import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/settings/settings_provider.dart';
import 'package:solchat/features/settings/blocked_users_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: settings.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader(context, l10n.appearance),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text(l10n.appearance),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: Container(),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(l10n.system),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(l10n.light),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(l10n.dark),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode != null) notifier.setThemeMode(mode);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: DropdownButton<Locale>(
                    value: settings.locale,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English 🇺🇸'),
                      ),
                      DropdownMenuItem(
                        value: Locale('es'),
                        child: Text('Español 🇪🇸'),
                      ),
                    ],
                    onChanged: (locale) {
                      if (locale != null) notifier.setLocale(locale);
                    },
                  ),
                ),
                
                const Divider(),
                _buildSectionHeader(context, l10n.privacy),
                SwitchListTile(
                  secondary: const Icon(Icons.visibility),
                  title: Text(l10n.onlineStatus),
                  subtitle: Text(l10n.onlineStatusDesc),
                  value: settings.isOnlineVisible,
                  activeColor: const Color(0xFF14F195),
                  onChanged: (val) => notifier.toggleOnlineVisibility(val),
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.redAccent),
                  title: Text(l10n.blockedUsers),
                  subtitle: Text(l10n.blockedUsersDesc),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                    );
                  },
                ),

                const Divider(),
                _buildSectionHeader(context, l10n.notifications),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: Text(l10n.enableNotifications),
                  value: settings.notificationsEnabled,
                  activeColor: const Color(0xFF14F195),
                   onChanged: (val) => notifier.toggleNotifications(val),
                 ),
                  if (settings.notificationsEnabled)
                  ListTile(
                    leading: const Icon(Icons.music_note, color: Color(0xFF14F195)),
                    title: Text(l10n.activeChatSound, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      settings.customSoundPath != null 
                        ? settings.customSoundPath!.split('/').last 
                        : l10n.defaultSound,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (settings.customSoundPath != null)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white38),
                            onPressed: () => notifier.setCustomSoundPath(null),
                          ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
                      ],
                    ),
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        notifier.setCustomSoundPath(result.files.single.path);
                      }
                    },
                  ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
