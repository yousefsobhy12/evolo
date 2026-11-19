import 'package:evolo/core/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  new({required Locale initial}) : super(initial);

  static const _arabic = Locale('ar');
  static const _english = Locale('en');

  /// Maps the device locale to a supported one. Falls back to Arabic.
  static Locale resolve(Locale device) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == device.languageCode) return supported;
    }
    return _arabic;
  }

  void toggle() => emit(state.languageCode == 'ar' ? _english : _arabic);

  void setLocale(Locale locale) {
    if (locale == state) return;
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    emit(locale);
  }
}
