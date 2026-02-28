import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/chat/data/chat_repository.dart';
import 'package:solchat/features/chat/screens/chat_screen.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/solana/solana_service.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/auth/widgets/user_display_name.dart';
import 'package:solchat/features/profile/profile_screen.dart';
import 'package:solchat/features/call/call_service.dart';
import 'package:solchat/services/notification_provider.dart';
import 'package:solchat/features/chat/screens/scan_qr_screen.dart';
import 'package:solchat/features/settings/settings_screen.dart';
import 'package:solchat/features/search/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solchat/features/chat/widgets/spotlight_overlay.dart';
import 'package:solchat/features/chat/screens/create_group_screen.dart';
import 'package:solchat/features/chat/widgets/solana_border_painter.dart';
import 'package:solchat/features/games/referred_games_screen.dart';
import 'package:solchat/features/settings/about_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final showNewChatHintProvider = StateProvider<bool>((ref) => false);

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHint();
    });
  }

  void _checkHint() {
    if (!mounted) return;
    
    // SAFETY: Only show tutorial if this screen is the TOP ROUTE
    // This prevents the assertion error if we are already in a chat
    if (ModalRoute.of(context)?.isCurrent != true) {
      SpotlightOverlay.hide();
      return;
    }

    final showHint = ref.read(showNewChatHintProvider);
    if (showHint) {
      _pulseController.repeat(reverse: true);
      final l10n = AppLocalizations.of(context)!;
      SpotlightOverlay.show(
        context,
        targetKey: _fabKey,
        message: l10n.tutorialMessage,
        onDismiss: () {
          ref.read(showNewChatHintProvider.notifier).state = false;
          _pulseController.stop();
          _pulseController.reset();
          // Mark as seen in Firestore
          final userAddress = ref.read(userProvider);
          if (userAddress != null) {
            ref.read(userServiceProvider).markTutorialAsSeen(userAddress);
          }
        },
      );
    } else {
      SpotlightOverlay.hide();
    }
  }

  @override
  void dispose() {
    SpotlightOverlay.hide();
    // Unregister Zego service to prevent connection loops/leaks
    ref.read(callServiceProvider).uninitService();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final userAddress = ref.watch(userProvider);
    final chatsStream = chatRepo.getChats();
    final l10n = AppLocalizations.of(context)!;

    // Reactively handle tutorial show/hide
    ref.listen(showNewChatHintProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkHint());
    });

    // Automatically trigger tutorial for first-time users (or those who haven't seen it)
    if (userAddress != null) {
      ref.listen(userInfoProvider(userAddress), (previous, next) {
        final user = next.value;
        if (user != null && !user.hasSeenTutorial && !ref.read(showNewChatHintProvider)) {
          // Trigger after a small delay to ensure UI is ready
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              ref.read(showNewChatHintProvider.notifier).state = true;
            }
          });
        }
      });
    }

    return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
        title: Text(l10n.chats, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => const SearchScreen()),
               );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF14F195)),
            onPressed: () async {
               // Open Scan Screen
               final result = await Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => const ScanQRScreen()),
               );

               if (result != null && result is String) {
                 if (result.length < 32 || result.length > 44) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invalidAddress)),
                    );
                    return;
                 }
                 
                   // Open Chat with scanned address
                 try {
                   final userAddress = ref.read(userProvider);
                   // Create/Get chat (this unhides it if it was hidden)
                   final chatId = await ref.read(chatRepositoryProvider).createChat(
                     userAddress!, 
                     result
                   );
                   
                   if (context.mounted) {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            otherUserAddress: result,
                          ),
                        ),
                     );
                   }
                 } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(l10n.errorOpeningChat(e.toString()))),
                   );
                 }
               }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF24243E),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              } else if (value == 'new_group') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
              } else if (value == 'games') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReferredGamesScreen()),
                );
              } else if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'new_group',
                  child: Row(
                    children: [
                      const Icon(Icons.group_add, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(l10n.newGroup, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(l10n.settings, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'games',
                  child: Row(
                    children: [
                      const Icon(Icons.sports_esports, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(l10n.referredGames, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'about',
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(l10n.aboutTitle, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Galaxy Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29), // Deep Dark Blue/Black
                  Color(0xFF302B63), // Rich Purple/Blue
                  Color(0xFF24243E), // Dark Slate
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: chatsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                 return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              final chats = snapshot.data ?? [];
              if (chats.isEmpty) {
                return Center(child: Text(l10n.noChatsYet, style: const TextStyle(color: Colors.white70)));
              }

              return ListView.builder(
                // Add padding for AppBar + List content
                padding: const EdgeInsets.only(top: kToolbarHeight + 20),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final isGroup = chat.isGroup;
                  final otherParticipant = isGroup 
                      ? '' 
                      : chat.participants.split(',').firstWhere((p) => p != userAddress, orElse: () => 'Unknown');

                    return StreamBuilder<bool>(
                      stream: ref.read(chatRepositoryProvider).watchUnreadStatus(chat.id),
                      initialData: false,
                      builder: (context, unreadSnapshot) {
                        final hasUnread = unreadSnapshot.data ?? false;

                        return ListTile(
                          leading: SolanaAnimatedBorder(
                            isActive: hasUnread,
                            child: Consumer(
                              builder: (context, ref, child) {
                                if (isGroup) {
                                  return CircleAvatar(
                                    backgroundColor: const Color(0xFF14F195).withOpacity(0.3),
                                    backgroundImage: chat.groupImage != null ? NetworkImage(chat.groupImage!) : null,
                                    child: chat.groupImage == null 
                                        ? const Icon(Icons.group, color: Colors.white) 
                                        : null,
                                  );
                                }
                                final userAsync = ref.watch(userInfoProvider(otherParticipant));
                                return CircleAvatar(
                                  backgroundColor: Colors.purple.withOpacity(0.3),
                                  backgroundImage: (userAsync.value?.avatarUrl != null && userAsync.value!.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(userAsync.value!.avatarUrl!)
                                      : null,
                                  child: (userAsync.value?.avatarUrl == null || userAsync.value!.avatarUrl!.isEmpty)
                                      ? Text(
                                          otherParticipant.substring(0, 2).toUpperCase(),
                                          style: const TextStyle(color: Colors.white),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                          title: isGroup 
                            ? Text(chat.name ?? l10n.appName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                            : UserDisplayName(
                                address: otherParticipant,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                          subtitle: Text(
                            chat.lastMessage ?? l10n.lastMessageNone,
                            style: const TextStyle(color: Colors.white60),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (chat.lastMessageTime != null)
                                Text(
                                  '${chat.lastMessageTime!.hour}:${chat.lastMessageTime!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),

                            ],
                          ),
                          onTap: () {
                            // Dismiss hint if navigating away
                            if (ref.read(showNewChatHintProvider)) {
                              ref.read(showNewChatHintProvider.notifier).state = false;
                              _pulseController.stop();
                            }
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat.id, 
                                  otherUserAddress: isGroup ? null : otherParticipant,
                                  isGroup: isGroup,
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                               showModalBottomSheet(
                                context: context,
                                backgroundColor: const Color(0xFF1B1B3A),
                                builder: (context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: Text(l10n.deleteChat, style: const TextStyle(color: Colors.red)),
                                          onTap: () async {
                                            Navigator.pop(context); // Close sheet
                                            
                                            // Confirm dialog
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(l10n.deleteChatConfirm),
                                                content: Text(l10n.deleteChatDesc),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text(l10n.cancel),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            
                                            if (confirm == true) {
                                               await ref.read(chatRepositoryProvider).deleteChat(chat.id);
                                               if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(l10n.chatDeleted)),
                                                  );
                                               }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                          },
                        );
                      },
                    );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut,
        )),
        child: FloatingActionButton(
            key: _fabKey,
            backgroundColor: const Color(0xFF14F195), // Solana Green
            foregroundColor: Colors.black,
            onPressed: () {
              // Reset hint
              if (ref.read(showNewChatHintProvider)) {
                ref.read(showNewChatHintProvider.notifier).state = false;
                _pulseController.stop();
                _pulseController.reset();
                // Mark as seen in Firestore
                final userAddress = ref.read(userProvider);
                if (userAddress != null) {
                  ref.read(userServiceProvider).markTutorialAsSeen(userAddress);
                }
              }
              // Show options sheet
              _showNewChatOptions(context);
            },
            child: const Icon(Icons.add),
          ),
      ),
    );
  }

    void _showNewChatOptions(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1B1B3A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF14F195),
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(l10n.newChatPrivate, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateChatDialog(context, ref);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.group_add, color: Colors.white),
                  ),
                  title: Text(l10n.newGroup, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(l10n.createCommunityDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    }

    void _showCreateChatDialog(BuildContext context, WidgetRef ref) {
    final addressController = TextEditingController(); // In real app, dispose this
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newChat),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: l10n.enterWalletAddress,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF14F195)),
                      onPressed: () async {
                         // Open Scan Screen
                         final result = await Navigator.push(
                           context,
                           MaterialPageRoute(builder: (_) => const ScanQRScreen()),
                         );
  
                         if (result != null && result is String) {
                           if (result.length < 32 || result.length > 44) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.invalidAddress)),
                              );
                              return;
                           }
                           // Populate the text field
                           addressController.text = result;
                         }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final recipient = addressController.text.trim();
                if (recipient.isEmpty) return;

                Navigator.pop(context); // Close dialog

                try {
                  final userAddress = ref.read(userProvider);
                  // Create Chat (Always public now)
                  final chatId = await ref.read(chatRepositoryProvider).createChat(
                    userAddress!, 
                    recipient, 
                    isPrivate: false 
                  );

                  // Navigate to new chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId, otherUserAddress: recipient),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.failedToCreateChat(e.toString()))),
                  );
                }
              },
              child: Text(l10n.startChat),
            ),
          ],
        );
      },
    );
  }
}
