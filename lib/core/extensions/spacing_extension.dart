import 'package:flutter/widgets.dart';

/// `16.vSpace` / `8.hSpace`. Fixed pt values, no screenutil.
extension SpacingNum on num {
  Widget get vSpace => SizedBox(height: toDouble());

  Widget get hSpace => SizedBox(width: toDouble());
}
