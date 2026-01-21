import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/gates/and_gate.dart';
import '../../core/components/gates/or_gate.dart';
import '../../core/components/gates/not_gate.dart';
import '../../core/components/gates/nand_gate.dart';
import '../../core/components/gates/nor_gate.dart';
import '../../core/components/gates/xor_gate.dart';
import '../../core/components/sequential/clock.dart';
import '../../core/components/sequential/d_latch.dart';
import '../../core/components/sequential/d_flip_flop.dart';
import '../../core/components/base/component.dart';
import '../../state/sandbox_state.dart';

/// A draggable component type in the palette.
class ComponentType {
  final String name;
  final String displayName;
  final String svgAsset;
  final Component Function() createComponent;

  const ComponentType({
    required this.name,
    required this.displayName,
    required this.svgAsset,
    required this.createComponent,
  });
}

/// Available component types in the palette.
final List<ComponentType> availableComponents = [
  // Basic gates
  ComponentType(
    name: 'And',
    displayName: 'AND Gate',
    svgAsset: 'assets/gates/And.svg',
    createComponent: () => AndGate(),
  ),
  ComponentType(
    name: 'Or',
    displayName: 'OR Gate',
    svgAsset: 'assets/gates/Or.svg',
    createComponent: () => OrGate(),
  ),
  ComponentType(
    name: 'Not',
    displayName: 'NOT Gate',
    svgAsset: 'assets/gates/Not.svg',
    createComponent: () => NotGate(),
  ),
  ComponentType(
    name: 'Nand',
    displayName: 'NAND Gate',
    svgAsset: 'assets/gates/Nand.svg',
    createComponent: () => NandGate(),
  ),
  ComponentType(
    name: 'Nor',
    displayName: 'NOR Gate',
    svgAsset: 'assets/gates/Nor.svg',
    createComponent: () => NorGate(),
  ),
  ComponentType(
    name: 'Xor',
    displayName: 'XOR Gate',
    svgAsset: 'assets/gates/Xor.svg',
    createComponent: () => XorGate(),
  ),
  // Sequential components
  ComponentType(
    name: 'Clock',
    displayName: 'Clock',
    svgAsset: 'assets/gates/Register.svg', // Reuse register icon for now
    createComponent: () => Clock(),
  ),
  ComponentType(
    name: 'DLatch',
    displayName: 'D-Latch',
    svgAsset: 'assets/gates/DLatch.svg',
    createComponent: () => DLatch(),
  ),
  ComponentType(
    name: 'DFlipFlop',
    displayName: 'D-Flip-Flop',
    svgAsset: 'assets/gates/Register.svg',
    createComponent: () => DFlipFlop(),
  ),
  ComponentType(name: "InputSource", displayName: "Input", svgAsset: 'assets/gates/Input.svg', createComponent: () => InputSource()),
  ComponentType(name: "OutputProbe", displayName: "Output", svgAsset: 'assets/gates/Output.svg', createComponent: () => OutputProbe()),
];

/// Component palette widget showing available components.
///
/// Users can drag components from the palette onto the canvas.
class ComponentPalette extends ConsumerWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: ListView.builder(
            itemCount: availableComponents.length,
            itemBuilder: (context, index) {
              final componentType = availableComponents[index];
              return _PaletteItem(componentType: componentType);
            },
          ),
        ),
      ],
    );
  }
}

/// Individual palette item that can be dragged.
class _PaletteItem extends ConsumerWidget {
  final ComponentType componentType;

  const _PaletteItem({required this.componentType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            svgAsset: componentType.svgAsset,
            size: 60,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildChild(context, ref),
      ),
      child: _buildChild(context, ref),
    );
  }

  Widget _buildChild(BuildContext context, WidgetRef ref) {
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
          svgAsset: componentType.svgAsset,
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
  final String svgAsset;
  final double size;

  const _ComponentIcon({
    required this.svgAsset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        svgAsset,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Icon(
          Icons.memory,
          size: size * 0.6,
          color: Colors.grey,
        ),
      ),
    );
  }
}
