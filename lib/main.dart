// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:container_inspection/services/connect_supabase.dart';
import 'package:container_inspection/utils/dialog_box_after.dart';
import 'package:container_inspection/utils/dialog_box_before.dart';
import 'package:container_inspection/utils/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'settings/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: API_URL,
    anonKey: API_KEY,
  );
  runApp(const MainApp());
}
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final connectSupabase = ConnectSupabase();

  Map<int, Map<String, dynamic>> selectedvalues = {};

  TextEditingController controllerCont = TextEditingController();
  TextEditingController controllerSeal = TextEditingController();

  int _selectedIndex = -1;
  
  void beforeLoad(){
    if (_selectedIndex == -1 || !selectedvalues.containsKey(_selectedIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa chọn cont cần kiểm.", textAlign: TextAlign.center,)),
      );
      return;
    }
    controllerCont.text = selectedvalues[_selectedIndex]!['Container']??'';
    showDialog(
      context: context, 
      builder: (context){
        return DialogBoxBefore(selectedCont: controllerCont,);
      });
  }

  void afterLoad(){
    if (_selectedIndex == -1 || !selectedvalues.containsKey(_selectedIndex)){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa chọn cont cần kiểm", textAlign: TextAlign.center,))
      );
      return;
    }
    controllerCont.text = selectedvalues[_selectedIndex]!['Container']??'';
    controllerSeal.text = selectedvalues[_selectedIndex]!['Seal']??'';
    
    showDialog(
      context: context, 
      builder: (contect){
        return DialogBoxAfter(selectedCont: controllerCont, selectedSeal: controllerSeal);
      }
    );
  }

  void uploadImage(){
    if (_selectedIndex == -1 || !selectedvalues.containsKey(_selectedIndex)){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa chọn cont cần up ảnh'))
      );
      return;
    }
    controllerCont.text = selectedvalues[_selectedIndex]!['Container']??'';

    showDialog(
      context: context, 
      builder: (context){
        return UploadImage(selectCont:controllerCont,);
      }
    );
  }

  void loadData() async{
    controllerCont.text = selectedvalues[_selectedIndex]!['Container']??'';
    String cont = controllerCont.text;
    final files = await connectSupabase.listImages(cont);

    if (files.isNotEmpty){
      final listCheck = ['empty_cont', 'image_close_door', 'image_done', 'image_half_door', 'image_seal'];

      // Kiểm tra xem tất cả mục trong list_check có tồn tại trong danh sách files
      final allExist = listCheck.every((item) => 
        files.any((file) => file.name.contains(item))
      );
      if (allExist) {
        await connectSupabase.updateItems({'After': 'Đã xong'}, cont, 'infor_cont');
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chưa đủ hình ảnh kiểm cont", textAlign: TextAlign.center,))
        );
      }
    } else {
      print('No files found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KIỂM CONTAINER',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints){
          final totalHeight = constraints.maxHeight;

          return Column(
            children: [
              SizedBox(
                height: totalHeight * (2/3),
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: connectSupabase.streamItems(), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    }
                
                    if (snapshot.hasError){
                      return Center(child: Text('Error: ${snapshot.error}'),);
                    }
                
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu khả dụng'));
                    }
                
                    final data = snapshot.data!;
                
                    return ListView.builder(
                      itemCount: data.length+1,
                      itemBuilder: (context, index) {

                        if (index == 0){
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text("CONT",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                                textAlign: TextAlign.center,)),

                              Expanded(
                                flex: 2,
                                child: Text("CHÌ", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                                textAlign: TextAlign.center,)),

                              Expanded(
                                flex: 1,
                                child: Text("Trước", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                                textAlign: TextAlign.center,)),

                              Expanded(
                                flex: 1,
                                child: Text("Sau", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                                textAlign: TextAlign.center,))
                            ],
                          );
                        }
                        
                        final item = data[index-1];
                        
                        String cont = item['Container']??'';
                        String seal = item['Seal']?? '';
                        String before = item['Before']?? '';
                        String after = item['After']??'';

                        if (before != ''){
                          before = 'Đã kiểm';
                        }

                        if (after != ''){
                          after = 'Đã xong';
                        }
                
                        return Card(
                          color: _selectedIndex == index ? Colors.grey[300] : Colors.white,
                          child: ListTile(
                            onTap: (){
                              setState(() {
                                if (_selectedIndex != -1 && selectedvalues.containsKey(_selectedIndex)) {
                                  selectedvalues.remove(_selectedIndex);
                                }
                                _selectedIndex = index;
                                selectedvalues[index] = {
                                  'Container': cont,
                                  'Seal': seal,
                                  'Before': before,
                                  'After': after
                                };
                              });
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(cont, style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 13),textAlign: TextAlign.center,)
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(seal, style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 13),textAlign: TextAlign.center,)
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(before, style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 12),textAlign: TextAlign.center,)
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(after, style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 12),textAlign: TextAlign.center,)
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
              SizedBox(
                height: totalHeight * (1/3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: beforeLoad,
                            child: const Text("Trước khi xuất"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: afterLoad,
                            child: const Text("Sau khi xuất"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: uploadImage, 
                            child: const Text('Ảnh kiểm cont')
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: loadData, 
                            child: const Text('Tải lại')
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }
      
      )
      
      
    );
  }
}
