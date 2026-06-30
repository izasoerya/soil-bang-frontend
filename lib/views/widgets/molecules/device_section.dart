import 'package:bang_soil/views/widgets/atoms/dropdown_device.dart';
import 'package:flutter/material.dart';

class DeviceSection extends StatefulWidget {
  const DeviceSection({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onDeviceChanged,
    required this.onRefreshClick,
    required this.onConnectClick,
  });

  final List<String> items;
  final String selectedValue;
  final void Function(String?) onDeviceChanged;
  final void Function() onRefreshClick;
  final void Function() onConnectClick;

  @override
  State<DeviceSection> createState() => _DeviceSectionState();
}

class _DeviceSectionState extends State<DeviceSection> {
  late String _selectedDevice;
  void _onDeviceChanged(String? device) {
    setState(() {
      _selectedDevice = device!;
      widget.onDeviceChanged(device);
    });
  }

  @override
  void initState() {
    _selectedDevice = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(26, 34, 41, 1),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.grey.shade600, width: 0.25),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownDevice(
            items: widget.items,
            selectedValue: _selectedDevice,
            onChanged: _onDeviceChanged,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: BoxDecoration(
              color: Color.fromRGBO(30, 40, 51, 1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade600, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onRefreshClick,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.refresh, color: Colors.white),
                ),
                IconButton(
                  onPressed: widget.onConnectClick,
                  padding: EdgeInsets.zero,
                  iconSize: 40,
                  icon: Icon(Icons.arrow_right_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
