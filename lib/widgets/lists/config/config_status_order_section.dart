import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../core/utils/item_grouping_helper.dart';

const List<String> _kAllStatuses = [
  'PENDING',
  'IN_PROGRESS',
  'PAUSED',
  'DROPPED',
  'COMPLETED',
];

class _Entry {
  final String key;
  bool enabled;

  _Entry({required this.key, required this.enabled});
}

class ConfigStatusOrderSection extends StatefulWidget {
  final List<String>? statusOrder;
  final ValueChanged<List<String>?> onChanged;

  const ConfigStatusOrderSection({
    super.key,
    required this.statusOrder,
    required this.onChanged,
  });

  @override
  State<ConfigStatusOrderSection> createState() =>
      _ConfigStatusOrderSectionState();
}

class _ConfigStatusOrderSectionState extends State<ConfigStatusOrderSection> {
  late List<_Entry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildEntries(widget.statusOrder);
  }

  List<_Entry> _buildEntries(List<String>? statusOrder) {
    if (statusOrder == null || statusOrder.isEmpty) {
      return _kAllStatuses
          .map((k) => _Entry(key: k, enabled: true))
          .toList();
    }
    final ordered = statusOrder
        .where(_kAllStatuses.contains)
        .map((k) => _Entry(key: k, enabled: true))
        .toList();
    final disabled = _kAllStatuses
        .where((k) => !statusOrder.contains(k))
        .map((k) => _Entry(key: k, enabled: false))
        .toList();
    return [...ordered, ...disabled];
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final entry = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, entry);
    });
    _notify();
  }

  void _toggle(int index, bool value) {
    setState(() => _entries[index].enabled = value);
    _notify();
  }

  void _notify() {
    final enabled = _entries
        .where((e) => e.enabled)
        .map((e) => e.key)
        .toList();
    // null means "all visible in default order" — only store when customized
    final isDefault =
        enabled.length == _kAllStatuses.length &&
        enabled.every((k) => enabled.indexOf(k) == _kAllStatuses.indexOf(k));
    widget.onChanged(isDefault ? null : enabled);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.configStatusOrderTitle,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.configStatusOrderDesc,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: _onReorder,
              children: [
                for (int i = 0; i < _entries.length; i++)
                  _StatusEntryTile(
                    key: ValueKey(_entries[i].key),
                    index: i,
                    label: groupLabelFor(context, _statusGroupKey(_entries[i].key)),
                    enabled: _entries[i].enabled,
                    onToggle: (v) => _toggle(i, v),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _statusGroupKey(String status) {
  switch (status) {
    case 'PENDING':
      return kGroupKeyPending;
    case 'IN_PROGRESS':
      return kGroupKeyInProgress;
    case 'PAUSED':
      return kGroupKeyPaused;
    case 'DROPPED':
      return kGroupKeyDropped;
    case 'COMPLETED':
      return kGroupKeyCompleted;
    default:
      return status;
  }
}

class _StatusEntryTile extends StatelessWidget {
  final int index;
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _StatusEntryTile({
    super.key,
    required this.index,
    required this.label,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: enabled ? null : colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: onToggle,
        ),
      ),
    );
  }
}
