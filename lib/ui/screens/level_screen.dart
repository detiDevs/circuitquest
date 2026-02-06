import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/widgets/expandable_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:circuitquest/constants.dart';
import '../widgets/component_palette.dart';
import '../widgets/circuit_canvas.dart';
import '../widgets/control_panel.dart';

/// Screen for playing a specific level.
///
/// This screen displays:
/// - Circuit canvas with grid
/// - Limited component palette (only components available for the level)
/// - Control panel for simulation
/// - Level info accessible via dialog and FAB
class LevelScreen extends ConsumerStatefulWidget {
  final Level level;

  const LevelScreen({super.key, required this.level});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    // Show level info dialog on first entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogShown && mounted) {
        _showLevelInfoDialog();
        _dialogShown = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Constants.kAppName} - ${widget.level.name}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _LevelScreenBody(level: widget.level),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLevelInfoDialog,
        tooltip: AppLocalizations.of(context)!.levelInformationTooltip,
        child: const Icon(Icons.info),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void _showLevelInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => _LevelInfoDialog(level: widget.level),
    );
  }
}

/// Main body of the level screen with responsive layout.
class _LevelScreenBody extends StatelessWidget {
  final Level level;

  const _LevelScreenBody({required this.level});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          // Desktop layout: Palette on left, Canvas in center, Controls on right
          return Row(
            children: [
              // Left panel: Component Palette
              SizedBox(
                width: 200,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: _LimitedComponentPalette(level: level),
                ),
              ),
              // Center: Circuit Canvas
              Expanded(
                child: CircuitCanvas(level: level),
              ),
              // Right panel: Control Panel
              SizedBox(
                width: 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: ControlPanel(level: level),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout: Vertical stack with collapsible sections
          return Column(
            children: [
              // Collapsible palette at top
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: ExpansionTile(
                  title: Text(AppLocalizations.of(context)!.availableComponents),
                  controlAffinity: ListTileControlAffinity.leading,
                  initiallyExpanded: false,
                  children: [
                    SizedBox(
                      height: 200,
                      child: _LimitedComponentPalette(level: level),
                    ),
                  ],
                ),
              ),
              // Canvas takes remaining space
              Expanded(
                child: CircuitCanvas(level: level),
              ),
              // Control panel at bottom
              ExpandableControlPanel(level: level),
            ],
          );
        }
      },
    );
  }
}

/// Dialog displaying level information.
class _LevelInfoDialog extends StatefulWidget {
  final Level level;

  const _LevelInfoDialog({required this.level});

  @override
  State<_LevelInfoDialog> createState() => _LevelInfoDialogState();
}

class _LevelInfoDialogState extends State<_LevelInfoDialog> {
  bool _showHints = false;

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.level.getLocalizedString('name', localeCode)),
                const SizedBox(height: 8),
                _DifficultyBadge(
                  difficulty: widget.level.getLocalizedString('difficulty', localeCode),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Description
            Text(
              AppLocalizations.of(context)!.levelDescription,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.level.getLocalizedString('description', localeCode),
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
            ...widget.level.getLocalizedStringList('objectives', localeCode).asMap().entries.map(
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

            // Hints
            if (widget.level.getLocalizedStringList('hints', localeCode).isNotEmpty) ...[
              const SizedBox(height: 16),
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
                    child: Text(
                      _showHints
                          ? AppLocalizations.of(context)!.hide
                          : AppLocalizations.of(context)!.show,
                    ),
                  ),
                ],
              ),
              if (_showHints) ...[
                const SizedBox(height: 8),
                ...widget.level.getLocalizedStringList('hints', localeCode).map(
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
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
  final Level level;

  const _LimitedComponentPalette({required this.level});

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
