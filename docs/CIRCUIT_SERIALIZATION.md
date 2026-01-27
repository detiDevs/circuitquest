# Circuit Serialization Feature

## Overview
The circuit serialization feature allows users to save their sandbox circuits to JSON files and load them back later. This provides a way to:
- Save work in progress
- Share circuits with others
- Create circuit templates
- Build a library of reusable circuits

## Usage

### Saving a Circuit
1. Build your circuit in sandbox mode
2. Click the "Save Circuit" button in the control panel
3. Enter a name and description for your circuit
4. Choose a location to save the JSON file
5. The circuit will be saved with all components, connections, and positions

### Loading a Circuit
1. Click the "Load Circuit" button in the control panel
2. Select a previously saved circuit JSON file
3. If you have an existing circuit, you'll be asked to confirm (loading will clear the current circuit)
4. The circuit will be loaded with all components and connections restored

## JSON Format

The circuit JSON format is similar to the level file format but simpler, containing only:

### Top Level Structure
```json
{
    "name": "Circuit Name",
    "description": "Circuit description",
    "components": [...],
    "connections": [...]
}
```

### Component Format
Each component has:
- `type`: Component type (e.g., "And", "Or", "InputSource", "OutputProbe")
- `position`: [x, y] pixel coordinates
- `id`: Unique identifier string
- `immovable`: (optional) Whether the component can be moved
- `label`: (optional) Display label

Example:
```json
{
    "type": "And",
    "position": [320, 160],
    "id": "component_2"
}
```

### Connection Format
Each connection specifies a wire between two component pins:
- `sourceComponentId`: ID of the component providing the signal
- `sourcePin`: Name of the output pin (e.g., "output", "sum", "carry")
- `targetComponentId`: ID of the component receiving the signal  
- `targetPin`: Name of the input pin (e.g., "input", "a", "b")

Example:
```json
{
    "sourceComponentId": "component_0",
    "sourcePin": "output",
    "targetComponentId": "component_2",
    "targetPin": "a"
}
```

## Component Types

Supported component types:
- **Gates**: And, Or, Not, Nand, Nor, Xor
- **Adders**: HalfAdder, FullAdder
- **Sequential**: Clock, DLatch, DFlipFlop
- **I/O**: InputSource, OutputProbe

## Example Circuit

See `examples/example_circuit.json` for a complete example of a saved circuit file.

## Implementation Details

### Serialization (`SandboxState.serializeCircuit`)
- Converts all placed components to JSON format
- Converts all wire connections to JSON format
- Returns a JSON string ready to be saved

### Deserialization (`SandboxState.loadCircuitFromJson`)
- Parses JSON string
- Stops any running simulation
- Clears existing circuit
- Creates component instances from type strings
- Recreates wire connections between components
- Updates UI

### File Operations (`CircuitFileManager`)
- Uses `file_picker` package for cross-platform file dialogs
- Saves files with `.json` extension
- Provides confirmation dialogs when loading over existing circuits
- Shows success/error messages via snackbars

## Future Enhancements

The current implementation saves entire sandbox circuits. Future work could include:
- **Custom Components**: Save circuits as reusable components (similar to the Python version)
- **Circuit Libraries**: Browse and load from a library of saved circuits
- **Cloud Storage**: Save/load circuits from cloud storage
- **Circuit Validation**: Verify circuit correctness before saving
- **Metadata**: Add tags, author info, creation date, etc.
- **Thumbnails**: Generate and save circuit preview images
