# Circuit Serialization Implementation Summary

## What Was Added

### 1. Serialization Methods in `SandboxState`
- **`serializeCircuit()`**: Converts the current circuit to JSON format
  - Serializes all placed components with their types, positions, IDs, and properties
  - Serializes all wire connections between components
  - Returns formatted JSON string
  
- **`loadCircuitFromJson()`**: Loads a circuit from JSON
  - Parses JSON and validates structure
  - Stops running simulations before loading
  - Clears existing circuit
  - Creates component instances from type strings
  - Rebuilds wire connections between components
  - Handles errors gracefully

- **`_rebuildWireConnections()`**: Internal helper method
  - Clears existing wire connections
  - Recreates Wire objects from connection data
  - Maintains circuit state consistency

### 2. JSON Serialization Support
- Added `toJson()` method to `PlacedComponent` class
- Added `toJson()` method to `WireConnection` class
- Uses `dart:convert` for JSON encoding/decoding

### 3. File Management UI (`CircuitFileManager` widget)
Located in `lib/ui/widgets/circuit_file_manager.dart`

Features:
- **Save Circuit** button with dialog for name/description
- **Load Circuit** button with file picker
- Confirmation dialog when loading over existing circuit
- Success/error feedback via snackbars
- Cross-platform file dialogs using `file_picker` package

### 4. Control Panel Integration
- Added "File Operations" section to control panel
- Integrated `CircuitFileManager` widget
- Positioned between simulation controls and clear button

### 5. Dependencies
Added to `pubspec.yaml`:
- `file_picker: ^8.1.6` - Cross-platform file selection
- `path_provider: ^2.1.5` - Platform-specific path access

### 6. Documentation and Examples
- Created `docs/CIRCUIT_SERIALIZATION.md` with full documentation
- Created `examples/example_circuit.json` with a sample circuit

## JSON Format

```json
{
    "name": "Circuit Name",
    "description": "Description",
    "components": [
        {
            "type": "And",
            "position": [320, 160],
            "id": "component_0",
            "immovable": false,  // optional
            "label": "Label"     // optional
        }
    ],
    "connections": [
        {
            "sourceComponentId": "component_0",
            "sourcePin": "output",
            "targetComponentId": "component_1",
            "targetPin": "a"
        }
    ]
}
```

## Files Modified

1. **`lib/state/sandbox_state.dart`**
   - Added imports for `dart:convert`, `output_probe`, `component_palette`
   - Added `toJson()` methods to `PlacedComponent` and `WireConnection`
   - Added `serializeCircuit()`, `loadCircuitFromJson()`, `_rebuildWireConnections()` methods

2. **`lib/ui/widgets/control_panel.dart`**
   - Imported `CircuitFileManager`
   - Added "File Operations" section with save/load buttons

3. **`pubspec.yaml`**
   - Added `file_picker` and `path_provider` dependencies

## Files Created

1. **`lib/ui/widgets/circuit_file_manager.dart`**
   - New widget for save/load functionality
   - Handles file dialogs and user interactions

2. **`examples/example_circuit.json`**
   - Sample circuit JSON file

3. **`docs/CIRCUIT_SERIALIZATION.md`**
   - Complete documentation of the feature

## How It Works

### Saving
1. User clicks "Save Circuit" in control panel
2. Dialog prompts for name and description
3. File picker opens to choose save location
4. Circuit is serialized to JSON and written to file
5. Success message shown

### Loading
1. User clicks "Load Circuit" in control panel
2. File picker opens to select JSON file
3. If circuit exists, confirmation dialog appears
4. JSON is parsed and circuit is reconstructed
5. All components and connections are restored
6. Success/error message shown

## Key Design Decisions

1. **Similar to Level Format**: JSON structure matches level files for consistency
2. **Component Factory Pattern**: Uses existing `availableComponents` list to create instances
3. **ID Preservation**: Maintains component IDs from saved files for connection integrity
4. **Graceful Error Handling**: Unknown component types are skipped with warnings
5. **User Feedback**: Clear dialogs and messages for all operations

## Testing

To test the feature:
1. Build a circuit in sandbox mode
2. Click "Save Circuit" and save it
3. Clear or modify the circuit
4. Click "Load Circuit" and load the saved file
5. Verify all components and connections are restored

## Future Enhancements

- Custom components (save circuits as reusable components)
- Circuit libraries/templates
- Cloud storage integration
- Circuit validation before saving
- Metadata (tags, author, creation date)
- Circuit thumbnails/previews
