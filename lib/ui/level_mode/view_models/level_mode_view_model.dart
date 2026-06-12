import 'package:circuitquest/data/repositories/level_repository_impl.dart';
import 'package:circuitquest/domain/models/level.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LevelModeViewModel {
  LevelModeViewModel(this._ref);

  final Ref _ref;
  late Level level;

  Future<Level> loadLevel(int levelId) async {
    final levelRepository = _ref.read(levelRepositoryProvider);
    level = await levelRepository.loadLevel(levelId);
    return level;
  }
}

final levelModeViewModelProvider = Provider<LevelModeViewModel>(
  (ref) => LevelModeViewModel(ref)
);
