import 'package:flutter/material.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import './difficulty_badge.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// Dialog displaying level information.
class LevelInfoDialog extends StatefulWidget {
  final Level level;

  const LevelInfoDialog({super.key, required this.level});

  @override
  State<LevelInfoDialog> createState() => LevelInfoDialogState();
}

class LevelInfoDialogState extends State<LevelInfoDialog> {
  bool _showHints = false;

  // Render plain text with inline LaTeX (dollar-delimited) using flutter_math_fork.
  // If no $ delimiters are present, returns a simple Text widget.
  Widget _renderMaybeMath(String s) {
    if (!s.contains(r'$')) {
      return Text(s, style: Theme.of(context).textTheme.bodySmall);
    }

    final regex = RegExp(r'(\$.*?\$)');
    final children = List<InlineSpan>.empty(growable: true);
    final mathParts = regex.allMatches(s).map((m) => m.group(0)!).toList();
    final nonMathParts = s.split(regex);

    for (int i = 0; i < nonMathParts.length; i++) {
      children.add(
        TextSpan(
          text: nonMathParts[i],
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
      if (i < mathParts.length) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              mathParts[i].substring(1, mathParts[i].length - 1),
              textStyle: Theme.of(context).textTheme.bodySmall,
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
          style: Theme.of(context).textTheme.bodySmall,
          children: children,
        ),
      ),
    );
  }

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
                widget.level.getLocalizedString('description', localeCode),
              ),
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
                          Expanded(child: _renderMaybeMath(entry.value)),
                        ],
                      ),
                    ),
                  ),

              // Hints
              if (widget.level
                  .getLocalizedStringList('hints', localeCode)
                  .isNotEmpty) ...[
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
                  ...widget.level
                      .getLocalizedStringList('hints', localeCode)
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
                                Expanded(child: _renderMaybeMath(hint)),
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
