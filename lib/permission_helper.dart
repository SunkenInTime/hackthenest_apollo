import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermissions() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    log("=> storage permission satus: $status");
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    return status == PermissionStatus.granted;
  }
}
