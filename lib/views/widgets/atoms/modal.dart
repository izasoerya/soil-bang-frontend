import 'package:bang_soil/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppModal extends StatelessWidget {
  const AppModal({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.content,
    this.confirmText,
    this.cancelText,
    this.closeText,
    this.onConfirm,
    this.onCancel,
    this.onClose,
    this.isDanger = false,
    this.actions,
  });

  /// Factory for a confirmation modal with Confirm and Cancel buttons.
  factory AppModal.confirmation({
    Key? key,
    String title = 'Sampling Confirmation',
    String message = 'Are you sure you want to perform data sampling?',
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
    Color? iconBackgroundColor,
    Widget? content,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
  }) {
    return AppModal(
      key: key,
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor ?? (isDanger ? AppColors.red : AppColors.primary),
      iconBackgroundColor: iconBackgroundColor,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDanger: isDanger,
    );
  }

  /// Factory for a success modal with a Close button.
  factory AppModal.success({
    Key? key,
    String title = 'Success',
    String message = 'Success taking data',
    String closeText = 'Close',
    IconData icon = Icons.check_circle_outline_rounded,
    Color iconColor = AppColors.green,
    Color? iconBackgroundColor,
    Widget? content,
    VoidCallback? onClose,
  }) {
    return AppModal(
      key: key,
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      content: content,
      closeText: closeText,
      onClose: onClose,
    );
  }

  final String title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final String? closeText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;
  final bool isDanger;
  final List<Widget>? actions;

  /// Helper to display a confirmation dialog returning `true` on confirm, `false` or `null` on cancel.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    String title = 'Sampling Confirmation',
    String message = 'Are you sure you want to perform data sampling?',
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
    bool isDanger = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AppModal.confirmation(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        isDanger: isDanger,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  /// Helper to display a success modal with a Close button.
  static Future<void> showSuccess({
    required BuildContext context,
    String title = 'Success',
    String message = 'Success taking data',
    String closeText = 'Close',
    IconData icon = Icons.check_circle_outline_rounded,
    VoidCallback? onClose,
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AppModal.success(
        title: title,
        message: message,
        closeText: closeText,
        icon: icon,
        onClose: () {
          Navigator.of(ctx).pop();
          onClose?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.surface : Colors.white;
    final borderColor = isDark ? AppColors.border : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : Colors.black;
    final messageColor = isDark
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.75);
    final cancelTextColor = isDark ? Colors.white : Colors.black;
    final cancelBgColor = isDark ? AppColors.surfaceInput : const Color(0xFFF1F5F9);
    final cancelBorderColor = isDark ? AppColors.border : const Color(0xFFCBD5E1);

    final resolvedIconColor = iconColor ?? AppColors.primary;
    final resolvedIconBg = iconBackgroundColor ??
        resolvedIconColor.withValues(alpha: isDark ? 0.15 : 0.12);

    final effectivePrimaryColor = isDanger ? AppColors.red : AppColors.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: resolvedIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: resolvedIconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: messageColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],
            const SizedBox(height: 24),
            _buildActionButtons(
              context,
              textColor: textColor,
              cancelTextColor: cancelTextColor,
              cancelBgColor: cancelBgColor,
              cancelBorderColor: cancelBorderColor,
              effectivePrimaryColor: effectivePrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required Color textColor,
    required Color cancelTextColor,
    required Color cancelBgColor,
    required Color cancelBorderColor,
    required Color effectivePrimaryColor,
  }) {
    if (actions != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions!,
      );
    }

    // Confirmation case: Cancel and Confirm buttons
    if (confirmText != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                backgroundColor: cancelBgColor,
                foregroundColor: cancelTextColor,
                side: BorderSide(color: cancelBorderColor),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                cancelText ?? 'Cancel',
                style: TextStyle(
                  color: cancelTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: effectivePrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                confirmText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Close button (Success or Info modal)
    final resolvedCloseText = closeText ?? 'Close';
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onClose ?? () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: effectivePrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          resolvedCloseText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
