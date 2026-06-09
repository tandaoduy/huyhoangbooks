import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Lấy dữ liệu từ bảng chỉ định và chuyển đổi thành một bản đồ Map dữ liệu các đối tượng
Future<Map<K, T>> getMapData<T, K>({
  required String table,
  required T Function(Map<String, dynamic> json) fromJson,
  required K Function(T t) getID,
}) async {
  final data = await supabase.from(table).select();
  var iterable = data.map((e) => fromJson(e));
  Map<K, T> map = {for (var element in iterable) getID(element): element};
  return map;
}

// Lấy dữ liệu có lọc điều kiện so khớp và chuyển đổi thành bản đồ Map
Future<Map<K, T>> getMapDataFilter<T, K>({
  required String table,
  required String filterColumn,
  required Object filterValue,
  required T Function(Map<String, dynamic> json) fromJson,
  required K Function(T t) getID,
}) async {
  final data = await supabase
      .from(table)
      .select()
      .eq(filterColumn, filterValue);
  var iterable = data.map((e) => fromJson(e));
  Map<K, T> map = {for (var element in iterable) getID(element): element};
  return map;
}


// Lắng nghe sự kiện đăng xuất tài khoản và thực hiện hàm gọi lại callback tương ứng
void listenSignOut(void Function() signOutCallback) {
  supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.signedOut) {
      signOutCallback.call();
    }
  });
}

// Lắng nghe sự kiện đăng nhập tài khoản thành công và thực hiện hàm gọi lại callback
void listenSignIn(void Function() signInCallback) {
  supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      signInCallback.call();
    }
  });
}

// Upload hình ảnh lên Supabase Storage bucket chỉ định và trả về đường dẫn URL công khai kèm timestamp
Future<String> uploadImage({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false,
}) async {
  await supabase.storage
      .from(bucket)
      .upload(
        path,
        image,
        fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
      );
  final String publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
  return "$publicUrl?ts=${DateTime.now().millisecondsSinceEpoch}";
}

// Lấy Stream luồng dữ liệu thời gian thực của bảng được chỉ định từ Supabase
Stream<List<T>> getDataStream<T>({
  required String table,
  required List<String> ids,
  required T Function(Map<String, dynamic> json) fromJson,
}) {
  var mapStream = supabase.from(table).stream(primaryKey: ids);
  return mapStream.map((event) => event.map((e) => fromJson(e)).toList());
}

// Xóa tệp hình ảnh khỏi Supabase Storage bucket chỉ định
Future<void> deleteImage({required String bucket, required String path}) async {
  await supabase.storage.from(bucket).remove([path]);
}
