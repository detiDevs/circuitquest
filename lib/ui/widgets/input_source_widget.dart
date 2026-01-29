import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/components/input_source.dart';
import '../../state/sandbox_state.dart';

/// A stateful widget to manage input source controls properly.
class InputSourceWidget extends ConsumerStatefulWidget {
  final InputSource inputComponent;
  final PlacedComponent placedComponent;
  final WidgetRef ref;
  final double gridSize;

  const InputSourceWidget({
    required this.inputComponent,
    required this.placedComponent,
    required this.ref,
    required this.gridSize,
  });

  @override
  ConsumerState<InputSourceWidget> createState() => _InputSourceWidgetState();
}

class _InputSourceWidgetState extends ConsumerState<InputSourceWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final outputPin = widget.inputComponent.outputs['outValue']!;
    _controller = TextEditingController(text: outputPin.value.toString());
  }

  @override
  void didUpdateWidget(InputSourceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inputComponent != widget.inputComponent) {
      _controller.dispose();
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outputPin = widget.inputComponent.outputs['outValue']!;
    final bitWidth = outputPin.bitWidth;
    final maxValue = (1 << bitWidth) - 1;
    final currentValue = outputPin.value;

    // Update controller if value changed externally
    if (_controller.text != currentValue.toString()) {
      _controller.text = currentValue.toString();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          // Bitwidth toggle button
          Tooltip(
            message: AppLocalizations.of(context)!.toggleBitwidth,
            child: GestureDetector(
              onTap: () {
                int newBitWidth;
                if (bitWidth == 1) {
                  newBitWidth = 8;
                } else if (bitWidth == 8) {
                  newBitWidth = 32;
                } else {
                  newBitWidth = 1;
                }
                // Create new output pin with new bitwidth
                widget.inputComponent.outputs['outValue'] =
                  widget.inputComponent.outputs['outValue']!.copyWith(newBitWidth);

                setState(() {
                  _controller.text = currentValue.toString();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  border: Border.all(color: Colors.blue[700]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppLocalizations.of(context)!.bitwidthLabel(bitWidth),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
          ),
          // Value input
          if (bitWidth == 1)
            // Toggle button for 1-bit
            GestureDetector(
              onTap: () {
                widget.inputComponent.setValue(currentValue == 0 ? 1 : 0);
                setState(() {
                  _controller.text = (currentValue == 0 ? 1 : 0).toString();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: currentValue == 0 ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentValue == 0 ? '0' : '1',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            // Text field for 8/32-bit
            SizedBox(
              width: widget.gridSize - 8,
              height: 24,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                style: const TextStyle(fontSize: 11),
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;
                  final constrainedValue = intValue.clamp(0, maxValue);
                  widget.inputComponent.setValue(constrainedValue);

                  // Update display only if the value was out of range
                  if (constrainedValue != intValue) {
                    _controller.text = constrainedValue.toString();
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: constrainedValue.toString().length),
                    );
                  }
                },
              ),
            ),
            ],
          ),
        ),
        // Output pin on the right edge
        Positioned(
          left: widget.gridSize - 6,
          top: widget.gridSize / 2 - 6,
          child: GestureDetector(
            onTap: () {
              widget.ref
                  .read(sandboxProvider)
                  .startWireDrawing(widget.placedComponent.id, 'output');
            },
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: outputPin.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
