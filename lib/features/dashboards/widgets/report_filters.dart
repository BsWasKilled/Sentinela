import 'package:flutter/material.dart';

import '../../alerts/domain/alert_type.dart';
import '../../territory/domain/territory.dart';

/// Filtros de região (chips) e de tipo de relato (menu).
class ReportFilters extends StatelessWidget {
  const ReportFilters({
    super.key,
    required this.region,
    required this.type,
    required this.onRegionChanged,
    required this.onTypeChanged,
  });

  final String? region;
  final AlertType? type;
  final ValueChanged<String?> onRegionChanged;
  final ValueChanged<AlertType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<AlertType?>(
          initialSelection: type,
          expandedInsets: EdgeInsets.zero,
          label: const Text('Tipo de relato'),
          leadingIcon: Icon(type?.icon ?? Icons.filter_list),
          onSelected: onTypeChanged,
          dropdownMenuEntries: [
            const DropdownMenuEntry(value: null, label: 'Todos os tipos'),
            for (final t in AlertType.values)
              DropdownMenuEntry(
                value: t,
                label: t.label,
                leadingIcon: Icon(t.icon),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Todas as regiões'),
                selected: region == null,
                onSelected: (_) => onRegionChanged(null),
              ),
              for (final name in Territory.regionNames) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(name),
                  selected: region == name,
                  onSelected: (_) => onRegionChanged(region == name ? null : name),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
