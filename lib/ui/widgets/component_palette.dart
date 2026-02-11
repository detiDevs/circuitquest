import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/base/component.dart';
import '../../state/custom_component_library.dart';
import '../../state/sandbox_state.dart';
import '../../core/components/custom_component.dart';

/// A draggable component type in the palette.
class ComponentType {
  final String name;
  final String displayName;
  final String iconPath;
  final bool isAsset;
  final Component Function() createComponent;

  const ComponentType({
    required this.name,
    required this.displayName,
    required this.iconPath,
    required this.createComponent,
    this.isAsset = true,
  });
}

/// Available component types in the palette.
//TODO: Create dynamically by mapping component registry
final List<ComponentType> availableComponents = [
  ComponentType(
    name: "InputSource",
    displayName: "Input",
    iconPath: 'assets/gates/Input.svg',
    createComponent: () => createComponentByName('InputSource')!,
  ),
  ComponentType(
    name: "OutputProbe",
    displayName: "Output",
    iconPath: 'assets/gates/Output.svg',
    createComponent: () => createComponentByName('OutputProbe')!,
  ),
  // Basic gates
  ComponentType(
    name: 'And',
    displayName: 'AND Gate',
    iconPath: 'assets/gates/And.svg',
    createComponent: () => createComponentByName('And')!,
  ),
  ComponentType(
    name: 'Or',
    displayName: 'OR Gate',
    iconPath: 'assets/gates/Or.svg',
    createComponent: () => createComponentByName('Or')!,
  ),
  ComponentType(
    name: 'Not',
    displayName: 'NOT Gate',
    iconPath: 'assets/gates/Not.svg',
    createComponent: () => createComponentByName('Not')!,
  ),
  ComponentType(
    name: 'Nand',
    displayName: 'NAND Gate',
    iconPath: 'assets/gates/Nand.svg',
    createComponent: () => createComponentByName('Nand')!,
  ),
  ComponentType(
    name: 'Nor',
    displayName: 'NOR Gate',
    iconPath: 'assets/gates/Nor.svg',
    createComponent: () => createComponentByName('Nor')!,
  ),
  ComponentType(
    name: 'Xor',
    displayName: 'XOR Gate',
    iconPath: 'assets/gates/Xor.svg',
    createComponent: () => createComponentByName('Xor')!,
  ),
  // Adders
  ComponentType(
    name: 'HalfAdder',
    displayName: 'Half Adder',
    iconPath: 'assets/gates/HalfAdder.svg',
    createComponent: () => createComponentByName('HalfAdder')!,
  ),
  ComponentType(
    name: 'FullAdder',
    displayName: 'Full Adder',
    iconPath: 'assets/gates/FullAdder.svg',
    createComponent: () => createComponentByName('FullAdder')!,
  ),
  // Sequential components
  ComponentType(
    name: 'Clock',
    displayName: 'Clock',
    iconPath: 'assets/gates/Register.svg', // Reuse register icon for now
    createComponent: () => createComponentByName('Clock')!,
  ),
  ComponentType(
    name: 'DLatch',
    displayName: 'D-Latch',
    iconPath: 'assets/gates/DLatch.svg',
    createComponent: () => createComponentByName('DLatch')!,
  ),
  ComponentType(
    name: 'DFlipFlop',
    displayName: 'D-Flip-Flop',
    iconPath: 'assets/gates/Register.svg',
    createComponent: () => createComponentByName('DFlipFlop')!,
  ),
  ComponentType(
    name: "Splitter8to1",
    displayName: "Splitter 8 to 1",
    iconPath: "assets/gates/Splitter8to1",
    createComponent: () => createComponentByName('Splitter8to1')!,
  ),
  ComponentType(
    name: "Splitter32to8",
    displayName: "Splitter 32 to 8",
    iconPath: "assets/gates/Splitter32to8",
    createComponent: () => createComponentByName('Splitter32to8')!,
  ),
  ComponentType(
    name: "Collector1to2",
    displayName: "Collector 1 to 2",
    iconPath: "assets/gates/Collector1to2",
    createComponent: () => createComponentByName('Collector1to2')!,
  ),
  ComponentType(
    name: "Collector1to5",
    displayName: "Collector 1 to 5",
    iconPath: "assets/gates/Collector1to5",
    createComponent: () => createComponentByName('Collector1to5')!,
  ),
  ComponentType(
    name: "Collector1to6",
    displayName: "Collector 1 to 6",
    iconPath: "assets/gates/Collector1to6",
    createComponent: () => createComponentByName('Collector1to6')!,
  ),
  ComponentType(
    name: "Collector8to16",
    displayName: "Collector8to16",
    iconPath: "assets/gates/Collector8to16",
    createComponent: () => createComponentByName('Collector8to16')!,
  ),
  ComponentType(
    name: "Multiplexer2Inp",
    displayName: "Multiplexer2Inp",
    iconPath: "assets/gates/Multiplexer2Inp",
    createComponent: () => createComponentByName('Multiplexer2Inp')!,
  ),
  ComponentType(
    name: "Multiplexer4Inp",
    displayName: "Multiplexer4Inp",
    iconPath: "assets/gates/Multiplexer4Inp",
    createComponent: () => createComponentByName('Multiplexer4Inp')!,
  ),
  ComponentType(
    name: "Multiplexer8Inp",
    displayName: "Multiplexer8Inp",
    iconPath: "assets/gates/Multiplexer8Inp",
    createComponent: () => createComponentByName('Multiplexer8Inp')!,
  ),
  ComponentType(
    name: "Adder32bit",
    displayName: "Adder32bit",
    iconPath: "",
    createComponent: () => createComponentByName('Adder32bit')!,
  ),
  ComponentType(
    name: "ProgramCounter",
    displayName: "ProgramCounter",
    iconPath: "",
    createComponent: () => createComponentByName('ProgramCounter')!,
  ),
  ComponentType(
    name: "InstructionMemory",
    displayName: "InstructionMemory",
    iconPath: "",
    createComponent: () => createComponentByName('InstructionMemory')!,
  ),
  ComponentType(
    name: "RegisterBlock",
    displayName: "RegisterBlock",
    iconPath: "",
    createComponent: () => createComponentByName('RegisterBlock')!,
  ),
  ComponentType(
    name: "ALUAdvanced",
    displayName: "ALUAdvanced",
    iconPath: "",
    createComponent: () => createComponentByName('ALUAdvanced')!,
  ),
  ComponentType(
    name: "SignExtend",
    displayName: "SignExtend",
    iconPath: "",
    createComponent: () => createComponentByName('SignExtend')!,
  ),
  ComponentType(
    name: "ControlUnit",
    displayName: "ControlUnit",
    iconPath: "",
    createComponent: () => createComponentByName('ControlUnit')!,
  ),
  ComponentType(
    name: "ALUControl",
    displayName: "ALUControl",
    iconPath: "",
    createComponent: () => createComponentByName('ALUControl')!,
  ),
  ComponentType(
    name: "DataMemory",
    displayName: "DataMemory",
    iconPath: "",
    createComponent: () => createComponentByName('DataMemory')!,
  ),
  ComponentType(
    name: "ShiftLeft2",
    displayName: "ShiftLeft2",
    iconPath: "",
    createComponent: () => createComponentByName('ShiftLeft2')!,
  ),
];

