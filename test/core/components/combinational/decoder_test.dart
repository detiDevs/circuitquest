import 'package:cirquitquest_flutter/core/components/combinational/decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Decoder', () {
    test('drives exactly one output high', () {
      final decoder = Decoder(selectBitWidth: 3); // 3 bits -> 8 outputs

      for (int i = 0; i < 8; i++) {
        decoder.inputs['input']!.value = i;
        decoder.evaluate();

        for (int j = 0; j < 8; j++) {
          final expected = i == j ? 1 : 0;
          expect(decoder.outputs['out$j']!.value, expected,
              reason: 'selector=$i, output=$j');
        }
      }
    });

    test('masks selector to width', () {
      final decoder = Decoder(selectBitWidth: 2); // outputs 4

      decoder.inputs['input']!.value = 7; // masks to 3 for 2-bit selector
      decoder.evaluate();

      expect(decoder.outputs['out3']!.value, 1);
      expect(decoder.outputs['out0']!.value, 0);
      expect(decoder.outputs['out1']!.value, 0);
      expect(decoder.outputs['out2']!.value, 0);
    });

    test('reports change when output pattern changes', () {
      final decoder = Decoder(selectBitWidth: 2);

      decoder.inputs['input']!.value = 0;
      final changed = decoder.evaluate();
      expect(changed, true);

      // Same value should not report change
      final unchanged = decoder.evaluate();
      expect(unchanged, false);

      // Different selector -> pattern changes
      decoder.inputs['input']!.value = 1;
      final changedAgain = decoder.evaluate();
      expect(changedAgain, true);
    });
  });
}
