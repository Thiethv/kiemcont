// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectSupabase{
  final supabase = Supabase.instance.client;
  
  Future<List<Map<String, dynamic>>> fetchItems(String tableDb) async {
    try {
      final response = await supabase
          .from(tableDb) // Tên bảng
          .select(); // Trả về danh sách các đối tượng JSON

      return response; // Trả về dữ liệu
    } catch (error) {
      print('Error fetching items: $error');
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String cont) async {
    try {
      final response = await supabase
          .from(tableName)
          .select()
          .eq('Container', cont);
      return response;
      
    }catch(e){
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamItems() {
    return supabase
      .from('infor_cont')
      .stream(primaryKey: ['id']);
  }

  Future<void> addItems(List<Map<String, dynamic>> items) async {
    try {
      final response = await supabase.from('cont_inspection').insert(items);

      // Kiểm tra phản hồi từ API
      if (response == null || response is! List) {
        print('Insert response is invalid or unexpected: $response');
      } else {
        print('Insert successful: $response');
      }
    } catch (error) {
      print('Error in addItems: $error');
    }
  }

  Future<void> updateItems(Map<String, dynamic> items, String cont, String tableName) async {
    try {
      final response = await supabase
                      .from(tableName)
                      .update(items)
                      .eq('Container', cont);
      
      if (response == null || response is! Map){
        print('Update response is invalid or unexpected: $response');
      } else {
        print('Update successfull: $response');
      }
    } catch (error) {
      print('Error in updateItems: $error');
    }
  }

  Future<List<FileObject>> listImages(String cont) async {
    try {
      final List<FileObject> response = await supabase
          .storage
          .from('image_cont')
          .list(path: cont);
          
      return response;
    } catch (e) {
      print('Error fetching files: $e');
      return [];
    }
  }

  // Kiểm tra Container có tồn tại trong bảng
  Future<bool> checkContainerExists(String cont) async {
    try {
      final response = await supabase
          .from('cont_inspection')
          .select('Container')
          .eq('Container', cont)
          .maybeSingle();

      // Nếu response khác null, có nghĩa là Container đã tồn tại
      return response != null;
    } catch (error) {
      // Nếu có lỗi, coi như Container không tồn tại
      print('Error checking Container: $error');
      return false;
    }
  }

}