import 'package:circuitquest/ui/widgets/control_panel.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:flutter/material.dart';

class ExpandableControlPanel extends StatefulWidget {
  /// When true, shows sandbox-only controls like save/load circuit.
  final bool isSandbox;

  /// The current level being played (if in level mode).
  final Level? level;

  const ExpandableControlPanel({
    super.key,
    this.isSandbox = false,
    this.level,
  });

  @override
  State<ExpandableControlPanel> createState() => _ExpandableControlPanelState();
}

class _ExpandableControlPanelState extends State<ExpandableControlPanel> {
  bool _expanded = false;

  static const double collapsedHeight = 220;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: _expanded ? maxHeight : collapsedHeight,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // ─── Drag / Toggle Handle ──────────────────────────────
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // ─── Scrollable Control Panel ─────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: ControlPanel(
                isSandbox: widget.isSandbox,
                level: widget.level,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
