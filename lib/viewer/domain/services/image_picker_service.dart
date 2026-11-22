class ImagePickerTexts {
  const ImagePickerTexts({required this.openViewerPrompt});

  final String openViewerPrompt;
}

class DirectoryAccessTexts {
  const DirectoryAccessTexts({required this.prompt, required this.message});

  final String prompt;
  final String message;
}

abstract class ImagePickerService {
  Future<String?> pickImagePath({
    required String initialDirectory,
    required ImagePickerTexts texts,
  });

  Future<String?> requestDirectoryAccess({
    required String initialDirectory,
    required DirectoryAccessTexts texts,
  });

  /// Asks the user to choose a folder, e.g. as a copy/move destination.
  Future<String?> pickDirectory({
    required String initialDirectory,
    required DirectoryAccessTexts texts,
  });
}
