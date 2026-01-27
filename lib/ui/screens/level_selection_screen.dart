import 'package:circuitquest/l10n/app_localizations.dart';
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
        _errorMessage = '${AppLocalizations.of(context)!.failedToLoadLevels}: $e';
        _isLoading = false;
      });
    }
  }

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
    await _levelLoader.toggleAllLevelsUnlocked();
    // Clear all caches to force reload
    _levelLoader.clearCache();
    // Refresh all level cards
    setState(() {
      _levelBlocks = null;
      _isLoading = true;
    });
    _loadLevelBlocks();
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
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_levelBlocks == null || _levelBlocks!.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noLevelsAvailable),
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
                onLevelCompleted: () {},
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
class _LevelCard extends StatefulWidget {
  final LevelBlockItem levelItem;
  final LevelLoader levelLoader;
  final VoidCallback onLevelCompleted;

  const _LevelCard({
    required this.levelItem,
    required this.levelLoader,
    required this.onLevelCompleted,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _isCompleted = false;
  bool _canAccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccessStatus();
  }

  Future<void> _loadAccessStatus() async {
    if (!mounted) return;
    
    // Clear the loader cache to ensure fresh data
    widget.levelLoader.clearCache();
    
    final canAccess = await widget.levelLoader.canAccessLevel(widget.levelItem.id);
    final isCompleted = await widget.levelLoader.isLevelCompleted(widget.levelItem.id);
    
    if (mounted) {
      setState(() {
        _canAccess = canAccess;
        _isCompleted = isCompleted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: _canAccess ? () => _accessLevel(context) : null,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getCardBorderColor(),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _getCardBackgroundColor(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges
                    Row(
                      children: [
                        if (widget.levelItem.recommended)
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
                        if (_isCompleted)
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
                        if (!_canAccess && !_isLoading)
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
                      'Level ${widget.levelItem.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    // Level name
                    Text(
                      widget.levelItem.name,
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
            if (!_canAccess && !_isLoading)
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

  Future<void> _accessLevel(BuildContext context) async {
    try {
      final level = await widget.levelLoader.loadLevel(widget.levelItem.id);
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LevelScreen(level: level),
          ),
        );
        // Reload status when returning from the level
        // Clear cache to ensure fresh data is loaded
        widget.levelLoader.clearCache();
        _loadAccessStatus();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToLoadLevel}: $e')),
        );
      }
    }
  }

  Color _getCardBorderColor() {
    if (_isCompleted) return Colors.green;
    if (widget.levelItem.recommended) return Colors.orange;
    if (_canAccess) return Colors.blue;
    return Colors.grey;
  }

  Color? _getCardBackgroundColor() {
    if (_isCompleted) return Colors.green[50];
    if (widget.levelItem.recommended) return Colors.orange[50];
    if (_canAccess) return Colors.blue[50];
    return Colors.grey[50];
  }
}
