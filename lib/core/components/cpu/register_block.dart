import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Register Block component containing 32 registers of 32-bits each
class RegisterBlock extends Component {
  late InputPin _readAddress1;
  late InputPin _readAddress2;
  late InputPin _writeAddress;
  late InputPin _writeData;
  late InputPin _writeEnable;
  late OutputPin _readData1;
  late OutputPin _readData2;

  List<int> _registers = List.filled(32, 0);

  /// Load initial register values.
  /// Only for testing and level initialization.
  void loadRegisters(List<int> values) {
    if (values.length <= 32) {
      _registers = List.from(values);
      // Pad with zeros if less than 32 values
      while (_registers.length < 32) {
        _registers.add(0);
      }
    }
  }

  RegisterBlock() {
    _readAddress1 = InputPin(this, bitWidth: 5);
    _readAddress2 = InputPin(this, bitWidth: 5);
    _writeAddress = InputPin(this, bitWidth: 5);
    _writeData = InputPin(this, bitWidth: 32);
    _writeEnable = InputPin(this, bitWidth: 1);
    _readData1 = OutputPin(this, bitWidth: 32);
    _readData2 = OutputPin(this, bitWidth: 32);
    
    inputs['readReg1'] = _readAddress1;
    inputs['readReg2'] = _readAddress2;
    inputs['writeReg'] = _writeAddress;
    inputs['writeData'] = _writeData;
    inputs['writeEnable'] = _writeEnable;
    outputs['readData1'] = _readData1;
    outputs['readData2'] = _readData2;
  }

  @override
  bool evaluate() {
    final addr1 = _readAddress1.value & 0x1F;
    final addr2 = _readAddress2.value & 0x1F;
    
    final data1 = _registers[addr1];
    final data2 = _registers[addr2];
    
    bool changed = false;
    if (_readData1.value != data1) {
      _readData1.value = data1;
      changed = true;
    }
    if (_readData2.value != data2) {
      _readData2.value = data2;
      changed = true;
    }
    return changed;
  }

  @override
  void tick() {
    if (_writeEnable.value == 1) {
      final addr = _writeAddress.value & 0x1F;
      _registers[addr] = _writeData.value;
    }
  }
}
