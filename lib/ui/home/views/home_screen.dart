import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/home/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/constants.dart';
import '../../sandbox_mode/sandbox_screen.dart';
import '../../level_selection/views/level_selection_screen.dart';
import 'package:circuitquest/ui/shared/widgets/rich_button.dart';
import 'dart:io';
import '../view_models/home_view_model.dart';
import '../widgets/home_logo.dart';

/// Home screen for CircuitQuest.
///
/// Presents two main options:
/// - Level Mode: Play through structured circuit challenges
/// - Sandbox Mode: Free-form circuit design and experimentation
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // App Logo
              const HomeLogo(),
              const SizedBox(height: 40),
              // App Title
              Text(
                Constants.kAppName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                AppLocalizations.of(context)!.appDescription,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Mode Selection Buttons
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    // Level Mode Button
                    RichButton(
                      title: AppLocalizations.of(context)!.levelModeTitle,
                      description: AppLocalizations.of(
                        context,
                      )!.levelModeDescription,
                      icon: Icons.school,
                      color: Colors.green,
                      onPressed: () {
                        _handleNavigation(
                          context,
                          viewModel.onLevelModeTap(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Sandbox Mode Button
                    RichButton(
                      title: AppLocalizations.of(context)!.sandboxModeTitle,
                      description: AppLocalizations.of(
                        context,
                      )!.sandboxModeDescription,
                      icon: Icons.construction,
                      color: Colors.orange,
                      onPressed: () {
                        _handleNavigation(
                          context,
                          viewModel.onSandboxModeTap(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    RichButton(
                      title: AppLocalizations.of(context)!.settings,
                      description: "",
                      icon: Icons.settings,
                      color: Colors.blue,
                      onPressed: () {
                        _handleNavigation(
                          context,
                          viewModel.onSettingsTap(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    RichButton(
                      title: "Leave Game",
                      description: "",
                      icon: Icons.exit_to_app_sharp,
                      color: Colors.red,
                      onPressed: () {
                        _handleNavigation(context, viewModel.onExitTap());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, HomeNavigation navigation) {
    switch (navigation) {
      case HomeNavigation.levelMode:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LevelSelectionScreen(),
          ),
        );
      case HomeNavigation.sandboxMode:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SandboxScreen(),
          ),
        );
      case HomeNavigation.settings:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
      case HomeNavigation.exitApp:
        exit(0);
    }
  }

}
