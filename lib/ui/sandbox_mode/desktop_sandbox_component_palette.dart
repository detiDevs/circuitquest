import 'dart:math' as math;

import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/core/components/custom_component.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/custom_component_library.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/component_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopSandboxComponentPalette extends ConsumerWidget {
  const DesktopSandboxComponentPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customLibrary = ref.watch(customComponentProvider);
    final customComponents = customLibrary.components
        .map(
          (entry) => ComponentType(
            name: entry.data.name,
            displayName: entry.data.name,
            iconPath: entry.spritePath ?? '',
            isAsset: false,
            createComponent: () => CustomComponent(entry.data),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxPaletteHeight = constraints.maxHeight;
        final maxCustomHeight = maxPaletteHeight / 3;
        final estimatedHeaderHeight = 56.0;
        final estimatedItemHeight = 72.0;
        final estimatedCustomHeight = estimatedHeaderHeight +
            (customComponents.isEmpty
                ? 0
                : customComponents.length * estimatedItemHeight);
        final customSectionHeight = math.min(maxCustomHeight, estimatedCustomHeight);

        return Column(
          children: [
            Expanded(
              child: _PaletteSection(
                child: buildResponsiveComponentList(
                  context,
                  components: availableComponents,
                  headerText: AppLocalizations.of(context)!.availableComponents,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: customSectionHeight,
              child: _PaletteSection(
                child: buildResponsiveComponentList(
                  context,
                  components: customComponents,
                  custom: true,
                  headerText: AppLocalizations.of(context)!.customComponents,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PaletteSection extends StatelessWidget {
  const _PaletteSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
