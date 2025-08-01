import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/settings_service.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  final SettingsService _settingsService;
  ThemeCubit(this._settingsService) : super(const ThemeState(ThemeMode.system));

  Future<void> loadTheme() async {
    final themeMode = await _settingsService.loadThemeMode();
    emit(ThemeState(themeMode));
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    await _settingsService.saveThemeMode(themeMode);
    emit(ThemeState(themeMode));
  }
}