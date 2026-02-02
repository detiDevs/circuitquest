import 'package:circuitquest/core/logic/pin.dart';

class Wire {
  final OutputPin from;
  final InputPin to;

  Wire(this.from, this.to) {
    // Allow connecting to a wider input; still block narrowing to avoid data loss surprises.
    // To allow any bitwidth, set it to 0
    if (to.bitWidth != 0 && from.bitWidth > to.bitWidth) {
      throw ArgumentError(
        'Bitwidth mismatch: ${from.bitWidth} -> ${to.bitWidth}',
      );
    }

    from.connect(this);
    to.source = this;
  }

  int get value => from.value;
}
