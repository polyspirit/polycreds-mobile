@Tags(['network'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:polycreds/api/api_client.dart';

/// Hits the live server from .env. Run with:
/// flutter test --run-skipped -t network --dart-define-from-file=.env
void main() {
  const server = String.fromEnvironment('DEFAULT_SERVER');
  if (server.isEmpty) {
    test('DEFAULT_SERVER is set', () {}, skip: 'DEFAULT_SERVER is not set, pass --dart-define-from-file=.env');
    return;
  }

  test('probe accepts PolyCreds server', () async {
    await ApiClient(serverUrl: server).probe(server);
  });

  test('probe rejects other hosts', () async {
    expect(() => ApiClient(serverUrl: server).probe('https://example.com'), throwsA(isA<ApiException>()));
  });

  test('wrong password gives field error', () async {
    final api = ApiClient(serverUrl: server);
    try {
      await api.login('nobody-${DateTime.now().millisecondsSinceEpoch}@example.com', 'wrong', 'smoke test');
      fail('login must fail');
    } on ApiException catch (e) {
      expect(e.statusCode, 422);
      expect(e.field('email'), isNotNull);
    }
  });
}
