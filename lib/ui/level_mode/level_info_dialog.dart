import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/level_state.dart';
import './difficulty_badge.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// Dialog displaying level information.
class LevelInfoDialog extends ConsumerStatefulWidget {
  final Level level;

  const LevelInfoDialog({super.key, required this.level});

  @override
  ConsumerState<LevelInfoDialog> createState() => LevelInfoDialogState();
}

class LevelInfoDialogState extends ConsumerState<LevelInfoDialog> {
  // ignore: unused_field
  bool _showHints = false;

  // Render plain text with inline LaTeX (dollar-delimited) using flutter_math_fork.
  // If no $ delimiters are present, returns a simple Text widget.
  Widget _renderMaybeMath(String s, TextStyle? initialTheme) {
    final theme = initialTheme ?? Theme.of(context).textTheme.bodySmall;
    if (!s.contains(r'$')) {
      return Text(s, style: theme);
    }

    final regex = RegExp(r'(\$.*?\$)');
    final children = List<InlineSpan>.empty(growable: true);
    final mathParts = regex.allMatches(s).map((m) => m.group(0)!).toList();
    final nonMathParts = s.split(regex);

    for (int i = 0; i < nonMathParts.length; i++) {
      children.add(
        TextSpan(
          text: nonMathParts[i],
          style: theme,
        ),
      );
      if (i < mathParts.length) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              mathParts[i].substring(1, mathParts[i].length - 1),
              textStyle: theme,
              onErrorFallback: (err) => Text(
                'Error rendering math: $err',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          style: theme,
          children: children,
        ),
      ),
    );
  }

  

  /// Render the truth table using flutter_math_fork. Provides an onError
  /// fallback to show a readable error message.
  Widget _renderTruthTable(List<List<dynamic>> table, TextStyle? textStyle) {
    // Render the truth table using Flutter's Table widget so we can control
    // the border color (e.g. white lines in dark mode).
    if (table.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.grey.shade300;

    final headerStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : (textStyle?.color ?? theme.textTheme.bodyMedium?.color),
    );
    final cellStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      color: isDark ? Colors.white : (textStyle?.color ?? theme.textTheme.bodyMedium?.color),
    );

    // Build table rows
    final rows = <TableRow>[];
    for (int r = 0; r < table.length; r++) {
      final row = table[r];
      final isHeader = r == 0;
      rows.add(TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: row.map<Widget>((cell) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.center,
            child: Text(
              cell == null ? '' : cell.toString(),
              style: isHeader ? headerStyle : cellStyle,
            ),
          );
        }).toList(),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: borderColor, width: 1),
          children: rows,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
  final List<List<dynamic>>? truthTable = level.truthTable;
    final localeCode = Localizations.localeOf(context).languageCode;
    final hints = level.getLocalizedStringList('hints', localeCode);
    final revealedHints = ref.watch(
      levelRevealedHintsCountProvider(level.levelId),
    );
    final visibleHintCount = revealedHints.clamp(0, hints.length).toInt();
    final canRevealMoreHints = visibleHintCount < hints.length;

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
                DifficultyBadge(
                  difficulty: widget.level.getLocalizedString(
                    'difficulty',
                    localeCode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Description
              Text(
                AppLocalizations.of(context)!.levelDescription,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _renderMaybeMath(
                widget.level.getLocalizedString('description', localeCode), null
              ),
              if (truthTable != null) ...[
                const SizedBox(height: 12),
                _renderTruthTable(truthTable, Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),

              // Objectives
              Text(
                AppLocalizations.of(context)!.levelObjectives,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.level
                  .getLocalizedStringList('objectives', localeCode)
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1}. ',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: _renderMaybeMath(
                              entry.value, null 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              // Hints
              if (hints.isNotEmpty) ...[
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
                    if (canRevealMoreHints)
                      TextButton(
                        onPressed: () => revealNextLevelHint(
                          ref,
                          level.levelId,
                          hints.length,
                        ),
                        child: Text(
                          visibleHintCount == 0
                              ? AppLocalizations.of(context)!.showAHint
                              : AppLocalizations.of(context)!.showNextHint,
                        ),
                      ),
                  ],
                ),
                if (visibleHintCount > 0) ...[
                  const SizedBox(height: 8),
                  ...hints
                      .take(visibleHintCount)
                      .map(
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
                                  child: _renderMaybeMath(
                                    hint,
                                    TextStyle(color: Colors.black)
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
