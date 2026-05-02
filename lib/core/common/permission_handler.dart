import 'package:permission_handler/permission_handler.dart'
    hide openAppSettings;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler show openAppSettings;

class PermissionHandlerHelper {
  /// Request camera permission for taking photos
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted || status.isDenied;
  }

  /// Request photo library read permission for selecting photos
  static Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isDenied;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  static Future<bool> isPhotoLibraryPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Open app settings if permission is denied permanently
  static Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  /// Get permission status message in Indonesian
  static String getPermissionMessage(PermissionStatus status, String permissionName) {
    if (status.isDenied) {
      return 'Izin $permissionName ditolak.';
    } else if (status.isPermanentlyDenied) {
      return 'Izin $permissionName ditolak secara permanen. Silakan buka Pengaturan untuk mengubahnya.';
    } else if (status.isRestricted) {
      return 'Izin $permissionName dibatasi oleh sistem.';
    }
    return 'Izin $permissionName berhasil diberikan.';
  }

  /// Request camera permission with detailed status
  static Future<PermissionStatus> requestCameraWithStatus() async {
    return await Permission.camera.request();
  }

  /// Request photo library permission with detailed status
  static Future<PermissionStatus> requestPhotoLibraryWithStatus() async {
    return await Permission.photos.request();
  }
}

