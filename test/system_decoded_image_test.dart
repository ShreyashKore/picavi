import 'dart:async';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/core/images/system_decoded_image.dart';
import 'package:oiv/core/widgets/app_image.dart';
import 'package:oiv/viewer/domain/constants/supported_image_extensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.gyanoba.oiv/file_open');

  group('imageExtensionsFor', () {
    test('adds HEIC/AVIF/TIFF only with system decoding', () {
      expect(
        imageExtensionsFor(systemDecoding: false),
        supportedImageExtensions,
      );
      expect(
        imageExtensionsFor(systemDecoding: true),
        containsAll(<String>[
          '.heic',
          '.heif',
          '.avif',
          '.tif',
          '.tiff',
          '.jpg',
        ]),
      );
    });
  });

  group('AppImage provider selection', () {
    test('HEIC uses the system decoder sized for thumbnails', () {
      final provider = AppImage.file(
        '/p/a.HEIC',
        cacheWidth: 220,
      ).imageProvider;
      if (isSystemImageDecodingAvailable) {
        expect(
          provider,
          const SystemDecodedImage('/p/a.HEIC', maxPixelSize: 220),
        );
      } else {
        expect(provider, isA<ResizeImage>());
      }
    }, skip: !Platform.isMacOS);

    test('JPEG keeps using Flutter decoding', () {
      final provider = AppImage.file('/p/a.jpg', cacheWidth: 220).imageProvider;
      expect(provider, isA<ResizeImage>());
    });
  });

  group('SystemDecodedImage', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('decodes the bytes returned by the native side', () async {
      final calls = <Map<Object?, Object?>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'decodeImage');
            calls.add(call.arguments as Map<Object?, Object?>);
            return img.encodePng(img.Image(width: 30, height: 12));
          });

      final info = await _resolve(
        const SystemDecodedImage('/p/photo.heic', maxPixelSize: 64),
      );

      expect((info.image.width, info.image.height), (30, 12));
      expect(calls.single, {'path': '/p/photo.heic', 'maxPixelSize': 64});
    });

    test('reports an error when the system cannot decode', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      await expectLater(
        _resolve(const SystemDecodedImage('/p/broken.heic')),
        throwsA(isA<StateError>()),
      );
    });
  });
}

Future<ImageInfo> _resolve(ImageProvider provider) {
  final completer = Completer<ImageInfo>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      stream.removeListener(listener);
      completer.complete(info);
    },
    onError: (error, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(error, stackTrace);
    },
  );
  stream.addListener(listener);
  return completer.future;
}
