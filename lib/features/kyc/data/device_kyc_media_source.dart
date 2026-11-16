import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/kyc_models.dart';
import '../domain/kyc_repository.dart';

/// [KycMediaSource] backed by the platform file picker and camera/gallery.
class DeviceKycMediaSource implements KycMediaSource {
  final ImagePicker _imagePicker;

  DeviceKycMediaSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'heic', 'webp'};

  @override
  Future<KycDocument?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = result?.files.singleOrNull;
    if (file == null || file.path == null) return null;
    return KycDocument(
      name: file.name,
      path: file.path!,
      sizeBytes: file.size,
      isImage: _imageExtensions.contains(file.extension?.toLowerCase()),
    );
  }

  @override
  Future<KycDocument?> takePhoto() =>
      _fromImagePicker(ImageSource.camera, CameraDevice.rear);

  @override
  Future<KycDocument?> pickPhoto() =>
      _fromImagePicker(ImageSource.gallery, CameraDevice.rear);

  Future<KycDocument?> _fromImagePicker(
    ImageSource source,
    CameraDevice device,
  ) async {
    final image = await _imagePicker.pickImage(
      source: source,
      preferredCameraDevice: device,
      maxWidth: 2400,
      imageQuality: 90,
    );
    if (image == null) return null;
    return KycDocument(
      name: image.name,
      path: image.path,
      sizeBytes: await image.length(),
      isImage: true,
    );
  }
}
