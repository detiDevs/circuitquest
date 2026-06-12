import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: SvgPicture.asset(
        'assets/images/AppLogo.svg',
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.memory, size: 80, color: Colors.blue[800]),
        ),
      ),
    );
  }
}
