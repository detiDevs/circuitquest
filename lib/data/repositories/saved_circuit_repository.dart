abstract class SavedCircuitRepository {
  Future<String> ensureDefaultDirectory();
  String sanitizeFileName(String input);
  Future<void> saveCircuitFile({required String path, required String jsonString});
  Future<String> readCircuitFile(String path);
}
