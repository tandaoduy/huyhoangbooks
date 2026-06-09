import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';

class PageAdminCategories extends StatelessWidget {
  final ControllerBookStore controller;

  const PageAdminCategories({super.key, required this.controller});

  // Hộp thoại biểu mẫu thêm mới hoặc chỉnh sửa thể loại sách
  static void showFormTheLoai(
    BuildContext context,
    ControllerBookStore controller,
    TheLoaiSach? cat,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(controller: controller, cat: cat),
    );
  }

  // Hộp thoại xác nhận yêu cầu xóa thể loại sách
  static void showXacNhanXoaTheLoai(
    BuildContext context,
    ControllerBookStore controller,
    String catId,
    String catName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa Thể Loại?", style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text(
            "Bạn có chắc chắn muốn xóa thể loại \"$catName\"? Các sách thuộc thể loại này sẽ không bị xóa nhưng sẽ mất tên danh mục.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
            ),
            FilledButton(
              onPressed: () async {
                Get.back();

                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
                  ),
                  barrierDismissible: false,
                );

                try {
                  await controller.xoaTheLoai(catId);
                  Get.back();

                  Get.snackbar(
                    "Đã xóa",
                    "Đã xóa thể loại thành công",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.back();
                  Get.snackbar(
                    "Lỗi",
                    "Không thể xóa thể loại: $e",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = controller.mapTheLoai.values.toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => PageAdminCategories.showFormTheLoai(context, controller, null),
            icon: Icon(Icons.add, size: 16),
            label: const Text("Thêm thể loại"),
            style: FilledButton.styleFrom(
              backgroundColor: Color(0xFFEF4D2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        Expanded(
          child: categories.isEmpty
              ? const Center(child: Text("Không có thể loại nào"))
              : ListView.separated(
                  padding: EdgeInsets.all(14),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.tenTheLoai,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Mã: ${cat.id}",
                                style: TextStyle(fontSize: 11, color: Colors.black38),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blueAccent,
                                  size: 20,
                                ),
                                onPressed: () => PageAdminCategories.showFormTheLoai(
                                  context,
                                  controller,
                                  cat,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => PageAdminCategories.showXacNhanXoaTheLoai(
                                  context,
                                  controller,
                                  cat.id,
                                  cat.tenTheLoai,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ),
    ],
  );
}

class _CategoryFormDialog extends StatefulWidget {
  final ControllerBookStore controller;
  final TheLoaiSach? cat;

  const _CategoryFormDialog({required this.controller, this.cat});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late TextEditingController _tenController;
  late bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.cat != null;
    _tenController = TextEditingController(text: widget.cat?.tenTheLoai ?? "");
  }

  @override
  void dispose() {
    _tenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isEdit ? "Sửa Thể Loại" : "Thêm Thể Loại Mới",
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: _buildTextField(_tenController, "Tên thể loại"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Hủy"),
        ),
        FilledButton(
          onPressed: () async {
            final name = _tenController.text.trim();
            if (name.isEmpty) return;

            // Đóng hộp thoại
            Get.back();

            // Hiển thị loading
            Get.dialog(
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
              ),
              barrierDismissible: false,
            );

            try {
              final catId = _isEdit ? widget.cat!.id : _generateUUIDv4();

              if (_isEdit) {
                await widget.controller.capNhatTheLoai(catId, name);
              } else {
                await widget.controller.themTheLoai(catId, name);
              }

              // Đóng loading
              Get.back();

              Get.snackbar(
                "Thành công",
                _isEdit ? "Đã cập nhật thể loại" : "Đã thêm thể loại mới",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.back(); // Đóng vòng xoay đang tải
              Get.snackbar(
                "Lỗi",
                "Không thể cập nhật thể loại: $e",
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
              );
            }
          },
          style: FilledButton.styleFrom(backgroundColor: Color(0xFFEF4D2F)),
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}

String _generateUUIDv4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));

  // Thiết lập phiên bản 4
  values[6] = (values[6] & 0x0f) | 0x40;
  // Thiết lập biến thể RFC 4122
  values[8] = (values[8] & 0x3f) | 0x80;

  final buffer = StringBuffer();
  for (var i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
      buffer.write('-');
    }
    buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
