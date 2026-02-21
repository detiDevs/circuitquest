import 'package:flutter/material.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import './difficulty_badge.dart';

// Dialog displaying level information.
class LevelInfoDialog extends StatefulWidget {
  final Level level;

  const LevelInfoDialog({super.key, required this.level});

  @override
  State<LevelInfoDialog> createState() => LevelInfoDialogState();
}

class LevelInfoDialogState extends State<LevelInfoDialog> {
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
                DifficultyBadge(
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