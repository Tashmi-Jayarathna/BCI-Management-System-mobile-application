import 'package:flutter/material.dart';

/// Shared list-tile card with a trailing "remove" action, used for
/// enrolled-course/enrolled-student rows inside the detail dialogs.
class RemovableListTileCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final String trailingTooltip;
  final VoidCallback onRemove;

  const RemovableListTileCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.trailingTooltip,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: leading,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: Icon(trailingIcon, color: Colors.redAccent),
          tooltip: trailingTooltip,
          onPressed: onRemove,
        ),
      ),
    );
  }
}
