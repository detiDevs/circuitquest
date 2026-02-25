import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:circuitquest/state/level_state.dart';
import 'package:circuitquest/ui/level_mode/level_screen.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget displaying a single level card.
class LevelCard extends ConsumerWidget {
  final LevelBlockItem levelItem;

  const LevelCard({super.key, required this.levelItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final localeCode = Localizations.localeOf(context).languageCode;
    final levelName = levelItem.getLocalizedName(localeCode);
    final isCompletedAsync = ref.watch(levelCompletedProvider(levelItem.id));
    final canAccessAsync = ref.watch(levelAccessProvider(levelItem.id));

    final isCompleted = isCompletedAsync.value ?? false;
    final canAccess = canAccessAsync.value ?? false;
    final isLoading = isCompletedAsync.isLoading || canAccessAsync.isLoading;

    return Material(
      child: InkWell(
        onTap: canAccess ? () => _accessLevel(context, ref) : null,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getCardBorderColor(isCompleted, canAccess),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _getCardBackgroundColor(isCompleted, canAccess),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges
                    Row(
                      children: [
                        
                        const Spacer(),
                        if (isCompleted)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (!canAccess && !isLoading)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: const Text(
                              'Locked',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Level number
                    Text(
                      'Level ${levelItem.id}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    // Level name
                    Text(
                      levelName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Disabled overlay for locked levels
            if (!canAccess && !isLoading)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _accessLevel(BuildContext context, WidgetRef ref) async {
    try {
      final loader = ref.read(levelLoaderProvider);
      final level = await loader.loadLevel(levelItem.id);
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LevelScreen(level: level)),
        );
        // No need to manually reload - Riverpod will handle the refresh
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          '${AppLocalizations.of(context)!.failedToLoadLevel}: $e',
        );
      }
    }
  }

  Color _getCardBorderColor(bool isCompleted, bool canAccess) {
    if (isCompleted) return Colors.green;
    if (canAccess) return Colors.blue;
    return Colors.grey;
  }

  Color? _getCardBackgroundColor(bool isCompleted, bool canAccess) {
    if (isCompleted) return Colors.green[50];
    if (canAccess) return Colors.blue[50];
    return Colors.grey[50];
  }
}
