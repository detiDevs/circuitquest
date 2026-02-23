import 'package:circuitquest/core/commands/command.dart';

class CommandController {
  static final List<Command> _undoStack = [];
  static final List<Command> _redoStack = [];

  static bool get canUndo => _undoStack.isNotEmpty;
  static bool get canRedo => _redoStack.isNotEmpty;

  static void executeCommand(Command command) {
    command.execute();
    addToUndo(command);
    _redoStack.clear();
  }

  static bool undo() {
    if (_undoStack.isNotEmpty && !_undoStack.last.canUndo) {
      return false;
    }
    final command = _undoStack.removeLast();
    command.undo();
    addToRedo(command);
    return true;
  }

  static bool redo() {
    if (_redoStack.isEmpty) {
      return false;
    }
    final command = _redoStack.removeLast();
    command.execute();
    addToUndo(command);
    return true;
  }

  /// Adds a command to the undo stack and manages the size limit.
  static void addToUndo(Command command) {
    _undoStack.add(command);
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0); // Remove the oldest element
    }
  }

  /// Adds a command to the redo stack and manages the size limit.
  static void addToRedo(Command command) {
    _redoStack.add(command);
    if (_redoStack.length > 50) {
      _redoStack.removeAt(0); // Remove the oldest element
    }
  }

  /// Clears both undo and redo stacks.
  static void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
