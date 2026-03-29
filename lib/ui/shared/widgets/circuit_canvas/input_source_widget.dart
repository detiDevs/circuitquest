import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/components/input_source.dart';
import '../../../../state/sandbox_state.dart';
import '../../utils/snackbar_utils.dart';

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

  /// Triggers event-driven evaluation when input value changes
  void _triggerEvaluation() {
    final sandboxState = ref.read(sandboxProvider);
    sandboxState.evaluateFromComponent(widget.inputComponent);
  }

  @override
  Widget build(BuildContext context) {
    final outputPin = widget.inputComponent.outputs['outValue']!;
    final bitWidth = outputPin.bitWidth;
    final currentValue = outputPin.value;
    final isImmutable = widget.placedComponent.immutable;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.placedComponent.label != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    widget.placedComponent.label!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              // Bitwidth toggle button
              Tooltip(
                message: AppLocalizations.of(context)!.toggleBitwidth,
                child: GestureDetector(
                  onTap: isImmutable
                      ? null
                      : () {
                          if (outputPin.connections.isNotEmpty) {
                            SnackBarUtils.showError(
                              context,
                              AppLocalizations.of(context)!.cantChangeBitwidth,
                            );
                            return;
                          }
                          int newBitWidth;
                          if (bitWidth == 1) {
                            newBitWidth = 8;
                          } else if (bitWidth == 8) {
                            newBitWidth = 32;
                          } else {
                            newBitWidth = 1;
                          }
                          widget.inputComponent.bitWidth = newBitWidth;

                          // Trigger evaluation after bitwidth change
                          _triggerEvaluation();

                          setState(() {
                            _controller.text = currentValue.toString();
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isImmutable ? Colors.grey[300] : Colors.blue[100],
                      border: Border.all(
                        color: isImmutable
                            ? Colors.grey[600]!
                            : Colors.blue[700]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.bitwidthLabel(bitWidth),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isImmutable
                            ? Colors.grey[700]
                            : Colors.blue[700],
                      ),
                    ),
                  ),
                ),
              ),
              // Value input
              if (bitWidth == 1)
                // Toggle button for 1-bit
                GestureDetector(
                  onTap: isImmutable
                      ? null
                      : () {
                          widget.inputComponent.value = currentValue == 0
                              ? 1
                              : 0;

                          // Trigger evaluation after value change
                          _triggerEvaluation();

                          setState(() {
                            _controller.text = (currentValue == 0 ? 1 : 0)
                                .toString();
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isImmutable
                          ? Colors.grey[400]
                          : (currentValue == 0 ? Colors.red : Colors.green),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      currentValue == 0 ? '0' : '1',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isImmutable ? Colors.black87 : Colors.white,
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
                    enabled: !isImmutable,
                    readOnly: isImmutable,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      filled: isImmutable,
                      fillColor: isImmutable ? Colors.grey[200] : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: isImmutable ? Colors.grey[700] : null,
                    ),
                    onChanged: isImmutable
                        ? null
                        : (value) {
                            final intValue = int.tryParse(value) ?? 0;
                            widget.inputComponent.value = intValue;

                            // Trigger evaluation after value change
                            _triggerEvaluation();

                            // Update display only if the value was out of range
                            if (widget.inputComponent.value != intValue) {
                              _controller.text = widget.inputComponent.value.toString();
                              _controller
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: widget.inputComponent.value.toString().length,
                                ),
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
          left: widget.gridSize - 20,
          top: widget.gridSize / 2 - 10,
          child: GestureDetector(
            onTap: () {
              widget.ref
                  .read(sandboxProvider)
                  .startWireDrawing(widget.placedComponent.id, 'outValue');
            },
            child: Container(
              width: 20,
              height: 20,
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
