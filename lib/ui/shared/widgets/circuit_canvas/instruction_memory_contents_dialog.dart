import 'package:circuitquest/core/components/cpu/instruction_memory.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:flutter/material.dart';

class InstructionMemoryContentsDialog {
  static int _parseInstructionValue(String value, int fallback) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }

    if (trimmed.startsWith('0x') || trimmed.startsWith('0X')) {
      return int.tryParse(trimmed.substring(2), radix: 16) ?? fallback;
    }

    return int.tryParse(trimmed) ?? fallback;
  }

  static String _formatAddress(int index) {
    final byteAddress = index * 4;
    return '0x${byteAddress.toRadixString(16).padLeft(8, '0')}';
  }

  static void displayDialog(
    BuildContext context,
    PlacedComponent placedComponent,
    SandboxState state,
  ) {
    if (placedComponent.component is! InstructionMemory) {
      return;
    }

    final instructionMemory = placedComponent.component as InstructionMemory;
    final isImmutable = placedComponent.immutable;
    final instructions = List<int>.from(instructionMemory.instructions);
    bool hasUnsavedChanges = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.instructionMemoryContents,
              ),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.instructionMemoryFormatHint,
                    ),
                    SizedBox(height: 8,),
                    Flexible(
                      child: instructions.isEmpty
                          ? Text(
                              AppLocalizations.of(
                                context,
                              )!.noInstructionsConfigured,
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: instructions.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 92,
                                      child: Text(
                                        _formatAddress(index),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        key: ValueKey('instruction_$index'),
                                        initialValue: instructions[index]
                                            .toString(),
                                        enabled: !isImmutable,
                                        readOnly: isImmutable,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (isImmutable) {
                                            return;
                                          }
                                          instructions[index] =
                                              _parseInstructionValue(
                                                value,
                                                instructions[index],
                                              );
                                          setState(
                                            () => hasUnsavedChanges = true,
                                          );
                                        },
                                      ),
                                    ),
                                    if (!isImmutable) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          setState(() {
                                            instructions.removeAt(index);
                                            hasUnsavedChanges = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                    ),
                    if (!isImmutable) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              instructions.add(0);
                              hasUnsavedChanges = true;
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: Text(
                            AppLocalizations.of(context)!.addInstruction,
                          ),
                        ),
                      ),
                    ],
                    if (hasUnsavedChanges)
                      Text(
                        AppLocalizations.of(context)!.unsavedChanges,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.close),
                ),
                if (!isImmutable)
                  FilledButton(
                    onPressed: hasUnsavedChanges
                        ? () {
                            instructionMemory.loadInstructions(instructions);
                            state.evaluateFromComponent(instructionMemory);
                            Navigator.of(context).pop();
                          }
                        : null,

                    child: Text(AppLocalizations.of(context)!.save),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
