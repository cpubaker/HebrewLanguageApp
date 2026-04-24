import 'dart:convert';
import 'dart:io';

class AiContextTransport {
  const AiContextTransport();

  Future<String> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.postUrl(uri).timeout(timeout);
      request.headers.contentType = ContentType.json;
      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }
      request.write(body);

      final response = await request.close().timeout(timeout);
      final responseBody = await utf8.decodeStream(response).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'AI context endpoint returned ${response.statusCode}.',
          uri: uri,
        );
      }

      return responseBody;
    } finally {
      client.close(force: true);
    }
  }
}
