import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

String rgbtoHex(Color color){
  return '${color.red.toRadixString(16).padLeft(2,'0')}${color.green.toRadixString(16).padLeft(2,'0')}${color.blue.toRadixString(16).padLeft(2,'0')}';
}

Color hexToColor(String hex){
  return Color(int.parse(hex,radix: 16)+0xFF000000);
}
void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickAudio() async {
  try {
    final filePickerRes = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (filePickerRes != null && filePickerRes.files.single.path != null) {
      return File(filePickerRes.files.single.path!);
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<File?> pickImage() async {
  try {
    final filePickerRes = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (filePickerRes != null && filePickerRes.files.single.path != null) {
      return File(filePickerRes.files.single.path!);
    }
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

/// Turns an error into text for the UI. Real connection problems get a hint to
/// check the network; server messages (for example "Music service is busy...")
/// are shown as they are instead of blaming the user's internet.
String friendlyError(Object e) {
  final msg = e.toString().replaceFirst('Exception: ', '').trim();
  final lower = msg.toLowerCase();
  final isNetwork = lower.contains('socketexception') ||
      lower.contains('clientexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network error') ||
      lower.contains('timed out') ||
      lower.contains('waking up');
  if (isNetwork) {
    return "Couldn't reach the server. Check your connection and try again.";
  }
  if (msg.isEmpty) return 'Something went wrong. Please try again.';
  return msg;
}
