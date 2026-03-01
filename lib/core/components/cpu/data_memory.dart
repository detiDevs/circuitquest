import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Data Memory component
class DataMemory extends SequentialComponent {
  late InputPin _address;
  late InputPin _writeData;
  late InputPin _memWrite;
  late InputPin _memRead;
  late OutputPin _readData;

  int _newData = 0;
  int _newDataAddress = 0;

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
    outputs['readData']!.value = 0;

    pinPositions = {'memWrite': PinPosition.TOP, 'memRead': PinPosition.TOP};
  }

  /// Load a list of data into the data memory.
  /// Only for testing and level initialization.
  void loadData(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      _memory[i] = data[i]; // Store at byte addresses (0, 4, 8, ...)
    }
  }

  @override
  bool evaluate() {
    _memRead.updateFromSource();
    _writeData.updateFromSource();
    _memWrite.updateFromSource();
    _address.updateFromSource();

    _newData = _writeData.value;
    _newDataAddress = _address.value;

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
  void applyNewState() {
    if (_memWrite.value == 1) {
      _memory[_newDataAddress] = _newData;
    }
  }
}
