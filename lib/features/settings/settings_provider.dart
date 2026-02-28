import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/user_service.dart';

// State Class
class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;
  final bool isOnlineVisible;
  final String? customSoundPath;
  final bool isLoading;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.notificationsEnabled = true,
    this.isOnlineVisible = true,
    this.customSoundPath,
    this.isLoading = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
    bool? isOnlineVisible,
    String? customSoundPath,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isOnlineVisible: isOnlineVisible ?? this.isOnlineVisible,
      customSoundPath: customSoundPath ?? this.customSoundPath,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  late SharedPreferences _prefs;

  SettingsNotifier(this.ref) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Theme
    final themeIndex = _prefs.getInt('themeMode') ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeIndex];

    // Locale
    final languageCode = _prefs.getString('languageCode') ?? 'en';
    final locale = Locale(languageCode);

    // Notifications
    final notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;

    // Online Status
    final isOnlineVisible = _prefs.getBool('isOnlineVisible') ?? true;

    // Custom Sound Path
    final customSoundPath = _prefs.getString('customSoundPath');

    state = SettingsState(
      themeMode: themeMode,
      locale: locale,
      notificationsEnabled: notificationsEnabled,
      isOnlineVisible: isOnlineVisible,
      customSoundPath: customSoundPath,
      isLoading: false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString('languageCode', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _prefs.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    // You could also call a NotificationService here to subscribe/unsubscribe topics
  }

  Future<void> toggleOnlineVisibility(bool visible) async {
    await _prefs.setBool('isOnlineVisible', visible);
    state = state.copyWith(isOnlineVisible: visible);
    
    // Sync with Firestore
    final userAddress = ref.read(userProvider);
    if (userAddress != null) {
      if (visible) {
        // If visible, set true (or start updating normally)
        await ref.read(userServiceProvider).updateOnlineStatus(userAddress, true);
      } else {
        // If hidden, force offline immediately
        await ref.read(userServiceProvider).updateOnlineStatus(userAddress, false);
      }
    }
  }

  Future<void> setCustomSoundPath(String? path) async {
    if (path == null) {
      await _prefs.remove('customSoundPath');
    } else {
      await _prefs.setString('customSoundPath', path);
    }
    state = state.copyWith(customSoundPath: path);
  }
}
