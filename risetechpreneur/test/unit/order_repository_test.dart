import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:risetechpreneur/data/order_repository.dart';

class _CaptureSendClient extends http.BaseClient {
  http.BaseRequest? lastRequest;

  final int statusCode;
  final String body;

  _CaptureSendClient({required this.statusCode, required this.body});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    final stream = Stream<List<int>>.value(body.codeUnits);
    return http.StreamedResponse(
      stream,
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  test(
    'placeOrder builds multipart request with expected headers/fields/file',
    () async {
      final client = _CaptureSendClient(
        statusCode: 200,
        body:
            '{"success":true,"message":"ok","order":{"id":11,"course_id":3,"user_id":2,"status":"pending"}}',
      );
      final repo = OrderRepository(client: client);

      final tempFile = File('${Directory.systemTemp.path}/proof_test.jpg');
      await tempFile.writeAsBytes([1, 2, 3]);

      await repo.placeOrder(courseId: 3, screenshot: tempFile, token: 't123');

      final req = client.lastRequest;
      expect(req, isNotNull);
      expect(req, isA<http.MultipartRequest>());

      final mp = req as http.MultipartRequest;
      expect(mp.url.path, contains('/api/orders/place'));
      expect(mp.headers['Authorization'], 'Bearer t123');
      expect(mp.fields['course_id'], '3');
      expect(mp.files, isNotEmpty);
      expect(mp.files.first.field, 'transaction_screenshot');
    },
  );
}
