import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// dart:io is only available on non-web platforms
import 'package:circuitquest/ui/shared/utils/platform_file_utils.dart';

/// Widget to display a component's SVG icon.
class ComponentIcon extends StatelessWidget {
  final String iconPath;
  final bool isAsset;
  final double size;

  const ComponentIcon({
    super.key,
    required this.iconPath,
    required this.isAsset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (iconPath.isEmpty) {
      return Icon(Icons.memory, size: size * 0.6, color: Colors.grey);
    }

    return SizedBox(
      width: size,
      height: size,
      child: isAsset
          ? SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
              placeholderBuilder: (context) =>
                  Icon(Icons.memory, size: size * 0.6, color: Colors.grey),
            )
          : _buildFileIcon(context),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    if (iconPath.toLowerCase().endsWith('.svg')) {
      return buildSvgFromFilePath(
        path: iconPath,
        size: size,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
        placeholderBuilder: (context) =>
            Icon(Icons.memory, size: size * 0.6, color: Colors.grey),
      );
    }
    return buildImageFromFilePath(
      path: iconPath,
      size: size,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.memory, size: size * 0.6, color: Colors.grey),
    );
  }
}
