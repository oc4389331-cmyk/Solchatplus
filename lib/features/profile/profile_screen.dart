import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/profile/nft_avatar_picker_screen.dart';
import 'package:solchat/features/profile/my_qr_code_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAddress = ref.watch(userProvider);
    final userAsync = ref.watch(userProfileProvider(userAddress ?? ''));

    ref.listen(userProfileProvider(userAddress ?? ''), (previous, next) {
      if (next.value?.nickname != null && _nicknameController.text.isEmpty) {
        _nicknameController.text = next.value!.nickname!;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userAsync.value?.avatarUrl != null 
                      ? NetworkImage(userAsync.value!.avatarUrl!) 
                      : null,
                    child: userAsync.value?.avatarUrl == null 
                      ? const Icon(Icons.person, size: 50) 
                      : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
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
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.walletAddress,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(
                userAddress ?? AppLocalizations.of(context)!.notConnected,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyQRCodeScreen()),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: Text(AppLocalizations.of(context)!.showMyQRCode),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF14F195),
                  side: const BorderSide(color: Color(0xFF14F195)),
                ),
              ),
              const SizedBox(height: 32),
              userAsync.when(
                data: (user) {
                  if (user?.nickname != null && _nicknameController.text.isEmpty) {
                    _nicknameController.text = user!.nickname!;
                  }
                  return TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.nickname,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text(AppLocalizations.of(context)!.errorLoadingProfile),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (userAddress == null) return;
                    
                    final nickname = _nicknameController.text.trim();
                    if (nickname.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.nicknameEmptyError)),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                       // Uniqueness Check
                       final isAvailable = await ref.read(userServiceProvider).isNicknameAvailable(nickname, userAddress);
                       if (!isAvailable) {
                         if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(AppLocalizations.of(context)!.nicknameTakenError)),
                           );
                         }
                         return;
                       }

                       await ref.read(userServiceProvider).updateNickname(
                         userAddress, 
                         nickname
                       );
                       if (mounted) { // Check if widget is still in tree
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(AppLocalizations.of(context)!.nicknameUpdated)),
                         );
                         // The stream will update automatically
                       }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : Text(AppLocalizations.of(context)!.saveNickname),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authServiceProvider).disconnect(ref);
                    Navigator.pop(context); // Go back to login/auth wrapper
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.disconnectWallet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
