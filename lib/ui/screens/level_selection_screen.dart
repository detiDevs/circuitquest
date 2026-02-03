import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/levels/levels.dart';
import '../../state/level_state.dart';
import 'level_screen.dart';

/// Screen for selecting a level to play.
///
/// Displays all available levels organized by their category blocks.
/// Users can tap on a level to start playing it.
class LevelSelectionScreen extends ConsumerStatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  ConsumerState<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends ConsumerState<LevelSelectionScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectALevel),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          // Testing button to toggle all levels unlock
          IconButton(
            icon: const Icon(Icons.lock_open),
            tooltip: 'Toggle unlock all levels (testing)',
            onPressed: () => _toggleAllLevelsUnlocked(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Future<void> _toggleAllLevelsUnlocked(BuildContext context) async {
    await toggleAllLevelsUnlocked(ref);
  }

  Widget _buildBody() {
    final levelBlocksAsync = ref.watch(levelBlocksProvider);

    return levelBlocksAsync.when(
      data: (levelBlocks) {
        if (levelBlocks.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noLevelsAvailable),
          );
        }

        return ListView.builder(
          itemCount: levelBlocks.length,
          itemBuilder: (context, index) {
            final category = levelBlocks.keys.elementAt(index);
            final levels = levelBlocks[category]!;
            return _LevelCategory(
              category: category,
              levels: levels,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context)!.failedToLoadLevels}: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(levelBlocksProvider);
              },
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displaying a category of levels.
class _LevelCategory extends StatelessWidget {
  final String category;
  final List<LevelBlockItem> levels;

  const _LevelCategory({
    required this.category,
    required this.levels,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        category,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text('${levels.length} levels'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final levelItem = levels[index];
              return _LevelCard(
                levelItem: levelItem,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Use 3 columns on wider screens (>= 600 dp), 2 columns on narrower screens
    return width >= 600 ? 3 : 2;
  }
}

/// Widget displaying a single level card.
class _LevelCard extends ConsumerWidget {
  final LevelBlockItem levelItem;

  const _LevelCard({
    required this.levelItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        if (levelItem.recommended)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.recommendedLevel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    // Level name
                    Text(
                      levelItem.name,
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
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 32,
                  ),
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
          MaterialPageRoute(
            builder: (context) => LevelScreen(level: level),
          ),
        );
        // No need to manually reload - Riverpod will handle the refresh
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToLoadLevel}: $e')),
        );
      }
    }
  }

  Color _getCardBorderColor(bool isCompleted, bool canAccess) {
    if (isCompleted) return Colors.green;
    if (levelItem.recommended) return Colors.orange;
    if (canAccess) return Colors.blue;
    return Colors.grey;
  }

  Color? _getCardBackgroundColor(bool isCompleted, bool canAccess) {
    if (isCompleted) return Colors.green[50];
    if (levelItem.recommended) return Colors.orange[50];
    if (canAccess) return Colors.blue[50];
    return Colors.grey[50];
  }
}
