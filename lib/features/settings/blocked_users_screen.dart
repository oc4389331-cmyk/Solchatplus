import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/auth/widgets/user_display_name.dart';
import 'package:solchat/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAddress = ref.watch(userProvider);
    final l10n = AppLocalizations.of(context)!;
    if (userAddress == null) return Scaffold(body: Center(child: Text(l10n.notAuthenticated)));

    final userStream = ref.watch(userProfileProvider(userAddress));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blockedUsers),
        backgroundColor: const Color(0xFF1B1B3A),
      ),
      backgroundColor: const Color(0xFF0F0C29),
      body: userStream.when(
        data: (user) {
          if (user == null || user.blockedUsers.isEmpty) {
            return Center(
              child: Text(
                l10n.noBlockedUsers,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: user.blockedUsers.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final blockedAddress = user.blockedUsers[index];
              return _BlockedUserTile(address: blockedAddress, currentAddress: userAddress);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _BlockedUserTile extends ConsumerWidget {
  final String address;
  final String currentAddress;

  const _BlockedUserTile({required this.address, required this.currentAddress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Consumer(
        builder: (context, ref, child) {
          final userAsync = ref.watch(userInfoProvider(address));
          return CircleAvatar(
            backgroundColor: Colors.purple.withValues(alpha: 0.2),
            backgroundImage: (userAsync.value?.avatarUrl != null && userAsync.value!.avatarUrl!.isNotEmpty)
                ? NetworkImage(userAsync.value!.avatarUrl!)
                : null,
            child: (userAsync.value?.avatarUrl == null || userAsync.value!.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white70)
                : null,
          );
        },
      ),
      title: UserDisplayName(
        address: address,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: TextButton(
        onPressed: () => _unblockUser(context, ref),
        child: Text(AppLocalizations.of(context)!.unblockButton, style: const TextStyle(color: Color(0xFF14F195))),
      ),
    );
  }

  Future<void> _unblockUser(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unblockUserConfirm),
        content: Text(l10n.unblockUserDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.unblockUser),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(userServiceProvider).unblockUser(currentAddress, address);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userUnblocked)),
        );
      }
    }
  }
}
