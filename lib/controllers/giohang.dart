import 'package:huyhoangbooks/controllers/supabae_helper.dart';

class GioHangItem {
  int? id;
  String? uid;
  String bookId;
  int soLuong;
  bool chon;

  GioHangItem({
    this.id,
    this.uid,
    required this.bookId,
    this.soLuong = 1,
    this.chon = false,
  });

  // Chuyển đổi đối tượng giỏ hàng GioHangItem sang Map<String, dynamic> để gửi lên Supabase
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'uid': uid,
      'BookId': bookId,
      'soLuong': soLuong,
      'chon': chon,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Khởi tạo đối tượng GioHangItem từ bản đồ dữ liệu Map<String, dynamic>
  factory GioHangItem.fromMap(Map<String, dynamic> map) {
    return GioHangItem(
      id: map['id'] as int?,
      uid: map['uid'] as String?,
      bookId: map['BookId'] as String? ?? (map['bookId'] as String? ?? ''),
      soLuong: map['soLuong'] as int? ?? 1,
      chon: map['chon'] as bool? ?? false,
    );
  }
}

// Lớp hỗ trợ các thao tác cập nhật dữ liệu GioHang trên Supabase
class GioHangSnapshot {
  // Tải thông tin giỏ hàng của người dùng theo ID người dùng (uid) từ database
  static Future<Map<String, GioHangItem>> getGioHang(String uid) async {
    final data = await supabase
        .from("GioHang")
        .select()
        .eq("uid", uid);
    final map = <String, GioHangItem>{};
    for (final item in data) {
      final model = GioHangItem.fromMap(item);
      map[model.bookId] = model;
    }
    return map;
  }

  // Thêm mới một sản phẩm vào giỏ hàng trên database
  static Future<int> them(GioHangItem item) async {
    try {
      await supabase.from("GioHang").insert(item.toMap());
      return 1;
    } catch (e) {
      print("Lỗi thêm vào giỏ hàng: ${e.toString()}");
      return 0;
    }
  }

  // Cập nhật số lượng hoặc trạng thái tích chọn của một mặt hàng trong giỏ hàng trên database
  static Future<int> capNhat(GioHangItem item) async {
    try {
      await supabase
          .from("GioHang")
          .update(item.toMap())
          .eq("uid", item.uid!)
          .eq("BookId", item.bookId);
      return 1;
    } catch (e) {
      print("Lỗi cập nhật giỏ hàng: ${e.toString()}");
      return 0;
    }
  }

  // Xóa bỏ một cuốn sách ra khỏi giỏ hàng của người dùng trên database
  static Future<int> xoa(String uid, String bookId) async {
    try {
      await supabase
          .from("GioHang")
          .delete()
          .eq("uid", uid)
          .eq("BookId", bookId);
      return 1;
    } catch (e) {
      print("Lỗi xóa khỏi giỏ hàng: ${e.toString()}");
      return 0;
    }
  }
}

