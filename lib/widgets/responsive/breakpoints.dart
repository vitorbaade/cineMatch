import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  static const double tablet = 700;
  static const double desktop = 1100;

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= tablet;

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= desktop;

  static const double maxContentWidth = 1200;
}
