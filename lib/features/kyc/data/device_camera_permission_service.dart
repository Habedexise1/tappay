import 'package:permission_handler/permission_handler.dart';

import '../domain/kyc_repository.dart';

class DeviceCameraPermissionService implements CameraPermissionService {
  CameraPermission _map(PermissionStatus status) => switch (status) {
    PermissionStatus.granted ||
    PermissionStatus.limited => CameraPermission.granted,
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => CameraPermission.permanentlyDenied,
    _ => CameraPermission.denied,
  };

  @override
  Future<CameraPermission> status() async =>
      _map(await Permission.camera.status);

  @override
  Future<CameraPermission> request() async =>
      _map(await Permission.camera.request());

  @override
  Future<bool> openSettings() => openAppSettings();
}
