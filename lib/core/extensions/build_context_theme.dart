import 'package:evolo/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  /// App-specific tokens (tiles, bars, reminder card...).
  AppColors get colors => theme.extension<AppColors>()!;

  bool get isDark => theme.brightness == Brightness.dark;
}
