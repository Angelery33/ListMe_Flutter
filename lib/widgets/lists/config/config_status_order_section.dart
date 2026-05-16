import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../core/utils/item_grouping_helper.dart';

/// La lista exhaustiva y canónica de claves de estado admitidas por la aplicación.
///
/// Se utiliza para asegurar que cualquier estado que no esté explícitamente en [statusOrder] se siga
/// mostrando (pero desactivado) en la lista de arrastrar y soltar.
const List<String> _kAllStatuses = [
  'PENDING',
  'IN_PROGRESS',
  'PAUSED',
  'DROPPED',
  'COMPLETED',
];

/// Modelo interno que empareja una clave de estado con su indicador de habilitado/visible.
class _Entry {
  /// La clave de estado (ej. `'PENDING'`, `'COMPLETED'`).
  final String key;

  /// Indica si este estado se muestra actualmente en la vista de detalles de la lista.
  bool enabled;

  _Entry({required this.key, required this.enabled});
}

/// Sección de configuración que permite al usuario reordenar y mostrar/ocultar estados de elementos
/// en la vista de detalles de la biblioteca utilizando una lista de arrastrar y soltar.
///
/// Emite `null` a través de [onChanged] cuando la configuración coincide con la predeterminada
/// (todos los estados habilitados en el orden canónico), evitando el almacenamiento innecesario.
class ConfigStatusOrderSection extends StatefulWidget {
  /// El orden de estado personalizado actual, o `null` cuando todos los estados se muestran
  /// en el orden predeterminado.
  final List<String>? statusOrder;

  /// Se llama cada vez que el usuario reordena o alterna un estado.
  ///
  /// Recibe la nueva lista ordenada de claves de estado *habilitadas*, o `null` si el
  /// resultado coincide con el orden predeterminado (para que pueda almacenarse como `null`).
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

/// Estado para [ConfigStatusOrderSection].
///
/// Mantiene la lista [_entries] mutable que impulsa la [ReorderableListView].
class _ConfigStatusOrderSectionState extends State<ConfigStatusOrderSection> {
  /// La copia de trabajo de las entradas de estado en su orden de visualización actual.
  late List<_Entry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildEntries(widget.statusOrder);
  }

  /// Convierte la lista [statusOrder] almacenada en una lista [_Entry] ordenada.
  ///
  /// Las entradas habilitadas aparecen primero (preservando el orden almacenado), seguidas de
  /// cualquier estado que no esté presente en [statusOrder] marcado como deshabilitado.
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

  /// Maneja los eventos de reordenación por arrastrar y soltar de la [ReorderableListView].
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final entry = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, entry);
    });
    _notify();
  }

  /// Alterna el estado habilitado de la entrada en el [index] y notifica al padre.
  void _toggle(int index, bool value) {
    setState(() => _entries[index].enabled = value);
    _notify();
  }

  /// Deriva el nuevo [statusOrder] de [_entries] y llama a [widget.onChanged].
  ///
  /// Pasa `null` cuando el resultado es idéntico a la configuración predeterminada
  /// para que el padre pueda omitir su almacenamiento.
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

/// Mapea una cadena de estado sin procesar (ej. `'PENDING'`) a la constante de clave de grupo
/// utilizada por [groupLabelFor] para buscar la etiqueta localizada.
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

/// Una única fila en la lista de arrastrar y soltar de orden de estado.
///
/// Muestra un controlador de arrastre, la [label] de estado localizada y un [Switch] que
/// controla si el estado es visible en la vista de detalles de la biblioteca.
class _StatusEntryTile extends StatelessWidget {
  /// La posición de este mosaico en la [ReorderableListView], utilizada por
  /// [ReorderableDragStartListener] para iniciar el arrastre.
  final int index;

  /// La etiqueta de visualización localizada para este estado.
  final String label;

  /// Indica si este estado está actualmente habilitado/visible.
  final bool enabled;

  /// Se llama cuando el usuario activa el interruptor de visibilidad.
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
