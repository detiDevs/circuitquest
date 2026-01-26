import 'package:flutter/material.dart';
import 'package:circuitquest/levels/levels.dart';
import 'level_screen.dart';

/// Screen for selecting a level to play.
///
/// Displays all available levels organized by their category blocks.
/// Users can tap on a level to start playing it.
class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late LevelLoader _levelLoader;
  Map<String, List<LevelBlockItem>>? _levelBlocks;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _levelLoader = LevelLoader();
    _loadLevelBlocks();
  }

  Future<void> _loadLevelBlocks() async {
    try {
      final blocks = await _levelLoader.loadLevelBlocks();
      setState(() {
        _levelBlocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load levels: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Level'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadLevelBlocks();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_levelBlocks == null || _levelBlocks!.isEmpty) {
      return const Center(
        child: Text('No levels available'),
      );
    }

    return ListView.builder(
      itemCount: _levelBlocks!.length,
      itemBuilder: (context, index) {
        final category = _levelBlocks!.keys.elementAt(index);
        final levels = _levelBlocks![category]!;
        return _LevelCategory(
          category: category,
          levels: levels,
          levelLoader: _levelLoader,
        );
      },
    );
  }
}

/// Widget displaying a category of levels.
class _LevelCategory extends StatelessWidget {
  final String category;
  final List<LevelBlockItem> levels;
  final LevelLoader levelLoader;

  const _LevelCategory({
    required this.category,
    required this.levels,
    required this.levelLoader,
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final levelItem = levels[index];
              return _LevelCard(
                levelItem: levelItem,
                levelLoader: levelLoader,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Widget displaying a single level card.
class _LevelCard extends StatelessWidget {
  final LevelBlockItem levelItem;
  final LevelLoader levelLoader;

  const _LevelCard({
    required this.levelItem,
    required this.levelLoader,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () async {
          try {
            final level = await levelLoader.loadLevel(levelItem.id);
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LevelScreen(level: level),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load level: $e')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: levelItem.recommended ? Colors.orange : Colors.grey[300]!,
              width: levelItem.recommended ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: levelItem.recommended
                ? Colors.orange[50]
                : Colors.grey[50],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommended badge
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
                    child: const Text(
                      'Recommended',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
      ),
    );
  }
}
