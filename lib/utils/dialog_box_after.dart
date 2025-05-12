// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, avoid_print
import 'package:container_inspection/services/connect_supabase.dart';
import 'package:flutter/material.dart';

class DialogBoxAfter extends StatefulWidget {
  final selectedCont;
  final selectedSeal;

  const DialogBoxAfter({super.key, required this.selectedCont, required this.selectedSeal});

  @override
  State<DialogBoxAfter> createState() => _DialogBoxAfterState();
}

class _DialogBoxAfterState extends State<DialogBoxAfter> {
  final connectSupabase = ConnectSupabase();

  final TextEditingController idController = TextEditingController();
  final TextEditingController ctnController = TextEditingController();
  final TextEditingController securityController = TextEditingController();
  final TextEditingController workerController = TextEditingController();

  String cont = '';
  String seal = '';
  String? selectedOvernight;

  String hintId = '';
  String hintCtn = '';
  String hintSec = '';
  String hintWh = '';
  String hintOver = '';

  @override
  void initState(){
    super.initState();
    cont = widget.selectedCont!.text.toString();
    seal = widget.selectedSeal.text.toString();
    getHintText();    
  }

  void getHintText() async {
    try{
      List<Map<String, dynamic>> items = await connectSupabase.getData('cont_inspection', cont);
      if (items.isNotEmpty){
        setState(() {
          for (var item in items){
            hintId = item['e-shipment']?.toString()??'';
            hintCtn = item['totalctn']?.toString()??'';
            hintOver = item['overnight']?.toString()??'';
            hintSec = item['security']?.toString()??'';
            hintWh = item['worker']?.toString()??'';
          }
        });
        
      }
    } catch(e) {
      print('Error: $e');
    }
     
  }

  void insertData() async{

    String upId = idController.text;
    String upCtn = ctnController.text;
    String upSec = securityController.text;
    String upWh = workerController.text;

    final idShip = upId.isNotEmpty ? upId : (hintId.isNotEmpty ? hintId : null);
    final ctnShip = upCtn.isNotEmpty ? upCtn : (hintCtn.isNotEmpty ? hintCtn : null);
    final secCheck = upSec.isNotEmpty ? upSec : (hintSec.isNotEmpty ? hintSec : null);
    final whCheck = upWh.isNotEmpty ? upWh : (hintWh.isNotEmpty ? hintWh : null);
    final overShip = selectedOvernight?.isNotEmpty == true
                    ? selectedOvernight
                    : (hintOver.isNotEmpty ? hintOver: null);

    if (idShip == null || ctnShip == null || overShip == null || secCheck == null || whCheck == null){
      if (context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thông báo: Chưa chọn đủ các mục cần kiểm"), 
            backgroundColor: Colors.redAccent,)
        );
        return;
      }
      
    }


    Map<String, dynamic> items = {
      'e-shipment': idShip,
      'totalctn': int.tryParse(ctnShip ?? ''),
      'seal': seal,
      'overnight': overShip,
      'security': secCheck,
      'worker': whCheck
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

  void clickCfm() async {
    final exitsContainer = await connectSupabase.checkContainerExists(cont);

    if (exitsContainer){
      insertData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thông báo: Chưa điền thông tin trước khi đóng hàng"), backgroundColor: Colors.redAccent,)
      );
    }
  }

  get overItems => <DropdownMenuItem<String>>[
    const DropdownMenuItem(value: '0 Đêm', child: Text('0 Đêm')),
    const DropdownMenuItem(value: '1 Đêm', child: Text('1 Đêm')),
    const DropdownMenuItem(value: '2 Đêm', child: Text('2 Đêm')),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sau khi xuất hàng: $cont', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),),

              const SizedBox(height: 10,),

              TextField(
                controller: idController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'eShipment: $hintId',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5)
                  )
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: ctnController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'Tổng số thùng: $hintCtn',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5)
                  )
                ),
              ),

              const SizedBox(height: 10,),

              DropdownButton(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text('Có lưu cont không?: $hintOver', style: const TextStyle(color: Colors.grey),),
                value: selectedOvernight,
                items: overItems, 
                onChanged: (newValue) {
                  setState(() {
                    selectedOvernight = newValue;
                  });
                }
              ),

              const SizedBox(height: 10,),
              
              TextField(
                controller: securityController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'Bảo vệ: $hintSec',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5)
                  )
                ),
              ),

              const SizedBox(height: 10,),

              TextField(
                controller: workerController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'Kho: $hintWh',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5)
                  )
                ),
              ),

              const SizedBox(height: 10,),

              Center(
                child: ElevatedButton(
                  onPressed: clickCfm, 
                  child: const Text("Xác nhận",)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}