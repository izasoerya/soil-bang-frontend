import 'package:bang_soil/services/csv_export_service.dart';
import 'package:bang_soil/services/database_service.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:bang_soil/utils/enum.dart';
import 'package:bang_soil/views/widgets/atoms/modal.dart';
import 'package:bang_soil/views/widgets/molecules/debug_monitor_section.dart';
import 'package:flutter/material.dart';

class AppHeaderSection extends StatelessWidget {
  const AppHeaderSection({super.key});

  Future<void> _handleExportCSV(BuildContext context) async {
    try {
      final csvExportService = CsvExportService();
      await csvExportService.exportToCSV();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleResetData(BuildContext context) async {
    final confirmed = await AppModal.showConfirmation(
      context: context,
      title: 'Reset Data',
      message:
          'Semua data sensor yang tersimpan akan dihapus permanen. Yakin ingin melanjutkan?',
      confirmText: 'Reset',
      cancelText: 'Batal',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteAllReadings();
      if (context.mounted) {
        AppModal.showSuccess(
          context: context,
          title: 'Berhasil',
          message: 'Data berhasil direset.',
          closeText: 'Tutup',
        );
      }
    }
  }

  void _showRawBluetoothDebugDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const RawBluetoothDebugDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOIL-BANG',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Spectral Sensor Dashboard',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          PopupMenuButton<HeaderMenu>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
            ),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            onSelected: (action) {
              if (action == HeaderMenu.exportCSV) {
                _handleExportCSV(context);
              } else if (action == HeaderMenu.debugRawBluetooth) {
                _showRawBluetoothDebugDialog(context);
              } else if (action == HeaderMenu.resetData) {
                _handleResetData(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: HeaderMenu.exportCSV,
                child: Row(
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Export CSV',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HeaderMenu.debugRawBluetooth,
                child: Row(
                  children: [
                    Icon(
                      Icons.bug_report_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Debug Raw Bluetooth',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HeaderMenu.resetData,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.red,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Reset Data',
                      style: TextStyle(color: AppColors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
