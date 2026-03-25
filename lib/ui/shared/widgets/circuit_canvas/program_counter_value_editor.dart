import 'package:circuitquest/core/components/cpu/program_counter.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';

class ProgramCounterValueEditor extends StatefulWidget {
  final ProgramCounter pc;

  const ProgramCounterValueEditor({super.key, required this.pc});

  @override
  State<ProgramCounterValueEditor> createState() =>
      _ProgramCounterValueEditorState();
}

class _ProgramCounterValueEditorState extends State<ProgramCounterValueEditor> {
  final textController = TextEditingController();
  bool enteredInvalidValue = false;

  @override
  void initState() {
    super.initState();
    textController.text = widget.pc.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.overrideProgramCounterValue),
        TextField(
          controller: textController,
          onSubmitted: (strValue) {
            final int intValue = int.tryParse(strValue) ?? 0;
            widget.pc.value = intValue;
            textController.text = widget.pc.value.toString();
            if (intValue != widget.pc.value) {
              setState(() {
                enteredInvalidValue = true;
              });
            } else {
              setState(() {
                enteredInvalidValue = false;
              });
            }
          },
        ),
        if (enteredInvalidValue)
          Text(
            AppLocalizations.of(context)!.invalidProgramCounterValue,
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
