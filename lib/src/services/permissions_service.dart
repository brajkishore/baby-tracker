import 'package:permission_handler/permission_handler.dart';

class PermissionsState {
  const PermissionsState({
    required this.location,
    required this.backgroundLocation,
    required this.notification,
  });

  final PermissionStatus location;
  final PermissionStatus backgroundLocation;
  final PermissionStatus notification;

  bool get allGranted =>
      location.isGranted && backgroundLocation.isGranted && notification.isGranted;
}

class PermissionsService {
  Future<PermissionsState> check() async {
    return PermissionsState(
      location: await Permission.location.status,
      backgroundLocation: await Permission.locationAlways.status,
      notification: await Permission.notification.status,
    );
  }

  Future<PermissionsState> requestAll() async {
    final location = await Permission.locationWhenInUse.request();
    final bg = await Permission.locationAlways.request();
    final notification = await Permission.notification.request();
    return PermissionsState(
      location: location,
      backgroundLocation: bg,
      notification: notification,
    );
  }
}