/// Helper function to build a responsive component list widget
/// Used by both ComponentPalette and limited palettes to show consistent behavior
Widget buildResponsiveComponentList(
  BuildContext context, {
  required List<ComponentType> components,
  bool showHeader = true,
  String? headerText,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  if (isMobile) {
    // Horizontal scrollable list on mobile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              headerText ?? 'Components',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        if (showHeader) const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: components
                  .map(
                    (componentType) => SizedBox(
                      width: 70,
                      child: _PaletteItem(componentType: componentType),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        if (showHeader) const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: components.length,
            itemBuilder: (context, index) {
              final componentType = components[index];
              return _PaletteItem(componentType: componentType);
            },
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildVerticalList(BuildContext context, List<CustomComponentEntry> customEntries) {
    return ListView(
      children: [
        ...availableComponents.map(
          (componentType) => _PaletteItem(componentType: componentType),
        ),
        if (customEntries.isNotEmpty) ...[
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Custom components',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          ...customEntries.map(
            (entry) => _PaletteItem(
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

  Widget _buildHorizontalList(BuildContext context, List<CustomComponentEntry> customEntries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...availableComponents.map(
            (componentType) => SizedBox(
              width: 70,
              child: _PaletteItem(componentType: componentType),
            ),
          ),
          if (customEntries.isNotEmpty) ...[
            const VerticalDivider(width: 1),
            ...customEntries.map(
              (entry) => SizedBox(
                width: 70,
                child: _PaletteItem(
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

/// Individual palette item that can be dragged.
class _PaletteItem extends ConsumerWidget {
  final ComponentType componentType;

  const _PaletteItem({required this.componentType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Draggable<ComponentType>(
      data: componentType,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _ComponentIcon(
            iconPath: componentType.iconPath,
            isAsset: componentType.isAsset,
            size: 60,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildChild(context, ref, isMobile),
      ),
      child: _buildChild(context, ref, isMobile),
    );
  }

  Widget _buildChild(BuildContext context, WidgetRef ref, bool isMobile) {
    if (isMobile) {
      return _buildMobileChild(context, ref);
    } else {
      return _buildDesktopChild(context, ref);
    }
  }

  Widget _buildMobileChild(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: componentType.displayName,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            ref.read(sandboxProvider).selectComponentType(componentType.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.componentSelected(
                    componentType.displayName)),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _ComponentIcon(
              iconPath: componentType.iconPath,
              isAsset: componentType.isAsset,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopChild(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: _ComponentIcon(
          iconPath: componentType.iconPath,
          isAsset: componentType.isAsset,
          size: 40,
        ),
        title: Text(
          componentType.displayName,
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          // Select this component type
          ref.read(sandboxProvider).selectComponentType(componentType.name);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.componentSelected(
                  componentType.displayName)),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}

/// Widget to display a component's SVG icon.
class _ComponentIcon extends StatelessWidget {
  final String iconPath;
  final bool isAsset;
  final double size;

  const _ComponentIcon({
    required this.iconPath,
    required this.isAsset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (iconPath.isEmpty) {
      return Icon(
        Icons.memory,
        size: size * 0.6,
        color: Colors.grey,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: isAsset
          ? SvgPicture.asset(
              iconPath,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                Icons.memory,
                size: size * 0.6,
                color: Colors.grey,
              ),
            )
          : _buildFileIcon(),
    );
  }

  Widget _buildFileIcon() {
    if (iconPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(iconPath),
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Icon(
          Icons.memory,
          size: size * 0.6,
          color: Colors.grey,
        ),
      );
    }
    return Image.file(
      File(iconPath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.memory,
        size: size * 0.6,
        color: Colors.grey,
      ),
    );
  }
}
