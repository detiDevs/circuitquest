import 'package:circuitquest/ui/widgets/control_panel.dart';
import 'package:flutter/material.dart';

class ExpandableControlPanel extends StatefulWidget {
  const ExpandableControlPanel({super.key});

  @override
  State<ExpandableControlPanel> createState() => _ExpandableControlPanelState();
}

class _ExpandableControlPanelState extends State<ExpandableControlPanel> {
  bool _expanded = false;

  static const double collapsedHeight = 220;
  static const double expandedHeight = 500; // or MediaQuery-based

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

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
          const Expanded(
            child: SingleChildScrollView(
              child: ControlPanel(isSandbox: true),
            ),
          ),
        ],
      ),
    );
  }
}
