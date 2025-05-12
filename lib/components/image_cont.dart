// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:container_inspection/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:math';


class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.idName,
    required this.btnName,
    required this.fileName,
    required this.imageUrl,
    required this.onUpload,
  });

  final String idName;
  final String btnName;
  final String fileName;
  final String? imageUrl;
  final void Function(String imageUrl) onUpload;

  Future<int> getNextFileIndex(String prefix, String fileName) async {
    try {
      // Lấy danh sách tệp trong thư mục
      final files = await supabase.storage.from('image_cont').list(
        path: prefix,
      );

      // Lọc tệp có tiền tố `fileName`
      final relevantFiles = files.where((file) => file.name.startsWith(fileName)).toList();

      // Lấy số thứ tự cao nhất từ các tệp đã tồn tại
      int maxIndex = 0;
      for (final file in relevantFiles) {
        final match = RegExp(r'_(\d+)$').firstMatch(file.name);
        if (match != null) {
          final index = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (index > maxIndex) {
            maxIndex = index;
          }
        }
      }

      return maxIndex + 1; // Trả về số tiếp theo
    } catch (e) {
      print('Error fetching next file index: $e');
      return 1; // Mặc định trả về 1 nếu không có tệp
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Text('No Image'),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image == null) {
              return;
            }
            try {
              // Đọc dữ liệu ảnh
              Uint8List imageBytes = await image.readAsBytes();
              // Nén và chuyển đổi ảnh thành JPEG
              img.Image? decodedImage = img.decodeImage(imageBytes);
              if (decodedImage == null){
                throw Exception('Không thể giải mã ảnh');
              }

              // Tính toán tỷ lệ nén cần thiết
              final originalSize = imageBytes.lengthInBytes;
              const maxSize = 1024 * 1024; // 1MB
              double scaleFactor = 1.0; // Bắt đầu với tỷ lệ 1.0 (100%)
              if (originalSize > maxSize) {
                scaleFactor = sqrt(maxSize / originalSize); // Lấy căn bậc hai tỷ lệ
              }

              // Điều chỉnh kích thước ảnh
              final newWidth = (decodedImage.width * scaleFactor).toInt();
              final newHeight = (decodedImage.height * scaleFactor).toInt();
              final resizedImage = img.copyResize(decodedImage, width: newWidth, height: newHeight);

              // Nén ảnh thành JPEG với chất lượng 85%
              Uint8List compressedImage = Uint8List.fromList(
                img.encodeJpg(resizedImage, quality: 85),
              );

              // Nếu vẫn vượt quá 1MB, giảm tiếp chất lượng JPEG
              int quality = 85;
              while (compressedImage.lengthInBytes > maxSize && quality > 10) {
                quality -= 5; // Giảm chất lượng mỗi lần 5%
                compressedImage = Uint8List.fromList(
                  img.encodeJpg(resizedImage, quality: quality),
                );
              }

              String imagePath = '';

              if (fileName == 'image_fix' || fileName == 'cont_error'){
                final int fileCount = await getNextFileIndex(idName, fileName);
                imagePath = '$idName/${fileName}_$fileCount';

              } else {
                imagePath = '$idName/$fileName';
              }
              String contentType = 'image/jpeg';

              await supabase.storage.from('image_cont').uploadBinary(
                  imagePath,
                  // imageBytes,
                  compressedImage,
                  fileOptions: FileOptions(
                    upsert: true,
                    contentType: contentType,
                  ),
                );
                String imageUrl =
                    supabase.storage.from('image_cont').getPublicUrl(imagePath);

                onUpload(imageUrl);

            }catch (e){
              print('Error uploading image: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error uploading image: $e')),
              );
              return;
            }
            
          },
          child: Text(btnName),
        ),
      ],
    );
  }
}