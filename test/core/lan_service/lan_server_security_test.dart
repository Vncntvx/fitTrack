import 'dart:convert';
import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/lan_service/lan_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

class _HttpResult {
  const _HttpResult({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

void main() {
  const expectedToken = 'fittrack-security-token';

  late Directory testDir;
  late LanServer server;
  late int serverPort;

  Future<_HttpResult> sendRequest({
    required String method,
    required String route,
    Map<String, String>? headers,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(
        method,
        Uri.parse('http://127.0.0.1:$serverPort$route'),
      );
      headers?.forEach(request.headers.set);

      final response = await request.close();
      final responseBody = await utf8.decodeStream(response);
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name.toLowerCase()] = values.join(', ');
      });

      return _HttpResult(
        statusCode: response.statusCode,
        body: responseBody,
        headers: responseHeaders,
      );
    } finally {
      client.close(force: true);
    }
  }

  setUpAll(() async {
    testDir = Directory(
      path.join(
        'test',
        '.lan_security_test_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
    await testDir.create(recursive: true);

    final dbPath = path.join(testDir.path, 'lan_security_test.db');
    final db = AppDatabase.native(path: dbPath);

    final reservation = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    serverPort = reservation.port;
    await reservation.close();

    server = LanServer(db);
    await server.start(serverPort, token: expectedToken);
  });

  tearDownAll(() async {
    if (server.isRunning) {
      await server.stop();
    }
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test(
    'rejects query-param token and removes auth hint from response body',
    () async {
      final result = await sendRequest(
        method: 'GET',
        route: '/api/settings?token=$expectedToken',
      );

      expect(result.statusCode, 401);
      final payload = jsonDecode(result.body) as Map<String, dynamic>;
      expect(payload['error'], 'Unauthorized');
      expect(payload.containsKey('hint'), isFalse);
      expect(result.body, isNot(contains('?token=')));
      expect(result.body, isNot(contains('Authorization')));
    },
  );

  test('rejects legacy X-FitTrack-Token header', () async {
    final result = await sendRequest(
      method: 'GET',
      route: '/api/settings',
      headers: {'X-FitTrack-Token': expectedToken},
    );

    expect(result.statusCode, 401);
    final payload = jsonDecode(result.body) as Map<String, dynamic>;
    expect(payload['error'], 'Unauthorized');
  });

  test('accepts Authorization Bearer token for API requests', () async {
    final result = await sendRequest(
      method: 'GET',
      route: '/api/settings',
      headers: {'Authorization': 'Bearer $expectedToken'},
    );

    expect(result.statusCode, 200);
    final payload = jsonDecode(result.body) as Map<String, dynamic>;
    expect(payload['data'], isA<Map<String, dynamic>>());
    expect(payload['message'], 'Fetched settings successfully');
  });

  test('adds COOP/COEP headers on authenticated API responses', () async {
    final result = await sendRequest(
      method: 'GET',
      route: '/api/settings',
      headers: {'Authorization': 'Bearer $expectedToken'},
    );

    expect(result.statusCode, 200);
    expect(result.headers['cross-origin-opener-policy'], 'same-origin');
    expect(result.headers['cross-origin-embedder-policy'], 'require-corp');
  });

  test('returns COOP/COEP + CORS headers for OPTIONS preflight', () async {
    final result = await sendRequest(method: 'OPTIONS', route: '/api/settings');

    expect(result.statusCode, 200);
    expect(result.headers['access-control-allow-origin'], '*');
    expect(
      result.headers['access-control-allow-methods'],
      'GET, POST, PUT, DELETE, OPTIONS',
    );
    expect(
      result.headers['access-control-allow-headers'],
      'Content-Type, Authorization',
    );
    expect(result.headers['cross-origin-opener-policy'], 'same-origin');
    expect(result.headers['cross-origin-embedder-policy'], 'require-corp');
  });
}
