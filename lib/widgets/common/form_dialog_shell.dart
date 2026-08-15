import 'package:flutter/material.dart';

/// Shared Add/Edit form dialog chrome: icon+title header, scrollable
/// sized content wrapping a caller-provided [Form] field column, and a
/// Cancel/Submit actions row.
class FormDialogShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final GlobalKey<FormState> formKey;
  final Widget fields;
  final VoidCallback onSubmit;
  final String submitLabel;

  const FormDialogShell({
    super.key,
    required this.icon,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          width: screenWidth * 0.85,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(key: formKey, child: fields),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: onSubmit, child: Text(submitLabel)),
      ],
    );
  }
}
