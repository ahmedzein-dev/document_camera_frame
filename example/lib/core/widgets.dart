import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';
import 'models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Document type selector (horizontal card list)
// ─────────────────────────────────────────────────────────────────────────────

class DocTypeSelector extends StatelessWidget {
  final List<DocTypeInfo> types;
  final DocumentType selected;
  final ValueChanged<DocumentType> onChanged;

  const DocTypeSelector({
    super.key,
    required this.types,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: types.map((info) {
        final isSelected = info.type == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(info.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: info == types.last ? 0 : 10,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? cs.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    info.icon,
                    size: 32,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI mode selector (vertical radio-style list)
// ─────────────────────────────────────────────────────────────────────────────

class UiModeSelector extends StatelessWidget {
  final List<UiModeInfo> modes;
  final DocumentCameraUIMode selected;
  final ValueChanged<DocumentCameraUIMode> onChanged;

  const UiModeSelector({
    super.key,
    required this.modes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: modes.map((info) {
        final isSelected = info.mode == selected;
        return GestureDetector(
          onTap: () => onChanged(info.mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? cs.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary
                        : cs.onSurfaceVariant.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    info.icon,
                    size: 20,
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                // Label + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? cs.primary : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outline,
                      width: 2,
                    ),
                    color: isSelected ? cs.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12, color: cs.onPrimary)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom launch bar
// ─────────────────────────────────────────────────────────────────────────────

class LaunchBar extends StatelessWidget {
  final VoidCallback onLaunch;

  const LaunchBar({super.key, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: onLaunch,
          icon: const Icon(Icons.camera_alt_rounded, size: 20),
          label: const Text(
            'Launch Camera',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
