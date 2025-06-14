class FirestoreHelper {
  static String? getField(Map<String, dynamic> data, String expectedKey) {
    for (var entry in data.entries) {
      if (entry.key.trim().toLowerCase() == expectedKey.toLowerCase()) {
        return entry.value?.toString();
      }
    }
    return null;
  }
}
