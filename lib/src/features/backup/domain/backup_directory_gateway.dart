abstract interface class BackupDirectoryGateway {
  Future<String?> chooseDirectory();

  Future<void> openDirectory(String path);

  Future<void> verifyWritable(String path);
}
