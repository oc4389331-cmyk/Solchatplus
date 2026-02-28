import 'package:flutter/material.dart';
import 'package:solchat/main.dart' show navigatorKey;
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/chat/data/chat_repository.dart';
import 'package:solchat/features/chat/data/local/app_database.dart';
import 'package:solchat/config/constants.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/solana/solana_service.dart';
import 'package:solchat/models/user_model.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/auth/widgets/user_display_name.dart';
import 'package:solchat/features/chat/widgets/message_bubble.dart';
import 'package:solchat/features/chat/widgets/solana_pay_card.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';
import 'dart:convert';
import 'package:solchat/services/storage_service.dart';
import 'package:solchat/services/notification_service.dart';
import 'package:solchat/features/chat/screens/chat_list_screen.dart';
import 'package:solchat/features/chat/screens/full_screen_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solchat/features/contacts/contact_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? otherUserAddress;
  final bool isGroup;

  const ChatScreen({
    super.key, 
    required this.chatId, 
    this.otherUserAddress,
    this.isGroup = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _messagesSubscription;
  String? _currentUserAddress; // Store to avoid ref access in dispose

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Set active chat status immediately
    _currentUserAddress = ref.read(userProvider);
    _setStatus(true, activeChatId: widget.chatId);
    NotificationService().setActiveChatId(widget.chatId);

    // Initial read status update
    if (_currentUserAddress != null) {
      ref.read(chatRepositoryProvider).updateReadStatus(widget.chatId);
    }

    // Sync messages for this chat
    ref.read(chatRepositoryProvider).syncMessages(widget.chatId);

    // Listen for new messages to update read status reactively
    _listenToMessages();
  }

  void _listenToMessages() {
    // Correctly subscribe to messages and handle read status updates
    // We cancel any previous subscription to avoid leaks
    _messagesSubscription?.cancel();
    _messagesSubscription = ref.read(chatRepositoryProvider)
        .getMessages(widget.chatId)
        .listen((messages) {
          if (messages.isNotEmpty && mounted) {
            ref.read(chatRepositoryProvider).updateReadStatus(widget.chatId);
          }
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    
    // Set status to offline before clearing the service reference
    _setStatus(false, activeChatId: null);
    NotificationService().setActiveChatId(null);
    
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setStatus(true, activeChatId: widget.chatId);
      NotificationService().setActiveChatId(widget.chatId);
      ref.read(chatRepositoryProvider).updateReadStatus(widget.chatId);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // NOTE: We used to clear activeChatId here, but for Android bubbles we keep it
      // so the NotificationService still suppresses banners while the bubble is open.
      _setStatus(false, activeChatId: null);
      // NotificationService().setActiveChatId(null); <-- Removed to allow bubble suppression
    }
  }

  void _setStatus(bool isOnline, {String? activeChatId}) {
    // Use stored address to avoid ref.read(userProvider) in dispose/background states
    if (_currentUserAddress != null) {
      ref.read(userServiceProvider).updateOnlineStatus(
        _currentUserAddress!, 
        isOnline, 
        activeChatId: activeChatId
      );
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    final userAddress = ref.read(userProvider);
    if (userAddress == null) return;

    ref.read(chatRepositoryProvider).sendMessage(
      widget.chatId,
      userAddress,
      text: _controller.text.trim(),
      type: 'text',
    );
    _controller.clear();
  }

  Future<void> _pickImage() async {
    // Request permissions contextually
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      if (Platform.isAndroid) Permission.photos else Permission.photos, // Simplified for brevity, usually handled by OS versions
      Permission.storage,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cameraPermissionRequired)),
        );
      }
      return;
    }

    // Requires image_picker in pubspec.yaml
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final userAddress = ref.read(userProvider);
      if (userAddress == null) return;

      // Delegate compression, upload, and sending to Repository
      ref.read(chatRepositoryProvider).sendMessage(
        widget.chatId,
        userAddress,
        type: 'image',
        imageFile: File(pickedFile.path),
      );
    }
  }

  void _showPaymentDialog() {
    String selectedToken = 'SOL'; // Default
    
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final amountController = TextEditingController();
        String? amountError;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B1B3A), // Match theme
              title: Text(l10n.sendPayment, style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     DropdownButton<String>(
                      value: selectedToken,
                      dropdownColor: const Color(0xFF24243E),
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      items: [
                         DropdownMenuItem(value: 'SOL', child: Text(l10n.solanaToken)),
                         DropdownMenuItem(value: 'SKR', child: Text(l10n.seekerToken)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                             selectedToken = value;
                             amountError = null; // Clear error on token switch
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l10n.amountLabel(selectedToken),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Colors.white24),
                        prefixText: selectedToken == 'SOL' ? '◎ ' : '',
                        prefixStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF14F195))),
                        errorText: amountError,
                      ),
                      onChanged: (_) {
                         if (amountError != null) setState(() => amountError = null);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14F195),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final text = amountController.text.trim().replaceAll(',', '.');
                    final amount = double.tryParse(text);
                    
                    if (amount == null) {
                      setState(() => amountError = l10n.invalidNumber);
                      return;
                    }

                    if (amount <= 0) {
                      setState(() => amountError = l10n.amountGreaterThanZero);
                      return;
                    }

                    // Minimum Checks based on decimals
                    // SOL: 9 decimals -> min 0.000000001
                    // SKR: 6 decimals -> min 0.000001
                    if (selectedToken == 'SOL' && amount < 0.000000001) {
                       setState(() => amountError = l10n.minSolAmount);
                       return;
                    }
                    if (selectedToken == 'SKR' && amount < 0.000001) {
                       setState(() => amountError = l10n.minSkrAmount);
                       return;
                    }

                    Navigator.pop(context);
                    _sendPayment(amount, selectedToken);
                  },
                  child: Text(l10n.send),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _sendPayment(double amount, String token) async {
    // Trigger Solana Service
    try {
      final userAddress = ref.read(userProvider);
      if (userAddress == null) return;

      String result;
      if (token == 'SOL') {
         result = await ref.read(solanaServiceProvider).sendSolPayment(
          senderAddress: userAddress, 
          recipientAddress: widget.otherUserAddress!,
          amount: amount,
        );
      } else {
          result = await ref.read(solanaServiceProvider).sendSplPayment(
          senderAddress: userAddress,
          recipientAddress: widget.otherUserAddress!,
          mintAddress: AppConstants.skrMintAddress,
          amount: amount,
          decimals: AppConstants.skrDecimals,
        );
      }
      
      // Send "payment" message
      final l10n = AppLocalizations.of(context)!;
      ref.read(chatRepositoryProvider).sendMessage(
        widget.chatId,
        userAddress,
        type: 'payment',
        text: l10n.paymentSentMsg(amount, token),
        paymentAmount: amount,
        paymentToken: token,
        paymentSignature: result,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      String errorMessage = l10n.paymentFailed(e.toString());
      
      if (e.toString().contains('InvalidAccountData')) {
        errorMessage = l10n.invalidTokenAccount;
      } else if (e.toString().contains('InsufficientFundsForRent')) {
        errorMessage = l10n.insufficientFundsRent;
      } else if (e.toString().contains('-32002')) {
        // Only show generic 32002 if it's NOT one of the above specific ones
        errorMessage = l10n.blockchainError;
      } else if (e.toString().contains('Transaction declined')) {
        errorMessage = l10n.transactionCancelled;
      } else if (e.toString().contains('Blockhash not found')) {
        errorMessage = l10n.networkBusy;
      } else if (e.toString().contains('Recipient has not initialized')) {
        errorMessage = l10n.recipientNotInitialized;
      } else if (e.toString().contains('No SKR balance found')) {
        errorMessage = l10n.noSkrBalance;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showComingSoon(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon(feature))),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B3A),
          title: Text(l10n.saveToContacts, style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addContactDesc,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.customNameOptional,
                    labelStyle: const TextStyle(color: Colors.white60),
                    hintText: l10n.customNameHint,
                    hintStyle: const TextStyle(color: Colors.white24),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14F195),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                // Save even if name is empty (wallet is now tracked as contact)
                await ref.read(contactRepositoryProvider).saveContact(
                  widget.otherUserAddress!, 
                  name
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(name.isNotEmpty ? l10n.savedAs(name) : l10n.walletSaved),
                    ),
                  );
                  setState(() {}); 
                }
              },
              child: Text(l10n.saveContact),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyChatConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.emptyChatHistory),
          content: Text(l10n.emptyChatConfirmDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(chatRepositoryProvider).clearChatHistory(widget.chatId);
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.chatHistoryCleared)),
                  );
                }
              },
              child: Text(l10n.empty, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatRepo = ref.watch(chatRepositoryProvider);
    final userAddress = ref.read(userProvider);
    if (userAddress == null) return Scaffold(body: Center(child: Text(l10n.notAuthenticated)));

    // Watch both streams to react to block list changes from either side
    // Watch both streams to react to block list changes from either side
    final currentUserStream = ref.watch(userServiceProvider).getUserStream(userAddress);
    final otherUserStream = widget.isGroup 
        ? Stream.value(null) 
        : ref.watch(userServiceProvider).getUserStream(widget.otherUserAddress!);

    return StreamBuilder<UserModel?>(
      stream: currentUserStream,
      builder: (context, currentUserSnapshot) {
        final currentUser = currentUserSnapshot.data;
        final messagesStream = chatRepo.getMessages(widget.chatId);

        return StreamBuilder<UserModel?>(
          stream: otherUserStream,
          builder: (context, otherUserSnapshot) {
            final otherUser = otherUserSnapshot.data;
            final amIBlocked = !widget.isGroup && (otherUser?.blockedUsers.contains(userAddress) ?? false);
            final isBlocked = !widget.isGroup && (currentUser?.blockedUsers.contains(widget.otherUserAddress) ?? false);

            return StreamBuilder<List<LocalChat>>(
              stream: chatRepo.getChats(),
              builder: (context, chatSnapshot) {
                final chat = chatSnapshot.data?.where((c) => c.id == widget.chatId).firstOrNull;
                final isLocked = chat?.isLocked ?? false;
                Map<String, dynamic> roles = {};
                if (chat?.roles != null) {
                  try {
                    roles = jsonDecode(chat!.roles!);
                  } catch (_) {}
                }
                final myRole = roles[userAddress] ?? 'member';
                final isAdmin = widget.isGroup && myRole == 'admin';

                return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                    } else {
                      // Root of the stack (likely a bubble or direct notification open)
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const ChatListScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
        title: Row(
          children: [
            // Avatar
            InkWell(
              onTap: widget.isGroup ? null : () => _showWalletDetailsDialog(context, widget.otherUserAddress!),
              borderRadius: BorderRadius.circular(20),
              child: Consumer(
                builder: (context, ref, child) {
                  if (widget.isGroup) {
                    // Group Avatar logic
                    return CircleAvatar(
                      backgroundColor: const Color(0xFF14F195).withValues(alpha: 0.2),
                      child: const Icon(Icons.group, color: Colors.white),
                    );
                  }
                  final userAsync = ref.watch(userInfoProvider(widget.otherUserAddress!));
                  return CircleAvatar(
                    backgroundColor: Colors.purple.withValues(alpha: 0.2),
                    backgroundImage: (userAsync.value?.avatarUrl != null && userAsync.value!.avatarUrl!.isNotEmpty) 
                        ? NetworkImage(userAsync.value!.avatarUrl!) 
                        : null,
                    child: (userAsync.value?.avatarUrl == null || userAsync.value!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  );
                }
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: widget.isGroup ? null : () => _showWalletDetailsDialog(context, widget.otherUserAddress!),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use UserDisplayName here!
                      if (widget.isGroup)
                        StreamBuilder(
                          stream: ref.watch(chatRepositoryProvider).getChats(),
                          builder: (context, snapshot) {
                            final chat = snapshot.data?.firstWhere((c) => c.id == widget.chatId);
                            return Text(
                              chat?.name ?? 'Group',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          }
                        )
                      else
                        UserDisplayName(
                          address: widget.otherUserAddress!,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      // Online Status / Last Seen
                      // Online Status / Last Seen
                      if (!widget.isGroup)
                        StreamBuilder<UserModel?>(
                          stream: ref.watch(userServiceProvider).getUserStream(widget.otherUserAddress!),
                          builder: (context, snapshot) {
                            final user = snapshot.data;
                            final isOnline = user?.isOnline ?? false;
                            final lastSeen = user?.lastSeen;
              
                            String statusText = l10n.offline;
                            if (isOnline) {
                              statusText = l10n.online;
                            } else if (lastSeen != null) {
                              final diff = DateTime.now().difference(lastSeen);
                              if (diff.inMinutes < 60) {
                                  statusText = l10n.seenMinutesAgo(diff.inMinutes);
                              } else if (diff.inHours < 24) {
                                  statusText = l10n.seenHoursAgo(diff.inHours);
                              } else {
                                  statusText = l10n.offline;
                              }
                            }
                            
                            return Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isOnline ? const Color(0xFF14F195) : Colors.grey,
                                    boxShadow: isOnline ? [
                                      BoxShadow(
                                        color: const Color(0xFF14F195).withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ] : [],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    statusText,
                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Voice Call Button (Disable if blocked or group for now)
          if (!widget.isGroup && !isBlocked && !amIBlocked)
          FutureBuilder<bool>(
            future: Permission.microphone.isGranted,
            builder: (context, snapshot) {
              final micGranted = snapshot.data ?? false;
              
              return GestureDetector(
                onTap: !micGranted ? () async {
                  final status = await Permission.microphone.request();
                  if (status.isGranted) {
                    setState(() {}); // Rebuild to show the actual button
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.micPermissionRequired)),
                      );
                    }
                  }
                } : null,
                child: AbsorbPointer(
                  absorbing: !micGranted,
                  child: ZegoSendCallInvitationButton(
                    isVideoCall: false,
                    resourceID: "zegouikit_call", 
                    invitees: [
                      ZegoUIKitUser(
                        id: (widget.otherUserAddress!.length > 32) 
                            ? widget.otherUserAddress!.substring(0, 32) 
                            : widget.otherUserAddress!,
                        name: 'User', 
                      ),
                    ],
                    iconSize: const Size(30, 30),
                    buttonSize: const Size(40, 40),
                    icon: ButtonIcon(icon: const Icon(Icons.phone, color: Colors.white)),
                  ),
                ),
              );
            }
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF24243E),
            onSelected: (value) async {
              if (value == 'add_contact') {
                _showAddContactDialog();
              } else if (value == 'empty_chat') {
                _showEmptyChatConfirmation();
              } else if (value == 'block_user') {
                // Toggle block
                final userService = ref.read(userServiceProvider);
                if (isBlocked) {
                    await userService.unblockUser(userAddress, widget.otherUserAddress!);
                    if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.userUnblocked)));
                    }
                } else {
                    // Confirm block?
                    // For now direct block
                    await userService.blockUser(userAddress, widget.otherUserAddress!);
                    if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.userBlocked)));
                    }
                }
              } else if (value == 'manage_group') {
                _showManageGroupBottomSheet(chat, roles);
              } else if (value == 'leave_group') {
                _showLeaveGroupConfirmation();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (!widget.isGroup)
                  PopupMenuItem<String>(
                    value: 'add_contact',
                    child: Row(
                      children: [
                        const Icon(Icons.person_add, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(l10n.addToContacts, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                if (widget.isGroup && isAdmin)
                  PopupMenuItem<String>(
                    value: 'manage_group',
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(l10n.manageGroup, style: const TextStyle(color: Colors.amber)),
                      ],
                    ),
                  ),
                if (widget.isGroup && !isAdmin)
                  PopupMenuItem<String>(
                    value: 'leave_group',
                    child: Row(
                      children: [
                        const Icon(Icons.exit_to_app, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(l10n.leaveGroup, style: const TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'empty_chat',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.emptyChatHistory, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                if (!widget.isGroup)
                  PopupMenuItem<String>(
                    value: 'block_user',
                    child: Row(
                      children: [
                        Icon(isBlocked ? Icons.check_circle : Icons.block, color: isBlocked ? Colors.green : Colors.grey),
                        const SizedBox(width: 8),
                        Text(isBlocked ? l10n.unblockUser : l10n.blockUser, style: const TextStyle(color: Colors.white)),
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
          // Galaxy Background Gradient
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
          
          Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: messagesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final messages = (snapshot.data as List<LocalMessage>?) ?? [];
                    return ListView.builder(
                      reverse: true, // Show newest at bottom
                      padding: const EdgeInsets.only(top: 100, bottom: 20, left: 16, right: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == userAddress;

                        if (msg.type == 'payment') {
                          return SolanaPayCard(
                            amount: msg.paymentAmount ?? 0.0,
                            status: l10n.paymentConfirmed,
                            isMe: isMe,
                            tokenSymbol: msg.paymentToken,
                            signature: msg.paymentSignature,
                          );
                        }

                        if (msg.type == 'image') {
                           final bool hasLocal = msg.localImagePath != null && File(msg.localImagePath!).existsSync();

                           return GestureDetector(
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (_) => FullScreenImage(
                                     imageUrl: msg.imageTempUrl,
                                     imagePath: msg.localImagePath,
                                   ),
                                 ),
                               );
                             },
                             onLongPress: isMe ? () => _showDeleteMessageDialog(context, msg.id) : null,
                             child: Align(
                               alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                               child: Column(
                                 crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   if (!isMe && widget.isGroup)
                                     Padding(
                                       padding: const EdgeInsets.only(left: 20, bottom: 4, top: 4),
                                       child: UserDisplayName(
                                         address: msg.senderId, 
                                         style: const TextStyle(
                                           color: Color(0xFF14F195), 
                                           fontSize: 13, 
                                           fontWeight: FontWeight.bold
                                         )
                                       ),
                                     ),
                                   Container(
                                     margin: EdgeInsets.only(
                                       top: 4, 
                                       bottom: 8,
                                       left: isMe ? 0 : 16,
                                       right: isMe ? 16 : 0,
                                     ),
                                     width: 200,
                                     height: 200,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(16),
                                       color: Colors.black26,
                                     ),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(16),
                                   child: hasLocal 
                                     ? Image.file(
                                         File(msg.localImagePath!),
                                         fit: BoxFit.cover,
                                         errorBuilder: (ctx, err, stack) => _buildImageError(),
                                       )
                                     : (msg.imageTempUrl != null && msg.imageTempUrl!.isNotEmpty && msg.imageTempUrl != 'DELETED')
                                         ? msg.imageTempUrl!.startsWith('data:image/')
                                           ? Image.memory(
                                               base64Decode(msg.imageTempUrl!.split(',').last),
                                               fit: BoxFit.cover,
                                               errorBuilder: (ctx, err, stack) => _buildImageError(),
                                             )
                                           : CachedNetworkImage(
                                               imageUrl: msg.imageTempUrl!,
                                               fit: BoxFit.cover,
                                               placeholder: (context, url) => const Center(
                                                 child: CircularProgressIndicator(color: Color(0xFF14F195)),
                                               ),
                                               errorWidget: (context, url, error) => _buildImageError(),
                                             )
                                         : _buildImageError(),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       );
                    }

                        return MessageBubble(
                          text: msg.textContent ?? '',
                          timestamp: msg.timestamp,
                          isMe: isMe,
                          onLongPress: isMe ? () => _showDeleteMessageDialog(context, msg.id) : null,
                          senderNameWidget: (!isMe && widget.isGroup) 
                            ? UserDisplayName(
                                address: msg.senderId, 
                                style: const TextStyle(
                                  color: Color(0xFF14F195), // Solana Green for names
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold
                                )
                              )
                            : null,
                        );
                      },
                    );
                  },
                ),
              ),
              
              // Input Area
              (isBlocked || amIBlocked) 
              ? Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  width: double.infinity,
                  child: Text(
                    isBlocked 
                        ? l10n.youBlockedUser
                        : l10n.userBlockedYou,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                )
              : (widget.isGroup && isLocked && !isAdmin)
              ? Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  width: double.infinity,
                  child: Text(
                    l10n.onlyAdminsCanMessage,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 10), // Adjust bottom spacing as requested
                child: SafeArea( // Ensure it doesn't overlap with home gestures
                  child: Row(
                    children: [
                      // Removed Icons.add_circle as requested
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: l10n.typeMessage,
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Solana/Money Button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.attach_money, color: Color(0xFF14F195)), // Solana Green
                        onPressed: _showPaymentDialog,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.image, color: Colors.white70),
                        onPressed: _pickImage,
                      ),
                      // Send Button
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF9945FF), // Solana Purple
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
                );
              }
            );
          }
        );
      }
    );
  }

  void _showWalletDetailsDialog(BuildContext context, String walletAddress) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B3A),
          title: Text(l10n.walletDetails, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.addressLabel, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              SelectableText(
                walletAddress,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: walletAddress));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.copyAddressClipboard)),
                );
              },
              child: Text(l10n.copy, style: const TextStyle(color: Color(0xFF14F195))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close, style: const TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteMessageDialog(BuildContext context, String messageId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B3A),
          title: Text(l10n.deleteMessageConfirm, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.deleteMessageDesc,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                try {
                  await ref.read(chatRepositoryProvider).deleteMessage(widget.chatId, messageId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.messageDeleted)),
                    );
                  }
                } catch (e) {
                  print('Delete error details: $e');
                  String errorMessage = l10n.failedToDelete;
                  if (e.toString().contains('permission-denied')) {
                    errorMessage = l10n.noPermission;
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveGroupConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B3A),
          title: Text(l10n.leaveGroup, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.confirmLeaveGroup,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close chat screen
                await ref.read(chatRepositoryProvider).leaveGroup(widget.chatId);
              },
              child: Text(l10n.leaveGroup, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showManageGroupBottomSheet(LocalChat? chat, Map<String, dynamic> roles) {
    if (chat == null) return;
    final l10n = AppLocalizations.of(context)!;
    final participantsList = chat.participants?.split(',') ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            final isLocked = chat.isLocked ?? false;

            return SafeArea(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Text(l10n.manageGroup, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24),
                    
                    // Lock Toggle
                    SwitchListTile(
                      title: Text(l10n.lockGroup, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(l10n.onlyAdminsCanMessage, style: const TextStyle(color: Colors.white54)),
                      value: isLocked,
                      activeColor: const Color(0xFF14F195),
                      onChanged: (val) async {
                        await ref.read(chatRepositoryProvider).toggleGroupLock(widget.chatId, val);
                        if (context.mounted) Navigator.pop(context); // close to see effect quickly
                      },
                    ),
                    const Divider(color: Colors.white24),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF14F195),
                        child: Icon(Icons.person_add, color: Colors.black, size: 20),
                      ),
                      title: Text(l10n.addMembers, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                         Navigator.pop(context);
                         _showAddMemberDialog(chat);
                      },
                    ),
                    
                    // Participants Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l10n.groupMembers, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    // Participant List
                    Expanded(
                      child: ListView.builder(
                        itemCount: participantsList.length,
                        itemBuilder: (context, index) {
                          final p = participantsList[index];
                          final pRole = roles[p] ?? 'member';
                          final isMe = p == ref.read(userProvider);
                          
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                            title: UserDisplayName(
                              address: p,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(pRole.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            trailing: (isMe || pRole == 'admin') ? null : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 20),
                                  onPressed: () async {
                                    await ref.read(chatRepositoryProvider).grantAdminRole(widget.chatId, p);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person_remove, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    await ref.read(chatRepositoryProvider).removeUserFromGroup(widget.chatId, p);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            );
          }
        );
      },
    );
  }

  void _showAddMemberDialog(LocalChat chat) {
    final addressController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B3A),
          title: Text(l10n.addMembers, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: addressController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.enterWalletAddress,
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                final addr = addressController.text.trim();
                // Basic Solana address check (length ~44)
                if (addr.isNotEmpty && addr.length > 30) {
                  Navigator.pop(context);
                  await ref.read(chatRepositoryProvider).addUserToGroup(widget.chatId, addr);
                }
              },
              child: Text(l10n.addMembers, style: const TextStyle(color: Color(0xFF14F195))),
            ),
          ],
        );
      }
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, color: Colors.white24, size: 40),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.imageError,
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
