import 'dart:io';
import 'package:circuitquest/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../state/sandbox_state.dart';
import '../../state/custom_component_library.dart';
import '../../core/components/input_source.dart';
import '../../core/components/output_probe.dart';

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
          label: const Text('Save Circuit'),
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
          label: const Text('Save as Custom Component'),
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
          label: const Text('Load Circuit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom components need at least one input and one output.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final nameController = TextEditingController(text: 'My Custom Component');
    final inputControllers = List.generate(
      inputComponents.length,
      (index) => TextEditingController(
        text: _toCamelCase('Input ${index + 1}'),
      ),
    );
    final outputControllers = List.generate(
      outputComponents.length,
      (index) => TextEditingController(
        text: _toCamelCase('Output ${index + 1}'),
      ),
    );

    String? spritePath;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Save as Custom Component'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Component Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Input keys',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                        labelText: 'Input ${index + 1} (bitwidth: $bitWidth)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  'Output keys',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(outputControllers.length, (index) {
                  final output = outputComponents[index].component as OutputProbe;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: outputControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Output ${index + 1} (bitwidth: ${output.bitWidth})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      dialogTitle: 'Select Component Image',
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
                  label: const Text('Select Image'),
                ),
                if (spritePath != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Selected: ${spritePath!.split(Platform.pathSeparator).last}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Component name cannot be empty.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final inputKeys = inputControllers.map((c) => c.text.trim()).toList();
    final outputKeys = outputControllers.map((c) => c.text.trim()).toList();
    if (inputKeys.any((k) => k.isEmpty) || outputKeys.any((k) => k.isEmpty)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Input/output keys cannot be empty.'),
            backgroundColor: Colors.red,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to build custom component data.'),
            backgroundColor: Colors.red,
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Custom component saved.'
                : 'Failed to save custom component.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Shows dialog to save the circuit
  Future<void> _saveCircuit(BuildContext context, SandboxState state) async {
    final nameController = TextEditingController(text: 'My Circuit');
    final descriptionController = TextEditingController(
      text: 'Circuit created in sandbox mode',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Circuit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Circuit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
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

      // Build default file name
      final defaultFileName = '${_sanitizeFileName(nameController.text)}.json';

      // Get save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Circuit',
        fileName: defaultFileName,
        initialDirectory: defaultDir,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      // Ensure .json extension
      final normalizedPath = result.endsWith('.json') ? result : '$result.json';

      // Write file
      final file = File(normalizedPath);
      await file.writeAsString(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Circuit saved to ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving circuit: $e'),
            backgroundColor: Colors.red,
          ),
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
        dialogTitle: 'Load Circuit',
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
            title: const Text('Load Circuit'),
            content: const Text(
              'Loading a circuit will clear the current circuit. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Load'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      // Load circuit
      final success = state.loadCircuitFromJson(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Circuit loaded successfully'
                  : 'Error loading circuit',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading circuit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Returns (and creates if needed) the default save/load directory.
  Future<String> _ensureDefaultDirectory() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
    final dirPath = [home, Constants.kAppName, 'Saved Circuits']
        .join(Platform.pathSeparator);
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
