DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;

class User {
  const User({required this.id, required this.name, required this.email, this.role});

  final int id;
  final String name;
  final String email;
  final String? role;

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        role: j['role'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'role': role};
}

enum GroupType {
  root,
  credential,
  note;

  static GroupType parse(String? v) =>
      GroupType.values.firstWhere((t) => t.name == v, orElse: () => GroupType.credential);
}

class Group {
  const Group({required this.id, required this.name, required this.type});

  final int id;
  final String name;
  final GroupType type;

  factory Group.fromJson(Map<String, dynamic> j) => Group(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        type: GroupType.parse(j['type'] as String?),
      );
}

class Remote {
  const Remote({required this.host, required this.port, required this.protocol});

  final String host;
  final int port;
  final String protocol;

  factory Remote.fromJson(Map<String, dynamic> j) => Remote(
        host: (j['host'] ?? '') as String,
        port: j['port'] is int ? j['port'] as int : int.tryParse('${j['port']}') ?? 22,
        protocol: (j['protocol'] ?? 'ssh') as String,
      );

  Map<String, dynamic> toJson() => {'host': host, 'port': port, 'protocol': protocol};
}

/// Credential without password and note (list item).
class CredentialSummary {
  const CredentialSummary({
    required this.id,
    required this.groupId,
    required this.name,
    this.url,
    this.favorite = false,
    this.createdAt,
    this.updatedAt,
    this.remote,
    this.login,
    this.remoteKnown = false,
  });

  final int id;
  final int? groupId;
  final String name;
  final String? url;
  final bool favorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Remote? remote;

  /// Null when the server does not send logins in lists (older servers).
  final String? login;

  /// True when the server sent the `remote` key, so a null [remote] really means "website".
  /// Older servers omit it from lists; then the type is known only after opening.
  final bool remoteKnown;

  bool get isRemote => remote != null;

  factory CredentialSummary.fromJson(Map<String, dynamic> j) => CredentialSummary(
        id: j['id'] as int,
        groupId: j['group_id'] as int?,
        name: (j['name'] ?? '') as String,
        url: j['url'] as String?,
        favorite: j['favorite'] == true || j['favorite'] == 1,
        createdAt: _date(j['created_at']),
        updatedAt: _date(j['updated_at']),
        remote: j['remote'] is Map ? Remote.fromJson(Map<String, dynamic>.from(j['remote'] as Map)) : null,
        login: j['login'] as String?,
        remoteKnown: j.containsKey('remote'),
      );

  CredentialSummary copyWith({bool? favorite, Remote? remote}) => CredentialSummary(
        id: id,
        groupId: groupId,
        name: name,
        url: url,
        favorite: favorite ?? this.favorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
        remote: remote ?? this.remote,
        login: login,
        remoteKnown: remoteKnown || remote != null,
      );
}

class Credential extends CredentialSummary {
  const Credential({
    required super.id,
    required super.groupId,
    required super.name,
    super.url,
    super.favorite,
    super.createdAt,
    super.updatedAt,
    super.remote,
    required String super.login,
    required this.password,
    this.note,
  }) : super(remoteKnown: true);

  @override
  String get login => super.login ?? '';

  final String password;
  final String? note;

  factory Credential.fromJson(Map<String, dynamic> j) {
    final s = CredentialSummary.fromJson(j);
    return Credential(
      id: s.id,
      groupId: s.groupId,
      name: s.name,
      url: s.url,
      favorite: s.favorite,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
      remote: s.remote,
      login: s.login ?? '',
      password: (j['password'] ?? '') as String,
      note: j['note'] as String?,
    );
  }

  CredentialSummary toSummary() => CredentialSummary(
        id: id,
        groupId: groupId,
        name: name,
        url: url,
        favorite: favorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
        remote: remote,
        login: login,
        remoteKnown: true,
      );
}

class NoteSummary {
  const NoteSummary({
    required this.id,
    required this.groupId,
    required this.name,
    this.favorite = false,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int? groupId;
  final String name;
  final bool favorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory NoteSummary.fromJson(Map<String, dynamic> j) => NoteSummary(
        id: j['id'] as int,
        groupId: j['group_id'] as int?,
        name: (j['name'] ?? '') as String,
        favorite: j['favorite'] == true || j['favorite'] == 1,
        createdAt: _date(j['created_at']),
        updatedAt: _date(j['updated_at']),
      );
}

class Note extends NoteSummary {
  const Note({
    required super.id,
    required super.groupId,
    required super.name,
    super.favorite,
    super.createdAt,
    super.updatedAt,
    this.note,
  });

  /// Quill Delta JSON (same format as the web editor) or plain text.
  final String? note;

  factory Note.fromJson(Map<String, dynamic> j) {
    final s = NoteSummary.fromJson(j);
    return Note(
      id: s.id,
      groupId: s.groupId,
      name: s.name,
      favorite: s.favorite,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
      note: j['note'] as String?,
    );
  }

  NoteSummary toSummary() =>
      NoteSummary(id: id, groupId: groupId, name: name, favorite: favorite, createdAt: createdAt, updatedAt: updatedAt);
}

/// Device session (Sanctum token).
class DeviceToken {
  const DeviceToken({
    required this.id,
    required this.deviceName,
    required this.isCurrent,
    this.lastUsedAt,
    this.expiresAt,
    this.createdAt,
    this.ip,
  });

  final int id;
  final String deviceName;
  final bool isCurrent;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  /// Last IP the token was used from; null on older servers and unused old tokens.
  final String? ip;

  factory DeviceToken.fromJson(Map<String, dynamic> j) => DeviceToken(
        id: j['id'] as int,
        deviceName: (j['device_name'] ?? '') as String,
        isCurrent: j['is_current'] == true,
        lastUsedAt: _date(j['last_used_at']),
        expiresAt: _date(j['expires_at']),
        createdAt: _date(j['created_at']),
        ip: j['ip'] as String?,
      );
}

class LoginResult {
  const LoginResult({required this.twoFactorRequired, required this.token, this.user});

  final bool twoFactorRequired;
  final String token;
  final User? user;

  factory LoginResult.fromJson(Map<String, dynamic> j) => LoginResult(
        twoFactorRequired: j['two_factor_required'] == true,
        token: j['token'] as String,
        user: j['user'] is Map ? User.fromJson(Map<String, dynamic>.from(j['user'] as Map)) : null,
      );
}
