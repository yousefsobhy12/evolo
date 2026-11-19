import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY (S3): in-memory only. S11 adds persistence and "system" mode.
class ThemeModeCubit extends Cubit<ThemeMode> {
  new({ThemeMode initial = ThemeMode.light}) : super(initial);

  void toggle() =>
      emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
}
