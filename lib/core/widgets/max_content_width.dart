import 'package:evolo/core/utils/breakpoints.dart';
import 'package:flutter/widgets.dart';

/// Centers its child and caps the width. Wrap the body of each page.
///
/// Used per page (not in MaterialApp.builder) so modal barriers and
/// SnackBars still span the full screen.
class MaxContentWidth extends StatelessWidget {
  const new({
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
