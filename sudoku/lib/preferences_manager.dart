import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

/// Manages user preferences and settings
class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();

  factory PreferencesManager() {
    return _instance;
  }

  PreferencesManager._internal();

  late SharedPreferences _prefs;

  /// Initialize the preferences manager
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
    }
  }

  /// Get all preferences as a map
  Future<Map<String, String?>> getAllPreferences() async {
    try {
      return {
        'difficultyLevel': _prefs.getString(PREF_DIFFICULTY_LEVEL),
        'theme': _prefs.getString(PREF_THEME),
        'accentColor': _prefs.getString(PREF_ACCENT_COLOR),
      };
    } catch (e) {
      debugPrint('Error retrieving preferences: $e');
      return {};
    }
  }

  /// Get difficulty level preference
  String? getDifficultyLevel() =>
      _prefs.getString(PREF_DIFFICULTY_LEVEL);

  /// Get theme preference
  String? getTheme() =>
      _prefs.getString(PREF_THEME);

  /// Get accent color preference
  String? getAccentColor() =>
      _prefs.getString(PREF_ACCENT_COLOR);

  /// Save difficulty level
  Future<void> setDifficultyLevel(String level) async {
    try {
      await _prefs.setString(PREF_DIFFICULTY_LEVEL, level);
    } catch (e) {
      debugPrint('Error saving difficulty level: $e');
    }
  }

  /// Save theme
  Future<void> setTheme(String theme) async {
    try {
      await _prefs.setString(PREF_THEME, theme);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Save accent color
  Future<void> setAccentColor(String color) async {
    try {
      await _prefs.setString(PREF_ACCENT_COLOR, color);
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }

  /// Clear all preferences
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
  }
}
