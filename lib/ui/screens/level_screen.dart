import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:circuitquest/constants.dart';
import '../widgets/component_palette.dart';
import '../widgets/circuit_canvas.dart';
import '../widgets/control_panel.dart';
import '../../state/sandbox_state.dart';

/// Screen for playing a specific level.
///
/// This screen displays:
/// - Level information (title, description, objectives)
/// - Circuit canvas with grid
/// - Limited component palette (only components available for the level)
/// - Control panel for simulation
/// - Level test cases and hints
class LevelScreen extends ConsumerWidget {
  final Level level;

  const LevelScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Constants.kAppName} - ${level.name}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: const _LevelScreenBody(),
    );
  }
}

/// Main body of the level screen with responsive layout.
class _LevelScreenBody extends ConsumerWidget {
  const _LevelScreenBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current level from the router or params
    // For now, we'll access it through the widget above
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 1200;

        if (isWideScreen) {
          // Desktop layout: Info panel, Canvas, Palette, Controls
          return Row(
            children: [
              // Left: Level Info Panel
              SizedBox(
                width: 300,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: const _LevelInfoPanel(),
                ),
              ),
              // Center-left: Component Palette
              SizedBox(
                width: 180,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: const _LimitedComponentPalette(),
                ),
              ),
              // Center: Circuit Canvas
              Expanded(
                child: CircuitCanvas(level: _getCurrentLevel(context)),
              ),
              // Right: Control Panel
              SizedBox(
                width: 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: ControlPanel(level: _getCurrentLevel(context)),
                ),
              ),
            ],
          );
        } else {
          // Mobile/Tablet layout: Vertical arrangement
          return SingleChildScrollView(
            child: Column(
              children: [
                // Level Info Section
                Container(
                  color: Colors.grey[100],
                  child: const _LevelInfoPanel(),
                ),
                // Component Palette (collapsible)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: ExpansionTile(
                    title: Text(AppLocalizations.of(context)!.availableComponents),
                    initiallyExpanded: false,
                    children: const [
                      SizedBox(
                        height: 200,
                        child: _LimitedComponentPalette(),
                      ),
                    ],
                  ),
                ),
                // Canvas
                Container(
                  constraints: const BoxConstraints(minHeight: 400),
                  color: Colors.white,
                  child: CircuitCanvas(level: _getCurrentLevel(context)),
                ),
                // Control Panel (collapsible)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: ExpansionTile(
                    title: Text(AppLocalizations.of(context)!.controlsTitle),
                    initiallyExpanded: false,
                    children: [
                      SizedBox(
                        child: ControlPanel(level: _getCurrentLevel(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Panel displaying level information.
class _LevelInfoPanel extends ConsumerStatefulWidget {
  const _LevelInfoPanel();

  @override
  ConsumerState<_LevelInfoPanel> createState() => _LevelInfoPanelState();
}

class _LevelInfoPanelState extends ConsumerState<_LevelInfoPanel> {
  bool _showHints = false;

  @override
  Widget build(BuildContext context) {
    // We need to pass the level through ModalRoute or similar
    // For now, we'll create a helper method to get it
    final level = _getCurrentLevel(context);

    if (level == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Title and Difficulty
            Text(
              level.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _DifficultyBadge(difficulty: level.difficulty),
            const SizedBox(height: 16),

            // Description
            Text(
              AppLocalizations.of(context)!.levelDescription,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              level.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Objectives
            Text(
              AppLocalizations.of(context)!.levelObjectives,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...level.objectives.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hints
            if (level.hints.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.levelHints,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showHints = !_showHints;
                      });
                    },
                    child: Text(_showHints ? 'Hide hints' : 'Show hints'),
                  ),
                ],
              ),
              if (_showHints) ...[
                const SizedBox(height: 8),
                ...level.hints.map(
                  (hint) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        border: Border.all(color: Colors.yellow[200]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: Colors.yellow[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hint,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget displaying the difficulty level with color coding.
class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor();
    final icon = _getDifficultyIcon();

    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).toInt()),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            difficulty,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_very_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }
}

/// Component palette limited to components available for this level.
class _LimitedComponentPalette extends ConsumerWidget {
  const _LimitedComponentPalette();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = _getCurrentLevel(context);

    if (level == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Filter available components based on level requirements
    final limitedComponents = availableComponents.where((comp) {
      return level.availableComponents.any((ac) => ac.type == comp.name);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            AppLocalizations.of(context)!.availableComponents,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: limitedComponents.length,
            itemBuilder: (context, index) {
              final componentType = limitedComponents[index];
              return _PaletteItem(componentType: componentType);
            },
          ),
        ),
      ],
    );
  }
}

/// Individual palette item that can be dragged (reused from sandbox).
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
            iconPath: componentType.iconPath,
            isAsset: componentType.isAsset,
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
          iconPath: componentType.iconPath,
          isAsset: componentType.isAsset,
          size: 40,
        ),
        title: Text(
          componentType.displayName,
          style: const TextStyle(fontSize: 11),
        ),
        onTap: () {
          ref.read(sandboxProvider).selectComponentType(componentType.name);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.selected}: ${componentType.displayName}'),
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
      child: SvgPicture.asset(
        iconPath,
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

/// Helper function to get the current level from the widget tree.
Level? _getCurrentLevel(BuildContext context) {
  // Try to get the level from LevelScreen
  try {
    final widget = context.findAncestorWidgetOfExactType<LevelScreen>();
    return widget?.level;
  } catch (e) {
    return null;
  }
}
