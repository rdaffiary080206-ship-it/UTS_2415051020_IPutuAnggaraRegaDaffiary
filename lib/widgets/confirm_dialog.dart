import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Menampilkan dialog konfirmasi. Mengembalikan `true` jika pengguna
/// menekan tombol konfirmasi, `false`/`null` jika membatalkan.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
  String cancelLabel = 'Batal',
  IconData icon = Icons.delete_forever_outlined,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      icon: Icon(icon, color: AppColors.primary, size: 36),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
