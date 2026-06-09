import 'package:flutter/material.dart';

// Widget hiển thị ảnh bìa của sách, hỗ trợ hiển thị ảnh mặc định khi lỗi hoặc đường dẫn trống
class AnhSach extends StatelessWidget {
  const AnhSach({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: Color(0xFFEDEDED),
        child: const Center(
          child: Icon(Icons.menu_book, color: Colors.black38, size: 42),
        ),
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Color(0xFFEDEDED),
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black38),
        ),
      ),
    );
  }
}

// Hàm định dạng số tiền (int) thành chuỗi có dấu chấm phân cách hàng nghìn và ký hiệu đ ở cuối
String dinhDangTien(int value) {
  var text = value.toString();
  var buffer = StringBuffer();

  for (var i = 0; i < text.length; i++) {
    var reverseIndex = text.length - i;
    buffer.write(text[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(".");
    }
  }

  return "$buffer đ";
}
