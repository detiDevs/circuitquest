import 'package:circuitquest/core/commands/command_controller.dart';
import 'package:circuitquest/core/commands/remove_component_command.dart';
import 'package:circuitquest/core/commands/rename_component_command.dart';
import 'package:circuitquest/core/logic/pin.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/shared/utils/pin_positioning_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double imageContainerHeight = 400;
const double maxDialogWidth = 600;

class ComponentDetailDialog {
  static void displayDialog(
    BuildContext context,
    PlacedComponent placedComponent,
    SandboxState state,
  ) {
    var textController = TextEditingController();
    textController.text = placedComponent.label ?? "";
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Title: Component type
              Text(placedComponent.type, style: TextTheme.of(context).displayLarge,),
              // Text field for label:
              TextField(
                controller: textController,
                onSubmitted: (value) {
                  final command = RenameComponentCommand(
                    state,
                    placedComponent.id,
                    textController.text,
                  );
                  CommandController.executeCommand(command);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: AppLocalizations.of(context)!.enterComponentLabel,
                ),
              ),
              Divider(),
              // Component image with pins on all 4 sides using grid layout
              SizedBox(
                width: double.infinity,
                height: imageContainerHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TOP pins row
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildGridPinsForSide(
                          placedComponent,
                          PinPosition.TOP,
                          imageContainerHeight,
                        ),
                      ),
                    ),
                    // Middle row: LEFT | Image | RIGHT
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // LEFT pins column
                          SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildGridPinsForSide(
                                placedComponent,
                                PinPosition.LEFT,
                                imageContainerHeight,
                              ),
                            ),
                          ),
                          // Center image
                          Expanded(
                            child: SvgPicture.asset(
                              'assets/gates/${placedComponent.type}.svg',
                              fit: BoxFit.contain,
                              placeholderBuilder: (context) =>
                                  Text(placedComponent.type),
                            ),
                          ),
                          // RIGHT pins column
                          SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildGridPinsForSide(
                                placedComponent,
                                PinPosition.RIGHT,
                                imageContainerHeight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // BOTTOM pins row
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildGridPinsForSide(
                          placedComponent,
                          PinPosition.BOTTOM,
                          imageContainerHeight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              // Delete option and closing button
              TextButton(
                onPressed: () {
                  // Use command pattern for undo/redo support
                  final command = RemoveComponentCommand(
                    state,
                    placedComponent.id,
                  );
                  CommandController.executeCommand(command);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds pin widgets for a specific side of the component in the dialog grid layout.
  /// Returns widgets suitable for Row (TOP/BOTTOM) or Column (LEFT/RIGHT) layout.
  /// For LEFT/RIGHT sides: labels are positioned horizontally beside the pin.
  /// For TOP/BOTTOM sides: labels are positioned vertically above/below the pin.
  static List<Widget> _buildGridPinsForSide(
    PlacedComponent placedComponent,
    PinPosition side,
    double containerSize,
  ) {
    final inputs = placedComponent.component.inputs.entries.toList();
    final outputs = placedComponent.component.outputs.entries.toList();
    final pinPositions = placedComponent.component.pinPositions;
    final widgets = <Widget>[];

    // Pre-calculate total pins on each side
    final inputKeys = inputs.map((e) => e.key).toList();
    final outputKeys = outputs.map((e) => e.key).toList();
    final pinsPerSide = PinPositioningUtils.calculatePinsPerSide(
      inputKeys,
      outputKeys,
      pinPositions,
    );

    final totalOnSide = pinsPerSide[side] ?? 0;
    if (totalOnSide == 0) {
      return widgets;
    }

    for (int i = 0; i < inputs.length + outputs.length; i++) {
      final entry = i < inputs.length ? inputs[i] : outputs[i - inputs.length];
      final pin = entry.value;
      final isInput = i < inputs.length;

      // Determine pin position
      final pinPosition = PinPositioningUtils.getPinPosition(
        entry.key,
        isInput,
        pinPositions,
      );

      // Only include pins that belong on this side
      if (pinPosition != side) {
        continue;
      }

      // Build label widget
      final labelWidget = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${entry.key}\n',
              style: TextStyle(color: Colors.black, fontSize: 10),
            ),
            WidgetSpan(child: Icon(Icons.usb, size: 12)),
            TextSpan(
              text: '${pin.bitWidth}',
              style: TextStyle(color: Colors.black, fontSize: 9),
            ),
            WidgetSpan(child: Icon(Icons.power_settings_new, size: 12)),
            TextSpan(
              text: '${pin.value}',
              style: TextStyle(color: Colors.black, fontSize: 9),
            )
          ],
        ),
      );

      // Build pin circle widget
      final pinCircle = Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: pin.value > 0 ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
      );

      // Layout depends on which side the pin is on
      if (side == PinPosition.LEFT || side == PinPosition.RIGHT) {
        // Horizontal layout: label beside pin
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: side == PinPosition.LEFT
                  ? [
                      Flexible(child: labelWidget),
                      SizedBox(width: 4),
                      pinCircle,
                    ]
                  : [
                      // RIGHT side: pin on left, label on right
                      pinCircle,
                      SizedBox(width: 4),
                      Flexible(child: labelWidget),
                    ],
            ),
          ),
        );
      } else {
        // Vertical layout for TOP/BOTTOM: label above/below pin
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                labelWidget,
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: pinCircle,
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
