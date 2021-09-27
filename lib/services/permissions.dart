
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermissions() async {

  var status = await Permission.storage.status;
  if (!status.isGranted) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    await Permission.storage.request();
    status = await Permission.storage.status;
  }
  return status == PermissionStatus.granted;
}