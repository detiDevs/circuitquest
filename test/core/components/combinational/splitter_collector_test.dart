import 'package:circuitquest_flutter/core/components/combinational/collector.dart';
import 'package:circuitquest_flutter/core/components/combinational/splitter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Splitter', () {
    test('splits a 16-bit bus into four 4-bit slices', () {
      final splitter = Splitter(sliceCount: 4, sliceBitWidth: 4);
      splitter.inputs['input']!.value = 0xABCD; // 1010 1011 1100 1101
      splitter.evaluate();

      expect(splitter.outputs['out0']!.value, 0xD);
      expect(splitter.outputs['out1']!.value, 0xC);
      expect(splitter.outputs['out2']!.value, 0xB);
      expect(splitter.outputs['out3']!.value, 0xA);
    });

    test('reports change only when slice value changes', () {
      final splitter = Splitter(sliceCount: 2, sliceBitWidth: 2);
      splitter.inputs['input']!.value = 3;
      final changed = splitter.evaluate();
      expect(changed, true);
      final unchanged = splitter.evaluate();
      expect(unchanged, false);
    });
  });

  group('Collector', () {
    test('collects four 4-bit slices into a 16-bit bus', () {
      final collector = Collector(sliceCount: 4, sliceBitWidth: 4);

      collector.inputs['in0']!.value = 0x1;
      collector.inputs['in1']!.value = 0x2;
      collector.inputs['in2']!.value = 0x3;
      collector.inputs['in3']!.value = 0x4;
      collector.evaluate();

      expect(collector.outputs['out']!.value, 0x4321);
    });

    test('reports change when aggregated value changes', () {
      final collector = Collector(sliceCount: 2, sliceBitWidth: 2);

      collector.inputs['in0']!.value = 1;
      collector.inputs['in1']!.value = 2;
      final changed = collector.evaluate();
      expect(changed, true);
      final unchanged = collector.evaluate();
      expect(unchanged, false);
    });
  });

  group('Splitter + Collector', () {
    test('round trips value through split then collect', () {
      final splitter = Splitter(sliceCount: 4, sliceBitWidth: 4);
      final collector = Collector(sliceCount: 4, sliceBitWidth: 4);

      splitter.inputs['input']!.value = 0xBEEF;
      splitter.evaluate();

      collector.inputs['in0']!.value = splitter.outputs['out0']!.value;
      collector.inputs['in1']!.value = splitter.outputs['out1']!.value;
      collector.inputs['in2']!.value = splitter.outputs['out2']!.value;
      collector.inputs['in3']!.value = splitter.outputs['out3']!.value;
      collector.evaluate();

      expect(collector.outputs['out']!.value, 0xBEEF & 0xFFFF);
    });
  });
}
