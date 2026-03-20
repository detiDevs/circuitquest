import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/sandbox_mode/custom_component_palette_item.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/palette_item.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/custom_component_library.dart';
import '../../../../core/components/custom_component.dart';

/// Helper function to build a responsive component list widget
/// Used by both ComponentPalette and limited palettes to show consistent behavior
Widget buildResponsiveComponentList(
  BuildContext context, {
  required List<ComponentType> components,
  bool showHeader = true,
  bool custom = false,
  String? headerText,
}) {
  final isMobile = MediaQuery.of(context).size.width < Constants.kMobileThreshold;

  if (isMobile) {
    // Horizontal PageView with 2 rows of 5 components per page on mobile
    return _MobilePagedComponentList(
      components: components,
      showHeader: showHeader,
      headerText: headerText,
    );
  } else {
    // Vertical list on desktop
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              headerText ?? 'Components',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        if (showHeader) const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: components.length,
            itemBuilder: (context, index) {
              final componentType = components[index];
              return PaletteItem(componentType: componentType);
            },
          ),
        ),
      ],
    );
  }
}

class _MobilePagedComponentList extends StatefulWidget {
  const _MobilePagedComponentList({
    required this.components,
    required this.showHeader,
    this.headerText,
  });

  final List<ComponentType> components;
  final bool showHeader;
  final String? headerText;

  @override
  State<_MobilePagedComponentList> createState() =>
      _MobilePagedComponentListState();
}

class _MobilePagedComponentListState extends State<_MobilePagedComponentList> {
  late final PageController _pageController;
  int _currentPage = 0;

  int get _pageCount => (widget.components.length / 10).ceil();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.headerText ?? 'Components',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        if (widget.showHeader) const Divider(height: 1),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pageCount,
            onPageChanged: (pageIndex) {
              setState(() {
                _currentPage = pageIndex;
              });
            },
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 10;
              final endIndex = (startIndex + 10).clamp(0, widget.components.length);
              final pageComponents = widget.components.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: pageComponents.length,
                  itemBuilder: (context, index) {
                    final componentType = pageComponents[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: PaletteItem(componentType: componentType),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          componentType.displayName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (_pageCount > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 14 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Component palette widget showing available components.
///
/// Users can drag components from the palette onto the canvas.
class ComponentPalette extends ConsumerWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customLibrary = ref.watch(customComponentProvider);
    final customEntries = customLibrary.components;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            AppLocalizations.of(context)!.componentPaletteTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        // Component list
        Expanded(
          child: isMobile
              ? _buildHorizontalList(context, customEntries)
              : _buildVerticalList(context, customEntries),
        ),
      ],
    );
  }

  Widget _buildVerticalList(
    BuildContext context,
    List<CustomComponentEntry> customEntries,
  ) {
    return ListView(
      children: [
        ...availableComponents.map(
          (componentType) => PaletteItem(componentType: componentType),
        ),
        if (customEntries.isNotEmpty) ...[
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Custom components',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ...customEntries.map(
            (entry) => CustomComponentPaletteItem(
              componentType: ComponentType(
                name: entry.data.name,
                displayName: entry.data.name,
                iconPath: entry.spritePath ?? '',
                isAsset: false,
                createComponent: () => CustomComponent(entry.data),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHorizontalList(
    BuildContext context,
    List<CustomComponentEntry> customEntries,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...availableComponents.map(
            (componentType) => SizedBox(
              width: 70,
              child: PaletteItem(componentType: componentType),
            ),
          ),
          if (customEntries.isNotEmpty) ...[
            const VerticalDivider(width: 1),
            ...customEntries.map(
              (entry) => SizedBox(
                width: 70,
                child: CustomComponentPaletteItem(
                  componentType: ComponentType(
                    name: entry.data.name,
                    displayName: entry.data.name,
                    iconPath: entry.spritePath ?? '',
                    isAsset: false,
                    createComponent: () => CustomComponent(entry.data),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
