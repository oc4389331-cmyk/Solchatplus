import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/profile/nft_avatar_picker_screen.dart';
import 'package:solchat/features/chat/screens/chat_list_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _errorText = l10n.nicknameRequired);
      return;
    }

    final userAddress = ref.read(userProvider);
    if (userAddress == null) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final isAvailable = await ref.read(userServiceProvider).isNicknameAvailable(nickname, userAddress);
      if (!isAvailable) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorText = l10n.nicknameInUse);
        return;
      }

      await ref.read(userServiceProvider).updateNickname(userAddress, nickname);
      // Ensure user exists and has a timestamp
      await ref.read(userServiceProvider).ensureUserExists(userAddress);
      
      // Refresh user info to trigger AuthWrapper redirection
      ref.invalidate(userInfoProvider(userAddress));

      // Small delay before enabling the hint to ensure stable transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Trigger the "New Chat" hint in the list screen
      ref.read(showNewChatHintProvider.notifier).state = true;
      
      // We don't need to manually navigate; AuthWrapper will see the nickname
      // and switch to ChatListScreen automatically.
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _errorText = l10n.errorSaving(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userAddress = ref.watch(userProvider);
    final userAsync = ref.watch(userProfileProvider(userAddress ?? ''));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.auto_awesome, size: 60, color: Color(0xFF14F195)),
                  const SizedBox(height: 20),
                  Text(
                    l10n.onboardingWelcome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.onboardingDesc,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Avatar Picker (Optional)
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        backgroundImage: userAsync.value?.avatarUrl != null 
                          ? NetworkImage(userAsync.value!.avatarUrl!) 
                          : null,
                        child: userAsync.value?.avatarUrl == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.white24) 
                          : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF14F195),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NftAvatarPickerScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Nickname Field (Mandatory)
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: l10n.yourNickname,
                      labelStyle: const TextStyle(color: Colors.white60),
                      hintText: l10n.nicknameHint,
                      hintStyle: const TextStyle(color: Colors.white24),
                      errorText: _errorText,
                      prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF14F195)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14F195)),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    onChanged: (value) {
                      if (_errorText != null) setState(() => _errorText = null);
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _completeSetup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14F195),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            l10n.startChatting,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.changeLaterNotice,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
