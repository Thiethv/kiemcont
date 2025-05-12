import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<String> items; // Danh sách các mục
  final String hintText; // Văn bản gợi ý
  final List<String> selectedValues; // Danh sách giá trị được chọn
  final ValueChanged<List<String>> onChanged; // Callback khi danh sách thay đổi

  // ignore: use_key_in_widget_constructors
  const MultiSelectDropdown({
    required this.items,
    required this.hintText,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          if (widget.selectedValues.contains(value)) {
            widget.selectedValues.remove(value); // Bỏ chọn nếu đã chọn trước đó
          } else {
            widget.selectedValues.add(value); // Thêm vào danh sách được chọn
          }
          widget.onChanged(widget.selectedValues); // Gọi callback khi thay đổi
        });
      },
      itemBuilder: (BuildContext context) {
        return widget.items.map((item) {
          return CheckedPopupMenuItem<String>(
            value: item,
            checked: widget.selectedValues.contains(item),
            child: Text(item),
          );
        }).toList();
      },
      
      tooltip: widget.hintText,
      position: PopupMenuPosition.under, // Menu hiển thị dưới nút
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.selectedValues.isEmpty
                    ? widget.hintText // Hiển thị gợi ý nếu chưa chọn gì
                    : widget.selectedValues.join(', '), // Hiển thị giá trị đã chọn
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: widget.selectedValues.isEmpty? Colors.grey: Colors.black),
                
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
