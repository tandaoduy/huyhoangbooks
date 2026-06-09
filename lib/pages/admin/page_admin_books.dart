import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/image_picker_helper.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageAdminBooks extends StatefulWidget {
  final ControllerBookStore controller;

  const PageAdminBooks({super.key, required this.controller});

  @override
  State<PageAdminBooks> createState() => _PageAdminBooksState();

  //Form thêm mới hoặc chỉnh sửa thông tin sách
  static void showFormSach(
      BuildContext context,
      ControllerBookStore controller,
      Book? book,
      ) {
    final bool isEdit = book != null;
    final tenController = TextEditingController(text: book?.tenSach ?? "");
    final tacGiaController = TextEditingController(text: book?.tacGia ?? "");
    final giaController = TextEditingController(
      text: book != null ? "${book.gia ?? 0}" : "",
    );
    final nxbController = TextEditingController(text: book?.nhaXuatBan ?? "");
    final namXbController = TextEditingController(
      text: book != null ? "${book.namXuatBan ?? 0}" : "",
    );
    final moTaController = TextEditingController(text: book?.moTa ?? "");
    final soLuongController = TextEditingController(
      text: book != null ? "${book.soLuong ?? 0}" : "",
    );
    final saleController = TextEditingController(
      text: book != null ? "${book.sale ?? 0}" : "0",
    );
    final imageLinkController = TextEditingController(text: book?.anh ?? "");

    String? selectedCategoryId = book?.theLoaiSach;
    if (selectedCategoryId == null && controller.mapTheLoai.isNotEmpty) {
      selectedCategoryId = controller.mapTheLoai.keys.first;
    }

    File? imageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            Future<void> chonAnhTuThuVien() async {
              final picked = await ImagePickerHelper.pickImageFromGallery();
              if (picked != null) {
                setBottomSheetState(() {
                  imageFile = picked;
                });
              }
            }

            return SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  top: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? "Sửa Sách" : "Thêm Sách Mới",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      // Tải ảnh bìa
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: chonAnhTuThuVien,
                              child: Container(
                                width: 80,
                                height: 104,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: imageFile != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : (imageLinkController.text.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  child: Image.network(
                                    imageLinkController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    Icon(
                                      Icons.broken_image,
                                      size: 32,
                                      color: Colors.black26,
                                    ),
                                  ),
                                )
                                    : Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 32,
                                  color: Colors.black26,
                                )),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Chọn ảnh từ thư viện hoặc dán link ảnh bên dưới",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14),
                      _buildTextField(tenController, "Tên sách"),
                      SizedBox(height: 10),
                      _buildTextField(tacGiaController, "Tác giả"),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              giaController,
                              "Giá gốc (đ)",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              saleController,
                              "Giảm giá (%)",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              soLuongController,
                              "Số lượng kho",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(nxbController, "Nhà xuất bản"),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              namXbController,
                              "Năm xuất bản",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Dropdown thể loại
                      if (controller.mapTheLoai.isNotEmpty) ...[
                        Text(
                          "Thể loại sách",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategoryId,
                              isExpanded: true,
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                              items: controller.mapTheLoai.values.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(cat.tenTheLoai, style: TextStyle(fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setBottomSheetState(() {
                                  selectedCategoryId = val;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      _buildTextField(
                        imageLinkController,
                        "Link ảnh bìa (nếu không upload)",
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                        moTaController,
                        "Mô tả sản phẩm",
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () async {
                            final name = tenController.text.trim();
                            final author = tacGiaController.text.trim();
                            final price =
                                int.tryParse(giaController.text.trim()) ?? 0;
                            final salePercent =
                                int.tryParse(saleController.text.trim()) ?? 0;
                            final qty =
                                int.tryParse(soLuongController.text.trim()) ?? 0;
                            final pub = nxbController.text.trim();
                            final year =
                                int.tryParse(namXbController.text.trim()) ?? 0;
                            final desc = moTaController.text.trim();
                            final imgUrl = imageLinkController.text.trim();
                            if (name.isEmpty) {
                              Get.snackbar(
                                "Lỗi",
                                "Vui lòng nhập tên sách",
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            // Hiển thị hộp thoại đang xử lý
                            Get.dialog(
                              Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFEF4D2F),
                                ),
                              ),
                              barrierDismissible: false,
                            );

                            try {
                              final finalBook = Book(
                                id: isEdit ? book.id : _generateUUIDv4(),
                                tenSach: name,
                                gia: price,
                                tacGia: author,
                                theLoaiSach: selectedCategoryId,
                                nhaXuatBan: pub,
                                namXuatBan: year,
                                moTa: desc,
                                soLuong: qty,
                                anh: imgUrl,
                                sale: salePercent,
                              );

                              if (isEdit) {
                                await controller.capNhatSach(
                                  finalBook,
                                  imageFile,
                                );
                              } else {
                                await controller.themSach(finalBook, imageFile);
                              }

                               // Đóng hộp thoại đang xử lý
                              Get.back();
                              // Đóng Form nhập liệu
                              Get.back();

                              Get.snackbar(
                                "Thành công",
                                isEdit
                                    ? "Đã cập nhật sách thành công"
                                    : "Đã thêm sách mới thành công",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                             } catch (e) {
                              Get.back(); // Đóng hộp thoại đang xử lý
                              Get.snackbar(
                                "Lỗi",
                                "Đã xảy ra lỗi: $e",
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Color(0xFFEF4D2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit ? "CẬP NHẬT" : "THÊM MỚI",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Hộp thoại xác nhận yêu cầu xóa sách
  static void showXacNhanXoaSach(
      BuildContext context,
      ControllerBookStore controller,
      String bookId,
      String bookTitle,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Xóa Sách?",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          content: Text(
            "Bạn có chắc chắn muốn xóa cuốn sách \"$bookTitle\" khỏi cơ sở dữ liệu không?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(fontSize: 16)),
            ),
            FilledButton(
              onPressed: () async {
                Get.back(); // Đóng hộp thoại xác nhận

                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
                  ),
                  barrierDismissible: false,
                );

                try {
                  await controller.xoaSach(bookId);
                  Get.back(); // Đóng hộp thoại đang xử lý

                  Get.snackbar(
                    "Đã xóa",
                    "Đã xóa sách khỏi cơ sở dữ liệu",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.back(); // Đóng hộp thoại đang xử lý
                  Get.snackbar(
                    "Lỗi",
                    "Không thể xóa sách: $e",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Xóa", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}

class _PageAdminBooksState extends State<PageAdminBooks> {
  final uiController = Get.put(AdminBooksUiController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminBooksUiController>(
      init: uiController,
      builder: (ui) {
        final List<Book> locSach = widget.controller.mapBooks.values.where((b) {
          final query = ui.searchQuery;
          return query.isEmpty ||
              b.tenSach.toLowerCase().contains(query) ||
              (b.tacGia ?? "").toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            // Thanh tìm kiếm
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onChanged: uiController.setSearchQuery,
                        style: TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "Tìm theo tên sách, tác giả...",
                          hintStyle: TextStyle(fontSize: 16, color: Colors.black38),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () => PageAdminBooks.showFormSach(
                        context,
                        widget.controller,
                        null,
                      ),
                      icon: Icon(Icons.add, size: 20),
                      label: const Text("Thêm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(0xFFEF4D2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: locSach.isEmpty
                  ? const Center(child: Text("Không tìm thấy cuốn sách nào"))
                  : ListView.separated(
                padding: EdgeInsets.all(14),
                itemCount: locSach.length,
                separatorBuilder: (_, __) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final book = locSach[index];
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: book.anh != null && book.anh!.isNotEmpty
                              ? Image.network(
                            book.anh!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image,
                              color: Colors.black26,
                            ),
                          )
                              : Icon(Icons.book, color: Colors.black26),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.tenSach,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                book.tacGia ?? "Không rõ tác giả",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dinhDangTien(book.giaBan),
                                    style: TextStyle(
                                      color: Color(0xFFEF4D2F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Kho: ${book.soLuong ?? 0}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: Colors.blueAccent,
                                size: 24,
                              ),
                              onPressed: () => PageAdminBooks.showFormSach(
                                context,
                                widget.controller,
                                book,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(height: 12),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                              onPressed: () =>
                                  PageAdminBooks.showXacNhanXoaSach(
                                    context,
                                    widget.controller,
                                    book.id,
                                    book.tenSach,
                                  ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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
      },
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 17),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ),
    ],
  );
}

String _generateUUIDv4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));

  // Set version to 4
  values[6] = (values[6] & 0x0f) | 0x40;
  // Set variant to RFC 4122
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