import 'dart:convert';

import 'package:huyhoangbooks/controllers/supabae_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataController {
  LocalDataController._();

  // Lấy email dạng chữ thường của người dùng đang đăng nhập, mặc định là "guest"
  static String get currentEmail {
    return supabase.auth.currentUser?.email?.toLowerCase() ?? "guest";
  }

  // Tạo khóa lưu trữ cục bộ duy nhất bằng cách kết hợp tiền tố với email người dùng
  static String userKey(String prefix) {
    return "${prefix}_${Uri.encodeComponent(currentEmail)}";
  }

  // Đọc danh sách bản đồ dữ liệu Map<String, dynamic> từ SharedPreferences theo khóa chỉ định
  static Future<List<Map<String, dynamic>>> readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      await prefs.setString(key, jsonEncode(<Map<String, dynamic>>[]));
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Lưu danh sách bản đồ dữ liệu Map<String, dynamic> vào SharedPreferences theo khóa chỉ định
  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  // Đọc giá trị chuỗi String từ SharedPreferences theo khóa chỉ định
  static Future<String?> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Lưu giá trị chuỗi String vào SharedPreferences theo khóa chỉ định
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Đọc giá trị Boolean từ SharedPreferences theo khóa, hỗ trợ giá trị mặc định nếu chưa lưu
  static Future<bool> readBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  // Lưu giá trị Boolean vào SharedPreferences theo khóa chỉ định
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
