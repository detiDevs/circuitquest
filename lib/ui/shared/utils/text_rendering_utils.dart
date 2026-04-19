import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TextRenderingUtils {
  /// Render a string that may contain inline LaTeX (dollar-delimited).
  ///
  /// Call from widgets as:
  /// `TextRenderingUtils.renderMaybeMath(context, text, textStyle)`
  static Widget renderMaybeMath(BuildContext context, String s, TextStyle? initialTheme) {
    final theme = initialTheme ?? Theme.of(context).textTheme.bodySmall;
    if (!s.contains(r'$')) {
      return Text(s, style: theme);
    }

    final regex = RegExp(r'(\$.*?\$)');
    final children = List<InlineSpan>.empty(growable: true);
    final mathParts = regex.allMatches(s).map((m) => m.group(0)!).toList();
    final nonMathParts = s.split(regex);

    for (int i = 0; i < nonMathParts.length; i++) {
      children.add(
        TextSpan(
          text: nonMathParts[i],
          style: theme,
        ),
      );
      if (i < mathParts.length) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              mathParts[i].substring(1, mathParts[i].length - 1),
              textStyle: theme,
              onErrorFallback: (err) => Text(
                'Error rendering math: $err',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          style: theme,
          children: children,
        ),
      ),
    );
  }
}