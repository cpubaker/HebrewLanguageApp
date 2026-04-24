class AiContextTransport {
  const AiContextTransport();

  Future<String> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) {
    throw UnsupportedError('AI context transport is not available.');
  }
}
