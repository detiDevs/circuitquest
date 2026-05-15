import 'package:circuitquest/data/repositories/level_repository_impl.dart';
import 'package:circuitquest/domain/models/level.dart';
import 'package:circuitquest/ui/shared/providers/level_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LevelSelectionViewModel {
  LevelSelectionViewModel(this._ref);

  final Ref _ref;

  AsyncValue<List<LevelCategory>> get categories =>
      _ref.watch(levelCategoriesProvider);

  void refresh() {
    _ref.invalidate(levelCategoriesProvider);
  }

  Future<void> toggleAllLevelsUnlocked() async {
    final repository = _ref.read(levelRepositoryProvider);
    await repository.toggleAllLevelsUnlocked();
    _ref.invalidate(levelMetaProvider);
    _ref.invalidate(levelAccessProvider);
  }
}

final levelSelectionViewModelProvider = Provider<LevelSelectionViewModel>(
  (ref) => LevelSelectionViewModel(ref),
);
