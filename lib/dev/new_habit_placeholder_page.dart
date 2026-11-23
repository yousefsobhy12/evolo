import 'package:evolo/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY (S6): the FAB needs somewhere to go. Replaced by the real
/// add-habit form in S7.
class NewHabitPlaceholderPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addHabit)),
      body: const SizedBox.shrink(),
    );
  }
}
