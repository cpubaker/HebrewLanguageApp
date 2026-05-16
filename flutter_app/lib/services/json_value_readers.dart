int readNonNegativeInt(Object? value) {
  final parsedValue = switch (value) {
    final num numericValue => numericValue.toInt(),
    final String textValue => int.tryParse(textValue.trim()),
    _ => null,
  };

  if (parsedValue == null || parsedValue < 0) {
    return 0;
  }

  return parsedValue;
}

String? readOptionalString(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmedValue = value.trim();
  return trimmedValue.isEmpty ? null : trimmedValue;
}

bool? readOptionalBool(Object? value) {
  return switch (value) {
    final bool booleanValue => booleanValue,
    final num numericValue => numericValue != 0,
    final String textValue => switch (textValue.trim().toLowerCase()) {
      'true' => true,
      'false' => false,
      '1' => true,
      '0' => false,
      _ => null,
    },
    _ => null,
  };
}
