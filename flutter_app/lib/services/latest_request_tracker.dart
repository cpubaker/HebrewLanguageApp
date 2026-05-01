class LatestRequestTracker {
  final Map<String, int> _tokensByKey = <String, int>{};

  int start(String key) {
    final nextToken = (_tokensByKey[key] ?? 0) + 1;
    _tokensByKey[key] = nextToken;
    return nextToken;
  }

  bool isLatest(String key, int token) {
    return _tokensByKey[key] == token;
  }
}
