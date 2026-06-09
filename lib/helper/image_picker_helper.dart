import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  // Chọn một hình ảnh từ thư viện ảnh của thiết bị với chất lượng nén tùy chọn
  static Future<File?> pickImageFromGallery({int imageQuality = 85}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }
}
