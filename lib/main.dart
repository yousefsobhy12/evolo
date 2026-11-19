import 'package:evolo/app.dart';
import 'package:evolo/core/di/injection.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Needed by DateFormat in AppFormatters (month names per language).
  await Future.wait([
    initializeDateFormatting('ar'),
    initializeDateFormatting('en'),
  ]);
  await configureDependencies();
  runApp(const EvoloApp());
}
