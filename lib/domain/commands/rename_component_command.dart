import 'package:circuitquest/domain/commands/command.dart';
import 'package:circuitquest/domain/use_cases/sandbox_engine.dart';
 

class RenameComponentCommand extends Command {
  final SandboxEngine _sandboxState;
  final String _componentId;
  final String newName;

  late String oldName;

  RenameComponentCommand(
    this._sandboxState,
    this._componentId,
    this.newName
  );

  @override
  void execute() {
    var comp = _sandboxState.getComponent(_componentId);
    oldName = comp?.label ?? "";
    _sandboxState.renameComponent(_componentId, newName);
  }

  @override
  void undo() {
    _sandboxState.renameComponent(_componentId, oldName);
  }

  @override
  String get description => "Renames a component";
}