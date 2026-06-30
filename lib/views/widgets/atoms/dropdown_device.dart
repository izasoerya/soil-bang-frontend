import 'package:flutter/material.dart';

class DropdownDevice extends StatelessWidget {
  const DropdownDevice({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<String> items;
  final String selectedValue;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(31, 45, 56, 1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade600, width: 0.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<String>(
        value: selectedValue,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: Color.fromRGBO(30, 40, 51, 1),
        underline: const SizedBox(),
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(color: Colors.white)),
          );
        }).toList(),
      ),
    );
  }
}
