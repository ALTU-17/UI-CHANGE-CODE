import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

Future<bool> _checkAndRequestPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.status;
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return status.isGranted;
  }
  return true;
}

Future<Directory> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download/Evolvuschool/Parent/Homework');
  } else {
    return await getApplicationDocumentsDirectory();
  }
}

Future<void> downloadFile(String url, BuildContext context, String name) async {
  bool hasPermission = await _checkAndRequestPermission();
  if (!hasPermission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Storage permission denied.')),
    );
    return;
  }

  Directory directory = await getDownloadDirectory();
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  String path = "${directory.path}/$name";
  File file = File(path);

  try {
    var res = await http.get(Uri.parse(url));
    await file.writeAsBytes(res.bodyBytes);
    // Show notification and snackbar as in your code...
  } catch (e) {
    // Handle error
  }
}