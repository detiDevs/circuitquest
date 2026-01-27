import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../state/sandbox_state.dart';

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
    final dirPath = [home, 'CircuitQuest', 'Saved Circuits']
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
}
