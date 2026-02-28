import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/chat/screens/chat_screen.dart';
import 'package:solchat/models/user_model.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/contacts/contact_repository.dart';
import 'package:solchat/features/chat/data/chat_repository.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    final userService = ref.read(userServiceProvider);
    // NEW: Search local contacts first
    final contactRepo = ref.read(contactRepositoryProvider);
    
    // 1. Local Search
    final localContacts = await contactRepo.searchContacts(query);
    
    // 2. Global Search
    final globalResults = await userService.searchUsers(query);
    
    // 3. Merge Results
    // We want to prefer local contacts (custom names) over global results
    // We also want to include "Chatted Users" (users we have a chat with but no contact saved)
    final Map<String, UserModel> mergedMap = {};

    // A. Add global results first
    for (var user in globalResults) {
      mergedMap[user.address] = user;
    }

    // B. Search Active Chats (Unsaved users)
    final chatRepo = ref.read(chatRepositoryProvider);
    final allChats = await chatRepo.getChatsFuture();
    final currentUserAddress = ref.read(userProvider);
    
    for (var chat in allChats) {
       final participants = chat.participants.split(',');
       final otherAddress = participants.firstWhere(
         (p) => p != currentUserAddress, 
         orElse: () => ''
       );

       if (otherAddress.isNotEmpty) {
          // Check if matches query (contains, case-insensitive)
          if (otherAddress.toLowerCase().contains(query.toLowerCase())) {
             // If not already in map, add as "Unknown" (or use chat info if available? No, chat has no user name)
             if (!mergedMap.containsKey(otherAddress)) {
                mergedMap[otherAddress] = UserModel(
                  address: otherAddress,
                  nickname: '${l10n.chat} ${otherAddress.substring(0,4)}...${otherAddress.substring(otherAddress.length-4)}', // Temporary name
                );
                
                // OPTIONAL: We could fetch the real user profile here if we wanted to be fancy, 
                // but for now, showing the address is enough to find them.
                // userService.getUser(otherAddress).then(...) 
             }
          }
       }
    }

    // C. Add/Override with local contacts
    // If a local contact exists, we create a UserModel from it (or update existing)
    for (var contact in localContacts) {
      if (mergedMap.containsKey(contact.address)) {
        // Update existing global result ONLY if we have a non-empty CUSTOM name
        if (contact.customName != null && contact.customName!.isNotEmpty) {
          final existing = mergedMap[contact.address]!;
          mergedMap[contact.address] = existing.copyWith(nickname: contact.customName);
        }
      } else {
        // Create new entry from local contact (will use custom name or fallback)
        mergedMap[contact.address] = UserModel(
          address: contact.address,
          nickname: contact.customName != null && contact.customName!.isNotEmpty 
              ? contact.customName 
              : '${contact.address.substring(0, 4)}...${contact.address.substring(contact.address.length - 4)}',
        );
      }
    }
    
    // Convert back to list
    final results = mergedMap.values.toList();
    
    // Filter out current user
    final filteredResults = results.where((user) => user.address != currentUserAddress).toList();

    if (mounted) {
      setState(() {
        _results = filteredResults;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: const TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
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
      ),
      body: Stack(
        children: [
            // Background
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
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_results.isEmpty && _searchController.text.isNotEmpty)
             Center(
               child: Text(
                l10n.noUsersFound,
                style: const TextStyle(color: Colors.white54),
              ),
             )
          else
            ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final user = _results[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withValues(alpha: 0.3),
                    backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                        ? Text(
                            (user.nickname ?? user.address).substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(
                    user.nickname ?? l10n.unknownUser,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${user.address.substring(0, 4)}...${user.address.substring(user.address.length - 4)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () {
                    // Navigate to Chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: 'new', // Logic handled in ChatScreen or Repo to find existing chat
                          otherUserAddress: user.address,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
