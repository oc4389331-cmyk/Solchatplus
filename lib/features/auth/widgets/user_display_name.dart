import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/contacts/contact_repository.dart';

class UserDisplayName extends ConsumerWidget {
  final String address;
  final TextStyle? style;

  const UserDisplayName({
    super.key,
    required this.address,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userInfoProvider(address));
    final contactNameAsync = ref.watch(contactNameProvider(address));

    return contactNameAsync.when(
      data: (customName) {
        if (customName != null && customName.isNotEmpty) {
          return Text(
            customName,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        
        // Fallback to server nickname
        return userAsync.when(
          data: (user) {
            final displayName = user?.nickname != null && user!.nickname!.isNotEmpty
                ? user.nickname!
                : address.length > 8 
                    ? '${address.substring(0, 4)}...${address.substring(address.length - 4)}'
                    : address;
            
            return Text(
              displayName,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
          loading: () => Text(
            'Loading...',
            style: style?.copyWith(color: Colors.grey),
          ),
          error: (_, __) => Text(
            address.length > 8 
                ? '${address.substring(0, 4)}...${address.substring(address.length - 4)}'
                : address,
            style: style,
          ),
        );
      },
      loading: () => Text(
        '...',
        style: style?.copyWith(color: Colors.grey),
      ),
      error: (_, __) => Text(
        address.length > 8 
            ? '${address.substring(0, 4)}...${address.substring(address.length - 4)}'
            : address,
        style: style,
      ),
    );
  }
}
