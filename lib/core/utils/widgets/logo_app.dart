import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoApp extends StatelessWidget {
  const LogoApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      width: 100,
      height: 100,
      'assets/svg/logo.svg',
    );
  }
}
