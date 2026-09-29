import 'package:dio/dio.dart';

import 'models.dart';

import '../l10n/l10n.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors = const {}});

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  String? field(String name) => fieldErrors[name]?.first;

  @override
  String toString() => message;
}

/// Thin wrapper around the PolyCreds (Polypass) REST API v1.
class ApiClient {
  ApiClient({required String serverUrl, this.onUnauthorized}) : _dio = Dio() {
    _dio.options
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers = {'Accept': 'application/json'};
    this.serverUrl = serverUrl;
  }

  final Dio _dio;
  String? _token;

  /// Called when an authorized request gets 401 (token expired or revoked).
  void Function()? onUnauthorized;

  set serverUrl(String url) => _dio.options.baseUrl = '${normalizeServerUrl(url)}/api/v1';

  set token(String? token) => _token = token;

  static String normalizeServerUrl(String url) {
    var u = url.trim();
    if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'https://$u';
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    String? token,
    bool reportUnauthorized = true,
  }) async {
    final bearer = token ?? _token;
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {
            'Accept-Language': localeTag,
            if (bearer != null) 'Authorization': 'Bearer $bearer',
          },
        ),
      );
      return res.data;
    } on DioException catch (e) {
      final ex = _toApiException(e);
      if (ex.isUnauthorized && reportUnauthorized && token == null && _token != null) {
        onUnauthorized?.call();
      }
      throw ex;
    }
  }

  ApiException _toApiException(DioException e) {
    final res = e.response;
    if (res == null) {
      return ApiException(switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          tr.errTimeout,
        DioExceptionType.badCertificate => tr.errCertificate,
        _ => tr.errNoConnection,
      });
    }
    final body = res.data;
    var message = '';
    final fields = <String, List<String>>{};
    if (body is Map) {
      message = (body['message'] as String?) ?? '';
      final errors = body['errors'];
      if (errors is Map) {
        errors.forEach((k, v) {
          if (v is List) fields['$k'] = v.map((e) => '$e').toList();
        });
        if (fields.isNotEmpty) message = fields.values.first.first;
      }
    }
    if (message.isEmpty) {
      message = switch (res.statusCode) {
        401 => tr.err401,
        403 => tr.err403,
        404 => tr.err404,
        429 => tr.err429,
        _ => tr.errServer('${res.statusCode}'),
      };
    }
    return ApiException(message, statusCode: res.statusCode, fieldErrors: fields);
  }

  Map<String, dynamic> _data(dynamic body) => Map<String, dynamic>.from((body as Map)['data'] as Map);

  List<Map<String, dynamic>> _list(dynamic body) =>
      ((body as Map)['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  // SERVER

  /// Checks that [url] hosts a PolyCreds API: unauthorized /me must answer 401 with JSON.
  Future<void> probe(String url) async {
    final dio = Dio(BaseOptions(
      baseUrl: '${normalizeServerUrl(url)}/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
      validateStatus: (_) => true,
    ));
    try {
      final res = await dio.get<dynamic>('/me');
      if (res.statusCode == 401 && res.data is Map) return;
      throw ApiException(tr.errNotPolyCreds);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // AUTH

  Future<LoginResult> login(String email, String password, String deviceName) async {
    final body = await _send('POST', '/auth/login',
        data: {'email': email, 'password': password, 'device_name': deviceName}, reportUnauthorized: false);
    return LoginResult.fromJson(Map<String, dynamic>.from(body as Map));
  }

  Future<LoginResult> verify2FA(String pendingToken, String code) async {
    final body = await _send('POST', '/auth/2fa/verify', data: {'code': code}, token: pendingToken);
    return LoginResult.fromJson(Map<String, dynamic>.from(body as Map));
  }

  Future<void> resend2FA(String pendingToken) => _send('POST', '/auth/2fa/resend', token: pendingToken);

  Future<void> logout() => _send('POST', '/auth/logout', reportUnauthorized: false);

  // PROFILE

  Future<User> me() async => User.fromJson(_data(await _send('GET', '/me')));

  Future<User> updateMe(Map<String, dynamic> data) async =>
      User.fromJson(_data(await _send('PATCH', '/me', data: data)));

  // GROUPS

  Future<Group> rootGroup() async => Group.fromJson(_data(await _send('GET', '/groups/root')));

  Future<List<Group>> groups({GroupType? type}) async {
    final body = await _send('GET', '/groups', query: type != null ? {'type': type.name} : null);
    return _list(body).map(Group.fromJson).toList();
  }

  Future<Group> createGroup(String name, GroupType type) async =>
      Group.fromJson(_data(await _send('POST', '/groups', data: {'name': name, 'type': type.name})));

  Future<Group> updateGroup(int id, {String? name, GroupType? type}) async => Group.fromJson(_data(await _send(
        'PATCH',
        '/groups/$id',
        data: {'name': ?name, 'type': ?type?.name},
      )));

  Future<void> deleteGroup(int id) => _send('DELETE', '/groups/$id');

  // CREDENTIALS

  Future<List<CredentialSummary>> credentials() async =>
      _list(await _send('GET', '/credentials')).map(CredentialSummary.fromJson).toList();

  Future<Credential> credential(int id) async => Credential.fromJson(_data(await _send('GET', '/credentials/$id')));

  Future<Credential> createCredential(Map<String, dynamic> data) async =>
      Credential.fromJson(_data(await _send('POST', '/credentials', data: data)));

  Future<Credential> updateCredential(int id, Map<String, dynamic> data) async =>
      Credential.fromJson(_data(await _send('PATCH', '/credentials/$id', data: data)));

  Future<void> deleteCredential(int id) => _send('DELETE', '/credentials/$id');

  // NOTES

  Future<List<NoteSummary>> notes() async => _list(await _send('GET', '/notes')).map(NoteSummary.fromJson).toList();

  Future<Note> note(int id) async => Note.fromJson(_data(await _send('GET', '/notes/$id')));

  Future<Note> createNote(Map<String, dynamic> data) async =>
      Note.fromJson(_data(await _send('POST', '/notes', data: data)));

  Future<Note> updateNote(int id, Map<String, dynamic> data) async =>
      Note.fromJson(_data(await _send('PATCH', '/notes/$id', data: data)));

  Future<void> deleteNote(int id) => _send('DELETE', '/notes/$id');

  // TOKENS

  Future<List<DeviceToken>> tokens() async => _list(await _send('GET', '/tokens')).map(DeviceToken.fromJson).toList();

  Future<void> deleteToken(int id) => _send('DELETE', '/tokens/$id');

  Future<int> deleteOtherTokens() async {
    final body = await _send('DELETE', '/tokens');
    return body is Map ? (body['count'] as int? ?? 0) : 0;
  }
}
