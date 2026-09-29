import 'package:flutter_test/flutter_test.dart';
import 'package:polycreds/api/models.dart';

void main() {
  test('list item from current server has login, remote and dates', () {
    final c = CredentialSummary.fromJson({
      'id': 7,
      'group_id': 11,
      'name': 'Prod',
      'url': null,
      'favorite': true,
      'login': 'root',
      'remote': {'host': '10.0.0.12', 'port': 22, 'protocol': 'ssh'},
      'created_at': '2025-03-03T10:00:00.000000Z',
      'updated_at': '2026-09-12T10:00:00.000000Z',
    });
    expect(c.login, 'root');
    expect(c.isRemote, isTrue);
    expect(c.remoteKnown, isTrue);
    expect(c.createdAt!.year, 2025);
  });

  test('website from current server: remote key present and null', () {
    final c = CredentialSummary.fromJson({'id': 1, 'group_id': 1, 'name': 'GitHub', 'remote': null});
    expect(c.isRemote, isFalse);
    expect(c.remoteKnown, isTrue);
  });

  test('list item from older server: no login, remote unknown', () {
    final c = CredentialSummary.fromJson({'id': 1, 'group_id': 1, 'name': 'GitHub'});
    expect(c.login, isNull);
    expect(c.remoteKnown, isFalse);
  });

  test('detail keeps non-null login', () {
    final c = Credential.fromJson({'id': 1, 'group_id': 1, 'name': 'X', 'password': 'p'});
    expect(c.login, '');
    expect(c.toSummary().remoteKnown, isTrue);
  });

  test('token ip', () {
    final t = DeviceToken.fromJson({'id': 1, 'device_name': 'Pixel', 'is_current': false, 'ip': '94.25.170.3'});
    expect(t.ip, '94.25.170.3');
    expect(DeviceToken.fromJson({'id': 2, 'device_name': 'Old', 'is_current': false}).ip, isNull);
  });
}
