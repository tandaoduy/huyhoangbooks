import 'dart:io';

import 'package:huyhoangbooks/helper/auth_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController {
  ProfileController._();

  // Khóa lưu đường dẫn ảnh đại diện theo tài khoản email hiện tại
  static String get avatarKey {
    return "avatar_${Uri.encodeComponent(AuthHelper.currentEmail)}";
  }

  // Tải đường dẫn tệp tin ảnh đại diện đã được lưu cục bộ
  static Future<String?> loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(avatarKey);
  }

  // Chọn ảnh từ thư viện, lưu tệp tin vào thư mục tài liệu của ứng dụng và cập nhật đường dẫn ảnh đại diện
  static Future<String?> pickAndSaveAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 900,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        "avatar_${DateTime.now().millisecondsSinceEpoch}_${picked.name}";
    final savedFile = await File(picked.path).copy("${dir.path}/$fileName");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(avatarKey, savedFile.path);
    return savedFile.path;
  }
}
