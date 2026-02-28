import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/profile/nft_service.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NftAvatarPickerScreen extends ConsumerWidget {
  final bool isSelectionMode;
  const NftAvatarPickerScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAddress = ref.watch(userProvider);
    final nftService = ref.watch(nftServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    if (userAddress == null) {
      return Scaffold(body: Center(child: Text(l10n.notAuthenticated)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectNftAvatar)),
      body: FutureBuilder<List<NftModel>>(
        future: nftService.fetchUserNfts(userAddress),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorLoadingNfts(snapshot.error.toString())));
          }
          
          final nfts = snapshot.data ?? [];
          if (nfts.isEmpty) {
            return Center(child: Text(l10n.noNftsFound));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: nfts.length,
            itemBuilder: (context, index) {
              final nft = nfts[index];
              return GestureDetector(
                onTap: () async {
                  if (isSelectionMode) {
                    Navigator.pop(context, nft.imageUrl);
                    return;
                  }
                  
                  // Update user profile
                  await ref.read(userServiceProvider).updateProfileImage(userAddress, nft.imageUrl);
                  if (context.mounted) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(l10n.avatarUpdated)),
                     );
                  }
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          nft.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          nft.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
