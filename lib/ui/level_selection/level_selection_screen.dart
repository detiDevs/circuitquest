import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/level_selection/level_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/level_state.dart';

/// Screen for selecting a level to play.
///
/// Displays all available levels organized by their category blocks.
/// Users can tap on a level to start playing it.
class LevelSelectionScreen extends ConsumerStatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  ConsumerState<LevelSelectionScreen> createState() =>
      _LevelSelectionScreenState();
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
            return LevelCategory(category: category, levels: levels);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
