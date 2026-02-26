import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/components/output_probe.dart';
import '../../../../state/sandbox_state.dart';
import '../../utils/snackbar_utils.dart';

/// UI for output probe components: shows bitwidth and current value, with input pin on the left.
class OutputProbeWidget extends ConsumerWidget {
  final OutputProbe outputComponent;
  final PlacedComponent placedComponent;
  final WidgetRef ref;
  final double gridSize;

  const OutputProbeWidget({
    super.key,
    required this.outputComponent,
    required this.placedComponent,
    required this.ref,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sandboxProvider);
    final inputPin = outputComponent.inputs['input']!;
    final bitWidth = outputComponent.bitWidth;
    final value = outputComponent.value;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 4, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(placedComponent.label != null) Container(
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
                  placedComponent.label!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
              // Label for the current bitwidth of the output
              Text(
                '$bitWidth-Bit',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                // Text field for the output value
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Input pin on the left edge
        Positioned(
          left: 0,
          top: gridSize / 2 - 6,
          child: GestureDetector(
            onTap: () {
              if (state.wireDrawingStart != null) {
                state.completeWireDrawing(
                  placedComponent.id, 
                  'input',
                  onError: (message) => SnackBarUtils.showError(context, message),
                );
                return;
              }

              // If already connected, delete the connection by tapping the input pin
              final existing = state.connections.where(
                (c) => c.targetComponentId == placedComponent.id && c.targetPin == 'input',
              );
              if (existing.isNotEmpty) {
                state.removeConnection(existing.first);
              }
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: inputPin.value > 0 ? Colors.green : Colors.red,
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
