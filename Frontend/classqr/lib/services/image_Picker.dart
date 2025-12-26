import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static Future<Uint8List?> pickProfileImageFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (file == null) return null;
    return file.readAsBytes();
  }

  static Future<Uint8List?> pickProfileImageFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (file == null) return null;
    return await file.readAsBytes();
  }
}
