// ignore_for_file: prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:container_inspection/services/connect_supabase.dart';
import 'package:container_inspection/utils/multi_select.dart';
import 'package:flutter/material.dart';

class DialogBoxBefore extends StatefulWidget {

  DialogBoxBefore({
    super.key,
    required this.selectedCont
    }
  );
  final selectedCont;

  @override
  State<DialogBoxBefore> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBoxBefore> {
  final connectSupabase = ConnectSupabase();
  final TextEditingController fixController = TextEditingController();

  String cont = '';
  String? selectedWeather;
  String? selectedFrom;
  String? seletedTo;
  List<String> selectedEndWall = [];
  List<String> selectedLeft = [];
  List<String> selectedRight = [];
  List<String> selectedFloor = [];
  List<String> selectedRoof = [];
  List<String> selectedTunnel = [];
  List<String> selectedDoor = [];

  List<Map<String, dynamic>> dropdownData = [];
  List<DropdownMenuItem<String>> contItems = [];
  List<DropdownMenuItem<String>> weatherItems = [];
  List<DropdownMenuItem<String>> fromItems = [];
  List<DropdownMenuItem<String>> toItems = [];
  List<DropdownMenuItem<String>> endwallItems = [];
  List<DropdownMenuItem<String>> leftItems = [];
  List<DropdownMenuItem<String>> rightItems = [];
  List<DropdownMenuItem<String>> floorItems = [];
  List<DropdownMenuItem<String>> roofItems = [];
  List<DropdownMenuItem<String>> tunnelItems = [];
  List<DropdownMenuItem<String>> doorItems = [];

  String hintthoitiet = '';
  String hintfrom = '';
  String hintto = '';
  String hintbefore = '';
  String hintleft = '';
  String hintright = '';
  String hintfloor = '';
  String hintdroof = '';
  String hinttunnel = '';
  String hintdoor = '';
  String hintfix = '';

  @override
  void initState(){
    super.initState();
    cont = widget.selectedCont?.text.toString()??'';
    getData();
    getHintText();
    
  }

  void getData() async {

    List<Map<String, dynamic>> items = await connectSupabase.fetchItems('choose_value');
    setState(() {
      // contItems = _buildDropdownItems(items, 'Container');
      weatherItems = _buildDropdownItems(items, 'Weather');
      fromItems = _buildDropdownItems(items, 'From');
      toItems = _buildDropdownItems(items, 'To');
      endwallItems = _buildDropdownItems(items, 'End_Wall');
      leftItems = _buildDropdownItems(items, 'Left_Side');
      rightItems = _buildDropdownItems(items, 'Right_Side');
      floorItems = _buildDropdownItems(items, 'Flooring');
      roofItems = _buildDropdownItems(items, 'Roof_Sheet');
      tunnelItems = _buildDropdownItems(items, 'Tunnel');
      doorItems = _buildDropdownItems(items, 'Door');
    });
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<Map<String, dynamic>> items, String columnName) {
    // Lọc giá trị duy nhất
    final uniqueValues = items
        .map((item) => item[columnName]?.toString())
        .where((value) => value != null && value.isNotEmpty) // Loại bỏ null và chuỗi rỗng
        .toSet()
        .toList();

    // Tạo danh sách DropdownMenuItem
    return uniqueValues.map((value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value!),
      );
    }).toList();
  }

  void insertData() async {
    final now = DateTime.now(); // Lấy thời gian hiện tại
    final gmt7Time = now.toUtc().add(const Duration(hours: 7)); // Chuyển sang GMT+7

    if (selectedWeather == null || selectedFrom == null || seletedTo == null || selectedEndWall.isEmpty || selectedLeft.isEmpty 
        || selectedRight.isEmpty || selectedRoof.isEmpty || selectedFloor.isEmpty || selectedDoor.isEmpty || selectedTunnel.isEmpty){

      if (context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông báo: Chưa chọn đủ các mục kiểm tra'), 
          backgroundColor: Colors.redAccent,)
        );
      }
      return;
    }
    List<Map<String, dynamic>> items = [];

    items.add({
      'created_at': gmt7Time.toIso8601String(),
      'Container': cont,
      'Weather': selectedWeather,
      'From': selectedFrom,
      'To': seletedTo,
      'End_Wall': selectedEndWall.join(','),
      'Left_Side': selectedLeft.join(','),
      'Right_Side': selectedRight.join(','),
      'Flooring': selectedFloor.join(','),
      'Roof_Sheet': selectedRoof.join(','),
      'Tunnel': selectedTunnel.join(','),
      'Door': selectedDoor.join(','),
      'items_repair': fixController.text
    });
    try {
      await connectSupabase.addItems(items);

      // Nếu thành công, đóng dialog
      if (context.mounted) {
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm dữ liệu thành công')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm dữ liệu: $e')),
        );
      }
    }
  }

  void updateData() async{

    // Gán giá trị an toàn từ hint hoặc selected
    final weather = selectedWeather?.isNotEmpty == true
        ? selectedWeather
        : (hintthoitiet.isNotEmpty ? hintthoitiet : null);
    final from = selectedFrom?.isNotEmpty == true
        ? selectedFrom
        : (hintfrom.isNotEmpty ? hintfrom : null);
    final to = seletedTo?.isNotEmpty == true
        ? seletedTo
        : (hintto.isNotEmpty ? hintto : null);

    final end = selectedEndWall.isNotEmpty
        ? selectedEndWall.join(',')
        : (hintbefore.isNotEmpty ? hintbefore : null);

    final left = selectedLeft.isNotEmpty
        ? selectedLeft.join(',')
        : (hintleft.isNotEmpty ? hintleft : null);

    final right = selectedRight.isNotEmpty
        ? selectedRight.join(',')
        : (hintright.isNotEmpty ? hintright : null);

    final floor = selectedFloor.isNotEmpty
        ? selectedFloor.join(',')
        : (hintfloor.isNotEmpty ? hintfloor : null);

    final droof = selectedRoof.isNotEmpty
        ? selectedRoof.join(',')
        : (hintdroof.isNotEmpty ? hintdroof : null);

    final tunnel = selectedTunnel.isNotEmpty
        ? selectedTunnel.join(',')
        : (hinttunnel.isNotEmpty ? hinttunnel : null);

    final door = selectedDoor.isNotEmpty
        ? selectedDoor.join(',')
        : (hintdoor.isNotEmpty ? hintdoor : null);

    final fix = fixController.text.isNotEmpty
        ? fixController.text
        : (hintfix.isNotEmpty ? hintfix : null);


    // Kiểm tra các giá trị bắt buộc
    if ([weather, from, to, end, left, right, floor, droof, tunnel, door]
        .any((value) => value == null)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thông báo: Chưa chọn đủ các mục cần kiểm"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }


    // Chuẩn bị dữ liệu để cập nhật
    final items = {
      'Weather': weather,
      'From': from,
      'To': to,
      'End_Wall': end,
      'Left_Side': left,
      'Right_Side': right,
      'Flooring': floor,
      'Roof_Sheet': droof,
      'Tunnel': tunnel,
      'Door': door,
      'items_repair': fix,
    };

    try {
      await ConnectSupabase().updateItems(items, cont, "cont_inspection");
      if (context.mounted) {
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật dữ liệu thành công')),
        );
      }

    }catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật dữ liệu: $error')),
        );
      }
    }
  }

  void upsertData() async {
    // Kiểm tra xem Container đã tồn tại chưa
    final existingContainer = await connectSupabase.checkContainerExists(cont);

    if (existingContainer) {
      // Nếu đã có Container, gọi update
      updateData();
    } else {
      // Nếu chưa có Container, gọi insert
      insertData();
    }

    await connectSupabase.updateItems({'Before': 'Đã kiểm'}, cont, 'infor_cont');
  }

  void getHintText() async {
    List<Map<String, dynamic>> items = await connectSupabase.getData('cont_inspection', cont);
    if (items != []){
      setState(() {
        for (var item in items){
          hintthoitiet = item['Weather']??'';
          hintfrom = item['From']??'';
          hintto = item['To']??'';
          hintbefore = item['End_Wall']??'';
          hintleft = item['Left_Side']??'';
          hintright = item['Right_Side']??'';
          hintfloor = item['Flooring']??'';
          hintdroof = item['Roof_Sheet']??'';
          hinttunnel = item['Tunnel']??'';
          hintdoor = item['Door']??'';
          hintfix = item['items_repair']??'';
        }
      });
      
    } 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        // height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text('Trước khi xuất hàng: $cont ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              
              DropdownButton(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text('Thời tiết: $hintthoitiet', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                value: selectedWeather,
                items: weatherItems,
                onChanged: (newValue){
                  setState(() {
                    selectedWeather = newValue;
                  });
                }
              ),
              DropdownButton(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text('Từ: $hintfrom', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                value: selectedFrom,
                items: fromItems,
                onChanged: (newValue){
                  setState(() {
                    selectedFrom = newValue;
                  });
                }
              ),
              DropdownButton(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text('Đến: $hintto', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                value: seletedTo,
                items: toItems,
                onChanged: (newValue){
                  setState(() {
                    seletedTo = newValue;
                  });
                }
              ),
              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: endwallItems.map((item) => item.value??"").toList(), 
                hintText: 'Phía trước cont: $hintbefore',
                selectedValues: selectedEndWall,
                onChanged: (selected){
                  setState(() {
                    selectedEndWall = selected;
                  });
                },
              ),

              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: leftItems.map((item) => item.value??"").toList(), 
                hintText: 'Bên trái cont: $hintleft',
                selectedValues: selectedLeft,
                onChanged: (selected){
                  setState(() {
                    selectedLeft = selected;
                  });
                },
              ),

              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: rightItems.map((item) => item.value??"").toList(), 
                hintText: 'Bên phải cont: $hintright',
                selectedValues: selectedRight,
                onChanged: (selected){
                  setState(() {
                    selectedRight = selected;
                  });
                },
              ),

              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: floorItems.map((item) => item.value??"").toList(), 
                hintText: 'Sàn cont: $hintfloor',
                selectedValues: selectedFloor,
                onChanged: (selected){
                  setState(() {
                    selectedFloor = selected;
                  });
                },
              ),

              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: roofItems.map((item) => item.value??"").toList(), 
                hintText: 'Trần cont: $hintdroof',
                selectedValues: selectedRoof,
                onChanged: (selected){
                  setState(() {
                    selectedRoof = selected;
                  });
                },
              ),

              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: tunnelItems.map((item) => item.value??"").toList(), 
                hintText: 'Gầm cont: $hinttunnel',
                selectedValues: selectedTunnel,
                onChanged: (selected){
                  setState(() {
                    selectedTunnel = selected;
                  });
                },
              ),

              const SizedBox(height: 5,),

              MultiSelectDropdown(
                items: doorItems.map((item) => item.value??"").toList(), 
                hintText: 'Cửa cont: $hintdoor',
                selectedValues: selectedDoor,
                onChanged: (selected){
                  setState(() {
                    selectedDoor = selected;
                  });
                },
              ),
              const SizedBox(height: 5,),

              TextField(
                controller: fixController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'Cần khắc phục (nếu có): $hintfix',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5))
                ),
              ),

              const SizedBox(height: 15,),

              Center(
                child: ElevatedButton(
                  onPressed: upsertData, 
                  child: const Text("Xác nhận")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}