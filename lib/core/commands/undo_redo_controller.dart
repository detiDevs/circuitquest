import 'package:circuitquest/core/commands/command.dart';

class UndoRedoController {
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  void executeCommand(Command command) {
    command.execute();
    addToUndo(command);
    _redoStack.clear();
  }

  bool undo() {
    if (_undoStack.isNotEmpty && !_undoStack.last.canUndo) {
      return false;
    }
    final command = _undoStack.removeLast();
    command.undo();
    addToRedo(command);
    return true;
  }

  bool redo() {
    if (_redoStack.isEmpty) {
      return false;
    }
    final command = _redoStack.removeLast();
    command.execute();
    addToUndo(command);
    return true;
  }

  /// Adds a command to the undo stack and manages the size limit.
  void addToUndo(Command command) {
    _undoStack.add(command);
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0); // Remove the oldest element
    }
  }

  /// Adds a command to the redo stack and manages the size limit.
  void addToRedo(Command command) {
    _redoStack.add(command);
    if (_redoStack.length > 50) {
      _redoStack.removeAt(0); // Remove the oldest element
    }
  }
}
