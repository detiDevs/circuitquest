import 'package:flutter/material.dart';

class SandboxBottomAppBar extends StatelessWidget {
  const SandboxBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(tooltip: "Components", onPressed: () => print("Components"), icon: Icon(Icons.extension)),
          IconButton(tooltip: "Custom Components", onPressed: () => print("Custom Components"), icon: Icon(Icons.person)),
          IconButton(tooltip: "File Operations", onPressed: () => print("File operations"), icon: Icon(Icons.save)),
          IconButton(tooltip: "Controls", onPressed: () => print("Controls"), icon: Icon(Icons.tune)),
        ],
      )
    );
  }
}