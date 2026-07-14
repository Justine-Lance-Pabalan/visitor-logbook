import 'package:flutter/material.dart';
import '../utils/colors.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final String? selected;
  final IconData icon;
  final List<String> options;
  final String dialogTitle;
  final void Function(String?) onChanged;

  const FilterButton({
    super.key,
    required this.label,
    required this.selected,
    required this.icon,
    required this.options,
    required this.dialogTitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected != null;

    return Expanded(
      child: OutlinedButton.icon(
        icon: Icon(icon, color: bsuRed, size: 16),
        label: Text(
          selected ?? label,
          style: TextStyle(
            color: bsuRed,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isActive ? bsuRed : Colors.grey.shade400,
            width: isActive ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: isActive ? bsuRed.withOpacity(0.08) : null,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (_) => SimpleDialog(
              title: Text(
                dialogTitle,
                style: const TextStyle(
                  color: bsuRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                if (isActive)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text(
                      'Clear filter',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ...options.map(
                  (option) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, option),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: selected == option ? bsuRed : Colors.black,
                        fontWeight: selected == option
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          if (result != null) {
            onChanged(result.isEmpty ? null : result);
          }
        },
      ),
    );
  }
}