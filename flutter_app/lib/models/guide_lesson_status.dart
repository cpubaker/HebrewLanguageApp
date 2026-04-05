enum GuideLessonStatus {
  unread('unread'),
  studying('studying'),
  read('read');

  const GuideLessonStatus(this.storageValue);

  final String storageValue;

  static GuideLessonStatus? fromStorageValue(String rawValue) {
    final normalizedValue = rawValue.trim();
    for (final status in GuideLessonStatus.values) {
      if (status.storageValue == normalizedValue) {
        return status;
      }
    }

    return null;
  }
}
