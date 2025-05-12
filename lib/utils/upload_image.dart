// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:container_inspection/components/image_cont.dart';
import 'package:container_inspection/main.dart';
import 'package:flutter/material.dart';

class UploadImage extends StatefulWidget {
  
  const UploadImage({super.key, required this.selectCont});

  // ignore: prefer_typing_uninitialized_variables
  final selectCont;

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String cont = '';
  String? _imageUrlEmppty;
  String? _imageUrlError;
  String? _imageUrlFix;
  String? _imageUrlDone;
  String? _imageUrlHalfDoor;
  String? _imageUrlCloseDoor;
  String? _imageUrlSeal;

  @override
  void initState(){
    super.initState();
    cont = widget.selectCont.text.toString();

    _initializeImageUrls();
  }

  Future<void> _initializeImageUrls() async {
    _imageUrlEmppty = await _fetchEntryUrl('image_empty');
    _imageUrlError = await _fetchEntryUrl('image_cont_error');
    _imageUrlFix = await _fetchEntryUrl('image_fix');
    _imageUrlDone = await _fetchEntryUrl('image_done');
    _imageUrlHalfDoor = await _fetchEntryUrl('image_half_door');
    _imageUrlCloseDoor = await _fetchEntryUrl('image_close_door');
    _imageUrlSeal = await _fetchEntryUrl('image_seal');

    setState(() {}); // Cập nhật giao diện sau khi dữ liệu đã sẵn sàng
  }

  Future<String?> _fetchEntryUrl(String columnName) async {
    try {
      final response = await supabase
          .from('cont_inspection')
          .select(columnName)
          .eq('Container', cont)
          .single();

      return response[columnName] as String?;
    } catch (e) {
      print('Error fetching $columnName: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Ảnh kiểm cont: $cont', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),),

              const SizedBox(height: 15,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh Cont Rỗng',
                fileName: 'empty_cont', 
                imageUrl: _imageUrlEmppty, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlEmppty = imageUrl;
                  });

                  // Liên kết URL với bảng `cont_inspection`
                  await supabase
                      .from('cont_inspection')
                      .update({'image_empty': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
                
              ),

              const SizedBox(height: 10,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh cont lỗi (nếu có)',
                fileName: 'cont_error', 
                imageUrl: _imageUrlError, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlError = imageUrl;
                  });

                  await supabase
                      .from('cont_inspection')
                      .update({'image_cont_error': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
              ),

              const SizedBox(height: 10,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh sau khắc phục (nếu có)', 
                fileName: 'image_fix',
                imageUrl: _imageUrlFix, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlFix = imageUrl;
                  });

                  await supabase
                      .from('cont_inspection')
                      .update({'image_fix': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
              ),

              const SizedBox(height: 10,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh sau khi đóng xong', 
                fileName: 'image_done',
                imageUrl: _imageUrlDone, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlDone = imageUrl;
                  });

                  await supabase
                      .from('cont_inspection')
                      .update({'image_done': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
              ),
              const SizedBox(height: 10,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh đóng 1 nửa cửa cont', 
                fileName: 'image_half_door',
                imageUrl: _imageUrlHalfDoor, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlHalfDoor = imageUrl;
                  });

                  await supabase
                      .from('cont_inspection')
                      .update({'image_half_door': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
              ),
              const SizedBox(height: 10,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh sau khi đóng cửa', 
                fileName: 'image_close_door',
                imageUrl: _imageUrlCloseDoor, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlCloseDoor = imageUrl;
                  });

                  await supabase
                      .from('cont_inspection')
                      .update({'image_close_door': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
              ),
              const SizedBox(height: 10,),
              Avatar(
                idName: cont, 
                btnName: 'Ảnh kẹp chì', 
                fileName: 'image_seal',
                imageUrl: _imageUrlSeal, 
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrlSeal = imageUrl;
                  });

                  await supabase
                      .from('cont_inspection')
                      .update({'image_seal': imageUrl})
                      .eq('Container', cont);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image uploaded and linked successfully!')),
                  );
                  
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}