import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:circuitquest/ui/shared/widgets/rich_button.dart';
import 'dart:io';
import '../view_models/home_view_model.dart';
import 'home_logo.dart';

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
    final localizations = AppLocalizations.of(context)!;

    final buttons = [
      // Level Mode Button
      RichButton(
        title: localizations.levelModeTitle,
        description: localizations.levelModeDescription,
        icon: Icons.school,
        color: Colors.green,
        onPressed: () {
          _handleNavigation(context, viewModel.onLevelModeTap());
        },
      ),
      // Sandbox Mode Button
      RichButton(
        title: localizations.sandboxModeTitle,
        description: localizations.sandboxModeDescription,
        icon: Icons.construction,
        color: Colors.orange,
        onPressed: () {
          _handleNavigation(context, viewModel.onSandboxModeTap());
        },
      ),
      RichButton(
        title: localizations.settings,
        description: "",
        icon: Icons.settings,
        color: Colors.blue,
        onPressed: () {
          _handleNavigation(context, viewModel.onSettingsTap());
        },
      ),
      RichButton(
        title: localizations.leaveGame,
        description: "",
        icon: Icons.exit_to_app_sharp,
        color: Colors.red,
        onPressed: () {
          _handleNavigation(context, viewModel.onExitTap());
        },
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // App Logo
              const HomeLogo(),
              const SizedBox(height: 24),
              // App Title
              Text(
                Constants.kAppName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                localizations.appDescription,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Mode Selection Buttons
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: _buildButtonColumn(buttons),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Arranges the buttons in a single column.
  Widget _buildButtonColumn(List<Widget> buttons) {
    return Column(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          buttons[i],
        ],
      ],
    );
  }

  void _handleNavigation(BuildContext context, HomeNavigation navigation) {
    switch (navigation) {
      case HomeNavigation.levelMode:
        context.push('/level-selection');
      case HomeNavigation.sandboxMode:
        context.push('/sandbox');
      case HomeNavigation.settings:
        context.push('/settings');
      case HomeNavigation.exitApp:
        exit(0);
    }
  }
}
