import 'package:circuitquest/levels/levels.dart';
import 'package:flutter/material.dart';
import './level_card.dart';
import '../../state/level_state.dart';

/// Widget displaying a category of levels.
class LevelCategoryWidget extends StatelessWidget {
  final LevelCategory category;

  const LevelCategoryWidget({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final categoryName = category.getLocalizedName(localeCode);
    final levels = category.levels;

    return ExpansionTile(
      title: Text(
        categoryName,
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
