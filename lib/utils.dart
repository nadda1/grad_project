import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  return await _imagePicker.pickImage(source: source);
}
