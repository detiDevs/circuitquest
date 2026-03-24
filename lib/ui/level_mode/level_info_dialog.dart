import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/level_state.dart';
import './difficulty_badge.dart';

// Dialog displaying level information.
class LevelInfoDialog extends ConsumerWidget {
  final Level level;

  const LevelInfoDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text(level.getLocalizedString('name', localeCode)),
                const SizedBox(height: 8),
                DifficultyBadge(
                  difficulty: level.getLocalizedString(
                    'difficulty',
                    localeCode,
                  ),
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              level.getLocalizedString('description', localeCode),
              style: Theme.of(context).textTheme.bodySmall,
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
            ...level
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
                      onPressed: () =>
                          revealNextLevelHint(ref, level.levelId, hints.length),
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
                                child: Text(
                                  hint,
                                  style: TextStyle(color: Colors.black),
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
