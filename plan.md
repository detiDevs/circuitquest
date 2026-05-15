# Plan: MVVM Refactor with Riverpod

Refactor to a clear data/domain/ui MVVM structure while keeping Riverpod for DI and state. Start by carving out a Home feature view model and provider, then roll the same pattern across level selection, level mode, and sandbox. Reuse existing services and state objects but move them into explicit layers and add view-model interfaces to keep UI passive.

## Steps
1. Define target folder structure and naming conventions for MVVM with Riverpod (data/services, data/repositories, domain/models, domain/commands, ui/<feature>/view_models, ui/<feature>/views, ui/core for shared widgets). Identify initial move list for Home only. (blocks later steps)
2. Create a Home view model that exposes UI state and navigation intents via methods (e.g., onLevelModeTap, onSandboxTap, onSettingsTap, onExitTap). Keep the view model pure UI logic, no widget imports. Provide it via Riverpod (Provider or NotifierProvider). (depends on 1)
3. Update Home view to consume the view model provider, render the same UI, and wire buttons to view model methods. Keep navigation in view for now, or use callbacks returned by VM if you want stricter MVVM. (depends on 2)
4. Establish the data layer boundaries: move LevelLoader into data/services, introduce a level repository interface + implementation that wraps it, and create providers for those repos. Add custom-component and saved-circuit repositories/services to load/save user data from file. Update existing providers in state to use these repositories. (parallel with step 3 after step 1)
5. Migrate level-selection feature to MVVM: create LevelSelectionViewModel that exposes AsyncValue for categories and commands for refresh/unlock; update view to use it. (depends on 4)
6. Migrate sandbox/level-mode state: split SandboxState into domain (simulation models) vs UI view model; expose only immutable UI state from VM and keep mutation inside VM. Use the custom-component and saved-circuit repositories/services for persistence. (depends on 4)
7. Move commands from lib/core/commands to lib/domain/commands and update imports. (parallel with step 4 after step 1)
8. Clean up old providers and adjust imports; ensure app entry wires all providers in one place (e.g., lib/app/providers.dart). (depends on 3,5,6,7)

## Planned file tree
```
lib/
  app/
    app.dart
    providers.dart
    router.dart
  data/
    repositories/
      level_repository.dart
      level_repository_impl.dart
      custom_component_repository.dart
      custom_component_repository_impl.dart
      saved_circuit_repository.dart
      saved_circuit_repository_impl.dart
    services/
      level_loader_service.dart
      custom_component_storage_service.dart
      saved_circuit_storage_service.dart
      preferences_service.dart
  domain/
    commands/
      add_connection_command.dart
      move_component_command.dart
      remove_component_command.dart
      ... (other command files)
    models/
      level.dart
      level_meta.dart
      level_category.dart
      custom_component.dart
      saved_circuit.dart
  ui/
    core/
      themes/
      widgets/
    home/
      view_models/
        home_view_model.dart
      views/
        home_screen.dart
      widgets/
        home_logo.dart
    level_selection/
      view_models/
        level_selection_view_model.dart
      views/
        level_selection_screen.dart
      widgets/
        level_category_widget.dart
        level_card.dart
    level_mode/
      view_models/
        level_view_model.dart
      views/
        level_screen.dart
      widgets/
        level_canvas.dart
    sandbox_mode/
      view_models/
        sandbox_view_model.dart
      views/
        sandbox_screen.dart
      widgets/
        sandbox_canvas.dart
  core/
    (simulation, components, logic - unchanged)
  l10n/
  constants.dart
  main.dart
```

## Relevant files
- lib/main.dart - app entry, provider scope wiring, home routing
- lib/ui/home/home_screen.dart - first screen to convert to MVVM
- lib/state/level_state.dart - current providers for levels; will shift to repository-backed VM
- lib/state/sandbox_state.dart - large state object to split into VM + domain
- lib/state/custom_component_library.dart - data source to move behind repository/service
- lib/levels/level_loader.dart - service to move under data/services
- lib/core/commands/ - commands to move into domain layer
- lib/ui/level_selection/level_selection_screen.dart - next feature to convert

## Verification
1. Run flutter analyze.
2. Run existing tests in test/.
3. Manual: launch app, verify Home buttons navigate, level selection loads, sandbox/level screens function.

## Decisions
- Keep Riverpod for DI/state; implement MVVM via view-model classes exposed as providers.
- Start with Home feature; then Level Selection; then Level/Sandbox.
- Custom components and saved circuits each get a repository/service for file persistence.
- Commands move into domain layer.
