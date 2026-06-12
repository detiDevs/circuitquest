import 'package:circuitquest/ui/home/widgets/home_screen.dart';
import 'package:circuitquest/ui/level_mode/widgets/level_screen.dart';
import 'package:circuitquest/ui/level_selection/widgets/level_selection_screen.dart';
import 'package:circuitquest/ui/sandbox_mode/widgets/sandbox_screen.dart';
import 'package:circuitquest/ui/settings/view_models/settings_view_model.dart';
import 'package:circuitquest/ui/settings/widgets/settings_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const home = '/';
  static const settings = '/settings';
  static const levelSelection = '/level-selection';
  static const level = '/level/:levelId';
  static const sandboxMode = '/sandbox';
}

GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (context, state) => HomeScreen()),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) {
        final viewModel = SettingsViewModel();
        return SettingsScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.levelSelection,
      builder: (context, state) => LevelSelectionScreen(),
    ),
    GoRoute(
      path: Routes.level,
      builder: (context, state) => LevelScreen(
        levelId: int.parse(state.pathParameters['levelId'] ?? '0'),
      ),
    ),
    GoRoute(
      path: Routes.sandboxMode,
      builder: (context, state) => SandboxScreen(),
    ),
  ],
);
