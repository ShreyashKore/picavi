import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../domain/constants/supported_image_extensions.dart';
import '../../domain/services/image_picker_service.dart';
import 'native_file_channel_service.dart';

final XTypeGroup _imageFileGroup = XTypeGroup(
  label: 'Images',
  extensions:
      supportedImageExtensions
          .map((extension) => extension.replaceFirst('.', ''))
          .toList()
        ..sort(),
  mimeTypes: const [
    'image/bmp',
    'image/gif',
    'image/jpeg',
    'image/png',
    'image/svg+xml',
    'image/webp',
    'image/x-icon',
  ],
);

class DesktopImagePickerService implements ImagePickerService {
  DesktopImagePickerService({required NativeFileChannelService nativeChannel})
    : _nativeChannel = nativeChannel;

  final NativeFileChannelService _nativeChannel;

  @override
  Future<String?> pickImagePath({
    required String initialDirectory,
    required ImagePickerTexts texts,
  }) async {
    if (Platform.isMacOS) {
      return _nativeChannel.pickImageFile(
        initialDirectory: initialDirectory,
        texts: texts,
      );
    }

    final selectedFile = await openFile(
      acceptedTypeGroups: [_imageFileGroup],
      initialDirectory: initialDirectory,
      confirmButtonText: texts.openViewerPrompt,
    );

    return selectedFile?.path;
  }

  @override
  Future<String?> requestDirectoryAccess({
    required String initialDirectory,
    required DirectoryAccessTexts texts,
  }) async {
    if (Platform.isMacOS) {
      return _nativeChannel.authorizeDirectoryAccess(
        initialDirectory: initialDirectory,
        texts: texts,
      );
    }

    return initialDirectory;
  }
}
