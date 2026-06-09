import 'package:huyhoangbooks/controllers/local_data_controller.dart';

class AddressController {
  AddressController._();

  // Lấy khóa lưu trữ cục bộ của địa chỉ theo tài khoản người dùng
  static String get _key {
    return LocalDataController.userKey("dia_chi");
  }

  // Tải danh sách các địa chỉ đã lưu cục bộ từ bộ nhớ máy
  static Future<List<Map<String, dynamic>>> loadAddresses() {
    return LocalDataController.readList(_key);
  }

  // Lưu danh sách các địa chỉ vào bộ nhớ cục bộ của máy
  static Future<void> saveAddresses(List<Map<String, dynamic>> addresses) {
    return LocalDataController.saveList(_key, addresses);
  }

  // Thêm mới hoặc cập nhật thông tin một địa chỉ trong danh sách và lưu lại
  static Future<List<Map<String, dynamic>>> upsertAddress(
    List<Map<String, dynamic>> addresses,
    Map<String, dynamic> address, {
    required bool isEdit,
  }) async {
    final updated = addresses.map((e) => Map<String, dynamic>.from(e)).toList();
    if (isEdit) {
      final idx = updated.indexWhere(
        (element) => element["id"] == address["id"],
      );
      if (idx != -1) {
        updated[idx] = address;
      }
    } else {
      updated.add(address);
    }
    if (address["macDinh"] == true) {
      for (final item in updated) {
        item["macDinh"] = item["id"] == address["id"];
      }
    }
    await LocalDataController.saveList(_key, updated);
    return updated;
  }

  // Thiết lập địa chỉ được chọn làm địa chỉ giao hàng mặc định
  static Future<List<Map<String, dynamic>>> setDefaultAddress(
    List<Map<String, dynamic>> addresses,
    String id,
  ) async {
    final updated = addresses.map((e) {
      final address = Map<String, dynamic>.from(e);
      address["macDinh"] = address["id"] == id;
      return address;
    }).toList();
    await LocalDataController.saveList(_key, updated);
    return updated;
  }

  // Xóa địa chỉ khỏi danh sách theo ID và cập nhật lại địa chỉ mặc định nếu cần
  static Future<List<Map<String, dynamic>>> deleteAddress(
    List<Map<String, dynamic>> addresses,
    String id,
  ) async {
    final updated = addresses
        .where((element) => element["id"] != id)
        .map((element) => Map<String, dynamic>.from(element))
        .toList();
    if (updated.isNotEmpty &&
        !updated.any((element) => element["macDinh"] == true)) {
      updated.first["macDinh"] = true;
    }
    await LocalDataController.saveList(_key, updated);
    return updated;
  }
}
