import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const EvoloApp());
}

class EvoloApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(),
    );
  }
}
