import 'package:circuitquest/ui/level_mode/level_screen.dart';
import 'package:flutter/material.dart';

class LevelBottomAppBar extends StatelessWidget {
  // Function showComponents;
  // Function startSimulation;
  Function showLevelInfo;
  // Function showControls;
  
  LevelBottomAppBar({super.key, required this.showLevelInfo});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        children: [
          IconButton(tooltip: "Components", onPressed: () => print("Components"), icon: Icon(Icons.extension)),
          Spacer(),
          IconButton(tooltip: "Start simulation", onPressed: () => print("Start simulation"), icon: Icon(Icons.check)),
          Spacer(),
          IconButton(tooltip: "Level Info", onPressed: () => showLevelInfo(), icon: Icon(Icons.info)),
          Spacer(),
          IconButton(tooltip: "Controls", onPressed: () => print("Controls"), icon: Icon(Icons.tune)),
        ],
      )
    );
  }
}