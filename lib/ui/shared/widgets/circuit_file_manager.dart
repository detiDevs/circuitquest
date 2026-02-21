import 'dart:convert';
import 'dart:io';
import 'package:circuitquest/constants.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../state/sandbox_state.dart';
import '../../../state/custom_component_library.dart';
import '../../../core/components/input_source.dart';
import '../../../core/components/output_probe.dart';

/// Widget for saving and loading circuit files.
class CircuitFileManager extends ConsumerWidget {
  const CircuitFileManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sandboxProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Save circuit button
        ElevatedButton.icon(
          onPressed: state.placedComponents.isEmpty
              ? null
              : () => _saveCircuit(context, state),
          icon: const Icon(Icons.save),
          label: Text(AppLocalizations.of(context)!.saveCircuit),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Save as custom component button
        ElevatedButton.icon(
          onPressed: state.placedComponents.isEmpty
              ? null
              : () => _saveAsCustomComponent(context, ref, state),
          icon: const Icon(Icons.extension),
          label: Text(AppLocalizations.of(context)!.saveAsCustomComponent),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Load circuit button
        OutlinedButton.icon(
          onPressed: () => _loadCircuit(context, state),
          icon: const Icon(Icons.folder_open),
          label: Text(AppLocalizations.of(context)!.loadCircuit),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
        ),
      ],
    );
  }

  Future<void> _saveAsCustomComponent(
    BuildContext context,
    WidgetRef ref,
    SandboxState state,
  ) async {
    final inputComponents = state.placedComponents
        .where((c) => c.component is InputSource)
        .toList();
    final outputComponents = state.placedComponents
        .where((c) => c.component is OutputProbe)
        .toList();

    if (inputComponents.isEmpty || outputComponents.isEmpty) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          AppLocalizations.of(context)!.customComponentsNeedInputOutputError,
        );
      }
      return;
    }

    final nameController = TextEditingController(
      text: AppLocalizations.of(context)!.customComponentDefaultName,
    );
    final inputControllers = List.generate(
      inputComponents.length,
      (index) =>
          TextEditingController(text: _toCamelCase('Input ${index + 1}')),
    );
    final outputControllers = List.generate(
      outputComponents.length,
      (index) =>
          TextEditingController(text: _toCamelCase('Output ${index + 1}')),
    );

    String? spritePath;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.saveAsCustomComponent),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.customComponentName,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.customComponentInputKeysLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(inputControllers.length, (index) {
                  final input = inputComponents[index].component as InputSource;
                  final bitWidth = input.outputs['outValue']?.bitWidth ?? 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: inputControllers[index],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.customComponentInputLabel(index + 1, bitWidth),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.customComponentOutputKeysLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(outputControllers.length, (index) {
                  final output =
                      outputComponents[index].component as OutputProbe;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: outputControllers[index],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .customComponentOutputLabel(
                              index + 1,
                              output.bitWidth,
                            ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      dialogTitle: AppLocalizations.of(
                        context,
                      )!.customComponentSelectImage,
                      type: FileType.custom,
                      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        spritePath = result.files.single.path;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(
                    AppLocalizations.of(context)!.customComponentSelectImage,
                  ),
                ),
                if (spritePath != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${AppLocalizations.of(context)!.selected}: ${spritePath!.split(Platform.pathSeparator).last}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          AppLocalizations.of(context)!.customComponentNameCannotBeEmptyError,
        );
      }
      return;
    }

    final inputKeys = inputControllers.map((c) => c.text.trim()).toList();
    final outputKeys = outputControllers.map((c) => c.text.trim()).toList();
    if (inputKeys.any((k) => k.isEmpty) || outputKeys.any((k) => k.isEmpty)) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          AppLocalizations.of(context)!.customComponentKeysCannotBeEmptyError,
        );
      }
      return;
    }

    final data = state.buildCustomComponentData(
      name: name,
      inputKeys: inputKeys,
      outputKeys: outputKeys,
    );
    if (data == null) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          AppLocalizations.of(context)!.customComponentBuildDataError,
        );
      }
      return;
    }

    final library = ref.read(customComponentProvider);
    final success = await library.saveCustomComponent(
      data,
      spriteSourcePath: spritePath,
    );
    if (success) {
      await library.refresh();
    }

    if (context.mounted) {
      success
          ? SnackBarUtils.showSuccess(
              context,
              AppLocalizations.of(context)!.customComponentSaved,
            )
          : SnackBarUtils.showError(
              context,
              AppLocalizations.of(context)!.customComponentSavingError,
            );
    }
  }

  /// Shows dialog to save the circuit
  Future<void> _saveCircuit(BuildContext context, SandboxState state) async {
    final nameController = TextEditingController(
      text: AppLocalizations.of(context)!.circuitDefaultName,
    );
    final descriptionController = TextEditingController(
      text: AppLocalizations.of(context)!.circuitDefaultDescription,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.save),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.circuitNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.description,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Ensure default save directory exists
      final defaultDir = await _ensureDefaultDirectory();

      // Serialize circuit
      final jsonString = state.serializeCircuit(
        name: nameController.text,
        description: descriptionController.text,
      );

      // Convert to bytes for mobile compatibility
      final bytes = utf8.encode(jsonString);

      // Build default file name
      final defaultFileName = '${_sanitizeFileName(nameController.text)}.json';

      // Save file (bytes required for Android/iOS)
      final result = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context)!.save,
        fileName: defaultFileName,
        initialDirectory: defaultDir,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (result == null) return;

      if (context.mounted) {
        SnackBarUtils.showSuccess(
          context,
          Text(AppLocalizations.of(context)!.circuitSavedTo(result)) as String,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          AppLocalizations.of(context)!.circuitSaveError(e.toString()),
        );
      }
    }
  }

  /// Shows dialog to load a circuit
  Future<void> _loadCircuit(BuildContext context, SandboxState state) async {
    try {
      // Ensure default directory exists before opening picker
      final defaultDir = await _ensureDefaultDirectory();

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: AppLocalizations.of(context)!.loadCircuit,
        initialDirectory: defaultDir,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Confirm if circuit is not empty
      if (state.placedComponents.isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.loadCircuit),
            content: Text(
              AppLocalizations.of(context)!.loadCircuitConfirmMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(AppLocalizations.of(context)!.loadCircuitAction),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      // Load circuit
      final success = state.loadCircuitFromJson(jsonString);

      if (context.mounted) {
        success
            ? SnackBarUtils.showSuccess(
                context,
                AppLocalizations.of(context)!.circuitLoadedSuccess,
              )
            : SnackBarUtils.showError(
                context,
                AppLocalizations.of(context)!.circuitLoadedError,
              );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          AppLocalizations.of(context)!.circuitLoadError(e.toString()),
        );
      }
    }
  }

  /// Returns (and creates if needed) the default save/load directory.
  Future<String> _ensureDefaultDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dirPath = [
      documentsDir.path,
      Constants.kAppName,
      'Saved Circuits',
    ].join(Platform.pathSeparator);
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Sanitizes the provided file name to a filesystem-safe string.
  String _sanitizeFileName(String input) {
    final trimmed = input.trim();
    final base = trimmed.isEmpty ? 'circuit' : trimmed;
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
  }

  String _toCamelCase(String input) {
    final words = input
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join();
    return '$first$rest';
  }
}
