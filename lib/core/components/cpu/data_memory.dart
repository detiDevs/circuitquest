import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Data Memory component
class DataMemory extends Component {
  late InputPin _address;
  late InputPin _writeData;
  late InputPin _memWrite;
  late InputPin _memRead;
  late OutputPin _readData;

  final Map<int, int> _memory = {};

  DataMemory() {
    _address = InputPin(this, bitWidth: 32);
    _writeData = InputPin(this, bitWidth: 32);
    _memWrite = InputPin(this, bitWidth: 1);
    _memRead = InputPin(this, bitWidth: 1);
    _readData = OutputPin(this, bitWidth: 32);
    
    inputs['address'] = _address;
    inputs['writeData'] = _writeData;
    inputs['memWrite'] = _memWrite;
    inputs['memRead'] = _memRead;
    outputs['readData'] = _readData;
  }

  /// Load a list of data into the data memory.
  /// Only for testing and level initialization.
  void loadData(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      _memory[i * 4] = data[i]; // Store at byte addresses (0, 4, 8, ...)
    }
  }

  @override
  bool evaluate() {
    if (_memRead.value == 1) {
      final data = _memory[_address.value] ?? 0;
      if (_readData.value != data) {
        _readData.value = data;
        return true;
      }
    }
    return false;
  }

  @override
  void tick() {
    if (_memWrite.value == 1) {
      _memory[_address.value] = _writeData.value;
    }
  }
}
