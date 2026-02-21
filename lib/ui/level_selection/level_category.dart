import 'package:circuitquest/levels/levels.dart';
import 'package:flutter/material.dart';
import './level_card.dart';

/// Widget displaying a category of levels.
class LevelCategory extends StatelessWidget {
  final String category;
  final List<LevelBlockItem> levels;

  const LevelCategory({super.key, required this.category, required this.levels});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        category,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              return LevelCard(levelItem: levelItem);
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
