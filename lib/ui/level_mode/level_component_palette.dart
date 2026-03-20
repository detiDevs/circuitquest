import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/component_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Component palette limited to components available for this level.
class LevelComponentPalette extends ConsumerWidget {
  final Level level;

  const LevelComponentPalette({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter available components based on level requirements
    final limitedComponents = availableComponents.where((comp) {
      return level.availableComponents.any((ac) => ac.type == comp.name);
    }).toList();

    // Reuse the responsive component list builder from component_palette.dart
    return buildResponsiveComponentList(
      context,
      components: limitedComponents,
      headerText: AppLocalizations.of(context)!.availableComponents,
    );
  }
}
