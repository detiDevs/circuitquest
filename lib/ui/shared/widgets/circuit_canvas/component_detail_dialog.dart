import 'package:circuitquest/core/commands/command.dart';
import 'package:circuitquest/core/commands/command_controller.dart';
import 'package:circuitquest/core/commands/remove_component_command.dart';
import 'package:circuitquest/core/commands/rename_component_command.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Title: Component type
              Text(placedComponent.type),
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
              // Maybe change the row/column to a grid layout to also have top and bottom inputs/outputs
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // column for the inputs
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: placedComponent.component.inputs.entries
                          .map((e) => Row(
                            children: [
                              Text('${e.key} (${e.value.bitWidth}-Bit)'),
                              CircleAvatar(backgroundColor: Colors.red, radius: 10,),
                            ],
                          ))
                          .toList(),
                    ),
                    // Component image with input/output explanations:
                    SvgPicture.asset(
                      'assets/gates/${placedComponent.type}.svg',
                      //TODO: make size dynamic
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Text(placedComponent.type),
                    ),
                    // column for the outputs
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: placedComponent.component.outputs.entries
                          .map((e) => Row(
                            children: [
                              CircleAvatar(backgroundColor: Colors.red, radius: 10),
                              Text('${e.key} (${e.value.bitWidth}-Bit)'),
                            ],
                          ))
                          .toList(),
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
                child: const Text("Delete"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
