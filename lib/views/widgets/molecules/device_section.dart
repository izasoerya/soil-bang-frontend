import 'package:bang_soil/theme/app_theme.dart';
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
  final VoidCallback onRefreshClick;
  final VoidCallback onConnectClick;

  @override
  State<DeviceSection> createState() => _DeviceSectionState();
}

class _DeviceSectionState extends State<DeviceSection> {
  late String _selectedDevice;

  @override
  void initState() {
    super.initState();
    _selectedDevice = widget.selectedValue;
  }

  @override
  void didUpdateWidget(DeviceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedDevice = widget.selectedValue;
    }
  }

  void _onDeviceChanged(String? device) {
    if (device == null) return;
    setState(() => _selectedDevice = device);
    widget.onDeviceChanged(device);
  }

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width * 0.05;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownDevice(
                items: widget.items,
                selectedValue: _selectedDevice,
                onChanged: _onDeviceChanged,
              ),
            ),
            const SizedBox(width: 8),
            _IconBtn(
              icon: Icons.refresh_rounded,
              onTap: widget.onRefreshClick,
              tooltip: 'Rescan',
            ),
            const SizedBox(width: 6),
            _ConnectBtn(onTap: widget.onConnectClick),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}

class _ConnectBtn extends StatelessWidget {
  const _ConnectBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_connected_rounded, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'Connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
