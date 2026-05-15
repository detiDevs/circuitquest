import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeNavigation {
  levelMode,
  sandboxMode,
  settings,
  exitApp,
}

class HomeViewModel {
  const HomeViewModel();

  HomeNavigation onLevelModeTap() => HomeNavigation.levelMode;

  HomeNavigation onSandboxModeTap() => HomeNavigation.sandboxMode;

  HomeNavigation onSettingsTap() => HomeNavigation.settings;

  HomeNavigation onExitTap() => HomeNavigation.exitApp;
}

final homeViewModelProvider = Provider<HomeViewModel>(
  (ref) => const HomeViewModel(),
);
