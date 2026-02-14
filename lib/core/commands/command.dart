/// Base interface for all undoable commands in the circuit editor.
abstract class Command {
  /// Executes the command.
  void execute();
  
  /// Undoes the command, restoring the previous state.
  void undo();
  
  /// A human-readable description of what this command does.
  String get description;
  
  /// Whether this command can be undone.
  bool get canUndo => true;
}