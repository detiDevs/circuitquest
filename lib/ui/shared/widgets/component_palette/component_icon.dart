import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              fit: BoxFit.contain,
              placeholderBuilder: (context) =>
                  Icon(Icons.memory, size: size * 0.6, color: Colors.grey),
            )
          : _buildFileIcon(),
    );
  }

  Widget _buildFileIcon() {
    if (iconPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(iconPath),
        fit: BoxFit.contain,
        placeholderBuilder: (context) =>
            Icon(Icons.memory, size: size * 0.6, color: Colors.grey),
      );
    }
    return Image.file(
      File(iconPath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.memory, size: size * 0.6, color: Colors.grey),
    );
  }
}
