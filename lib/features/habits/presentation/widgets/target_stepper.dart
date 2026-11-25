import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// "−  3 times a day  +". The cubit owns the limits; this only draws them
/// (a button is disabled when its direction is not allowed).
class TargetStepper extends StatelessWidget {
  const new({
    required this.value,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
    this.enabled = true,
    super.key,
  });

  final int value;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool enabled;

  /// M3's default icon button is 40x40 (below the 48 touch target).
  static final ButtonStyle _buttonStyle = IconButton.styleFrom(
    minimumSize: const Size.square(48),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        IconButton.outlined(
          onPressed: enabled && canDecrement ? onDecrement : null,
          tooltip: l10n.decreaseTarget,
          style: _buttonStyle,
          icon: const Icon(Icons.remove),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.habitTargetSummary(value),
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ).centered().expanded(),
        IconButton.outlined(
          onPressed: enabled && canIncrement ? onIncrement : null,
          tooltip: l10n.increaseTarget,
          style: _buttonStyle,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
