import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:circuitquest/constants.dart';
import 'sandbox_screen.dart';
import 'level_selection_screen.dart';

/// Home screen for CircuitQuest.
///
/// Presents two main options:
/// - Level Mode: Play through structured circuit challenges
/// - Sandbox Mode: Free-form circuit design and experimentation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildAppLogo(),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Mode Selection Buttons
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    // Level Mode Button
                    _ModeButton(
                      title: AppLocalizations.of(context)!.levelModeTitle,
                      description: AppLocalizations.of(context)!.levelModeDescription,
                      icon: Icons.school,
                      color: Colors.green,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LevelSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Sandbox Mode Button
                    _ModeButton(
                      title: AppLocalizations.of(context)!.sandboxModeTitle,
                      description: AppLocalizations.of(context)!.sandboxModeDescription,
                      icon: Icons.construction,
                      color: Colors.orange,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SandboxScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _ModeButton(
                      title: AppLocalizations.of(context)!.settings,
                      description: "",
                      icon: Icons.settings,
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SettingsScreen())
                        );
                      },
                    )
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

  /// Builds the app logo with fallback handling.
  Widget _buildAppLogo() {
    return SizedBox(
      width: 150,
      height: 150,
      child: SvgPicture.asset(
        'assets/images/AppLogo.svg',
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.memory,
            size: 80,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }
}

/// A button for selecting a game mode.
class _ModeButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            color: color.withAlpha((0.1 * 255).toInt()),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 64,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
