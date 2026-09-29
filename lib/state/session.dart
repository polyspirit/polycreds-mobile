import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../l10n/l10n.dart';

/// Cloud server offered on the server screen. Set DEFAULT_SERVER in .env and
/// build with --dart-define-from-file=.env; empty means self-hosted only.
const kDefaultServer = String.fromEnvironment('DEFAULT_SERVER');

enum SessionStage { loading, server, login, twoFactor, createPin, locked, unlocked }

/// Server choice, auth token, current user and local PIN lock.
class Session extends ChangeNotifier {
  Session({ApiClient? api, this.defaultServer = kDefaultServer}) : serverUrl = defaultServer {
    this.api = api ?? ApiClient(serverUrl: defaultServer);
    this.api.onUnauthorized = _onUnauthorized;
  }

  static const maxPinAttempts = 5;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  late final ApiClient api;

  SessionStage stage = SessionStage.loading;
  final String defaultServer;
  String serverUrl;
  User? user;

  String? _token;
  String? _pendingToken;
  String pendingEmail = '';
  int pinAttemptsLeft = maxPinAttempts;

  /// Set when the user is changing PIN from settings (not first setup).
  bool get hasPin => _pinHash != null;
  String? _pinHash;
  String? _pinSalt;
  int pinLength = 4;

  String get serverHost => Uri.tryParse(serverUrl)?.host ?? serverUrl;

  Future<void> init() async {
    final all = await _storage.readAll();
    serverUrl = all['server_url'] ?? defaultServer;
    api.serverUrl = serverUrl;
    _token = all['token'];
    api.token = _token;
    _pinHash = all['pin_hash'];
    _pinSalt = all['pin_salt'];
    pinAttemptsLeft = int.tryParse(all['pin_attempts'] ?? '') ?? maxPinAttempts;
    pinLength = int.tryParse(all['pin_length'] ?? '') ?? 4;
    final u = all['user'];
    if (u != null) user = User.fromJson(Map<String, dynamic>.from(jsonDecode(u) as Map));

    if (_token == null) {
      stage = all['server_url'] == null ? SessionStage.server : SessionStage.login;
    } else if (_pinHash == null) {
      stage = SessionStage.createPin;
    } else {
      stage = SessionStage.locked;
    }
    notifyListeners();
  }

  // SERVER

  Future<void> chooseServer(String url) async {
    final normalized = ApiClient.normalizeServerUrl(url);
    await api.probe(normalized);
    serverUrl = normalized;
    api.serverUrl = normalized;
    await _storage.write(key: 'server_url', value: normalized);
    stage = SessionStage.login;
    notifyListeners();
  }

  /// Back from login to server choice; also used from settings ("Сменить сервер").
  Future<void> changeServer() async {
    if (_token != null) await _signOut(revoke: true);
    stage = SessionStage.server;
    notifyListeners();
  }

  // AUTH

  Future<void> login(String email, String password) async {
    final result = await api.login(email.trim(), password, await _deviceName());
    if (result.twoFactorRequired) {
      _pendingToken = result.token;
      pendingEmail = email.trim();
      stage = SessionStage.twoFactor;
      notifyListeners();
    } else {
      await _completeLogin(result);
    }
  }

  Future<void> verify2FA(String code) async {
    final pending = _pendingToken;
    if (pending == null) throw ApiException(tr.errLoginExpired);
    try {
      await _completeLogin(await api.verify2FA(pending, code));
    } on ApiException catch (e) {
      // Attempts exceeded or pending token expired: start over.
      if (e.isUnauthorized) {
        _pendingToken = null;
        stage = SessionStage.login;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> resend2FA() async {
    final pending = _pendingToken;
    if (pending != null) await api.resend2FA(pending);
  }

  void cancel2FA() {
    _pendingToken = null;
    stage = SessionStage.login;
    notifyListeners();
  }

  Future<void> _completeLogin(LoginResult result) async {
    _pendingToken = null;
    _token = result.token;
    api.token = _token;
    await _storage.write(key: 'token', value: _token);
    user = result.user ?? await api.me();
    await _saveUser();
    // A new login always asks for a new PIN.
    await _clearPin();
    stage = SessionStage.createPin;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    user = await api.me();
    await _saveUser();
    notifyListeners();
  }

  void setUser(User u) {
    user = u;
    _saveUser();
    notifyListeners();
  }

  Future<void> _saveUser() => _storage.write(key: 'user', value: jsonEncode(user!.toJson()));

  /// Full sign out: revokes token on the server and wipes local secrets.
  Future<void> logout() async {
    await _signOut(revoke: true);
    stage = SessionStage.login;
    notifyListeners();
  }

  Future<void> _signOut({required bool revoke}) async {
    if (revoke && _token != null) {
      try {
        await api.logout();
      } catch (_) {
        // Offline or token already dead: local cleanup is enough.
      }
    }
    _token = null;
    _pendingToken = null;
    api.token = null;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
    await _clearPin();
    user = null;
  }

  void _onUnauthorized() {
    if (stage != SessionStage.unlocked && stage != SessionStage.locked) return;
    _signOut(revoke: false).then((_) {
      stage = SessionStage.login;
      notifyListeners();
    });
  }

  Future<String> _deviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return '${a.manufacturer} ${a.model} · PolyCreds';
      }
      if (Platform.isIOS) {
        final i = await info.iosInfo;
        return '${i.name} · PolyCreds';
      }
    } catch (_) {}
    return 'PolyCreds Mobile';
  }

  // PIN

  String _hash(String pin, String salt) {
    var digest = utf8.encode('$salt:$pin');
    for (var i = 0; i < 10000; i++) {
      digest = Uint8List.fromList(sha256.convert(digest).bytes);
    }
    return base64Encode(digest);
  }

  Future<void> setPin(String pin) async {
    final rnd = Random.secure();
    _pinSalt = base64Encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
    _pinHash = _hash(pin, _pinSalt!);
    pinAttemptsLeft = maxPinAttempts;
    pinLength = pin.length;
    await _storage.write(key: 'pin_length', value: '$pinLength');
    await _storage.write(key: 'pin_salt', value: _pinSalt);
    await _storage.write(key: 'pin_hash', value: _pinHash);
    await _storage.write(key: 'pin_attempts', value: '$pinAttemptsLeft');
    stage = SessionStage.unlocked;
    notifyListeners();
  }

  Future<void> _clearPin() async {
    _pinHash = null;
    _pinSalt = null;
    pinAttemptsLeft = maxPinAttempts;
    await _storage.delete(key: 'pin_hash');
    await _storage.delete(key: 'pin_salt');
    await _storage.delete(key: 'pin_attempts');
  }

  bool checkPin(String pin) => _pinHash != null && _hash(pin, _pinSalt!) == _pinHash;

  /// Returns true on success. Too many failures sign the user out.
  Future<bool> unlock(String pin) async {
    if (checkPin(pin)) {
      pinAttemptsLeft = maxPinAttempts;
      await _storage.write(key: 'pin_attempts', value: '$pinAttemptsLeft');
      stage = SessionStage.unlocked;
      notifyListeners();
      return true;
    }
    pinAttemptsLeft--;
    await _storage.write(key: 'pin_attempts', value: '$pinAttemptsLeft');
    if (pinAttemptsLeft <= 0) {
      await logout();
    } else {
      notifyListeners();
    }
    return false;
  }

  void lock() {
    if (stage == SessionStage.unlocked && hasPin) {
      stage = SessionStage.locked;
      notifyListeners();
    }
  }
}
