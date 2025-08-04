import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../services/settings_service.dart';

// --- STATE ---
class LocaleState extends Equatable {
  final Locale? locale;
  const LocaleState(this.locale);

  @override
  List<Object?> get props => [locale];
}

// --- CUBIT ---
class LocaleCubit extends Cubit<LocaleState> {
  final SettingsService _settingsService;

  LocaleCubit(this._settingsService) : super(const LocaleState(null));

  Future<void> loadLocale() async {
    final locale = await _settingsService.loadLocale();
    emit(LocaleState(locale));
  }

  Future<void> setLocale(Locale locale) async {
    await _settingsService.saveLocale(locale.languageCode);
    emit(LocaleState(locale));
  }

  // A method to clear the setting and revert to system language
  Future<void> clearLocale() async {
    await _settingsService.saveLocale(''); // Save empty string
    emit(const LocaleState(null));
  }
}