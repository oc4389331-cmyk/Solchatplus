import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/chat/data/chat_repository.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/contacts/contact_repository.dart';
import 'package:solchat/features/solana/solana_service.dart';
import 'package:solchat/config/constants.dart';
import 'package:solchat/features/chat/screens/chat_screen.dart';
import 'package:solchat/features/profile/nft_avatar_picker_screen.dart';
import 'package:solchat/features/auth/widgets/user_display_name.dart';
import 'package:solchat/features/chat/data/local/app_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Data
  final _nameController = TextEditingController();
  String? _selectedGroupImageUrl;
  final Set<String> _selectedParticipants = {};
  String _selectedToken = 'SOL';
  bool _isCreating = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterGroupName)),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedParticipants.isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectAtLeastOneMember)),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _createGroup() async {
    setState(() => _isCreating = true);

    try {
      final userAddress = ref.read(userProvider);
      final solanaService = ref.read(solanaServiceProvider);
      
      final fee = _selectedToken == 'SOL' 
          ? AppConstants.chatCreationFeeSol 
          : AppConstants.chatCreationFeeSkr;

      // 1. Solicitud de Pago (Confirmation Dialog)
      final l10n = AppLocalizations.of(context)!;
      final confirmPayment = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.confirmPayment),
          content: Text(l10n.groupCreationFeeDesc(fee.toString(), _selectedToken)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.payAndCreate, style: const TextStyle(color: Color(0xFF14F195))),
            ),
          ],
        ),
      );

      if (confirmPayment != true) {
        setState(() => _isCreating = false);
        return;
      }

      // 2. Execute transaction
      String signature;
      if (_selectedToken == 'SOL') {
        signature = await solanaService.sendSolPayment(
          senderAddress: userAddress!,
          recipientAddress: AppConstants.projectFeeWallet, 
          amount: fee
        );
      } else {
        signature = await solanaService.sendSplPayment(
          senderAddress: userAddress!,
          mintAddress: AppConstants.skrMintAddress,
          recipientAddress: AppConstants.projectFeeWallet,
          amount: fee,
          decimals: AppConstants.skrDecimals,
        );
      }

      if (signature.isEmpty) throw Exception('Payment failed');

      // Create in Firestore & Local
      final participantsList = [userAddress!, ..._selectedParticipants];
      final chatId = await ref.read(chatRepositoryProvider).createGroup(
        name: _nameController.text.trim(),
        participants: participantsList,
        groupImage: _selectedGroupImageUrl,
        paymentSignature: signature,
        paymentToken: _selectedToken,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context); // Close create screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(chatId: chatId, isGroup: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_stepTitle(l10n)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _previousStep)
            : null,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentStep ? const Color(0xFF14F195) : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildIdentityStep(),
                    _buildMembersStep(),
                    _buildPaymentStep(),
                  ],
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0: return l10n.newGroupTitle;
      case 1: return l10n.addMembers;
      case 2: return l10n.confirmAndPay;
      default: return '';
    }
  }

  Widget _buildIdentityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                backgroundImage: _selectedGroupImageUrl != null 
                    ? NetworkImage(_selectedGroupImageUrl!) 
                    : null,
                child: _selectedGroupImageUrl == null 
                    ? const Icon(Icons.group, size: 60, color: Colors.white24) 
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF14F195),
                  child: IconButton(
                    icon: const Icon(Icons.photo_library, size: 20, color: Colors.black),
                    onPressed: () async {
                      final result = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NftAvatarPickerScreen(isSelectionMode: true),
                        ),
                      );
                      if (result != null) {
                        setState(() => _selectedGroupImageUrl = result);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.groupName,
              labelStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.edit, color: Color(0xFF14F195)),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF14F195))),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.groupIdentityDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersStep() {
    final suggestedAsync = ref.watch(suggestedMembersProvider);
    final userAddress = ref.read(userProvider);

    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.selectMembersDesc,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Expanded(
          child: suggestedAsync.when(
            data: (members) {
              // Filter out self
              final otherMembers = members.where((m) => m.address != userAddress).toList();
              if (otherMembers.isEmpty) {
                 return Center(child: Text(l10n.noContactsFound, style: const TextStyle(color: Colors.white38)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: otherMembers.length,
                itemBuilder: (context, index) {
                  final contact = otherMembers[index];
                  final isSelected = _selectedParticipants.contains(contact.address);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    activeColor: const Color(0xFF14F195),
                    checkColor: Colors.black,
                    title: UserDisplayName(
                      address: contact.address,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      contact.address.substring(0, 8) + '...',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedParticipants.add(contact.address);
                        } else {
                          _selectedParticipants.remove(contact.address);
                        }
                      });
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final l10n = AppLocalizations.of(context)!;
    const solFee = AppConstants.chatCreationFeeSol;
    const skrFee = AppConstants.chatCreationFeeSkr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.groupSummary, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _selectedGroupImageUrl != null ? NetworkImage(_selectedGroupImageUrl!) : null,
                  child: _selectedGroupImageUrl == null ? const Icon(Icons.group) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(l10n.membersSelected(_selectedParticipants.length), style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(l10n.paymentMethod, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTokenOption('SOL', '$solFee SOL'),
              const SizedBox(width: 15),
              _buildTokenOption('SKR', '$skrFee SKR'),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              l10n.groupCreationNotice,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenOption(String token, String label) {
    final isSelected = _selectedToken == token;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedToken = token),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF14F195).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? const Color(0xFF14F195) : Colors.white10),
          ),
          child: Column(
            children: [
              Text(token, style: TextStyle(color: isSelected ? const Color(0xFF14F195) : Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _isCreating ? null : (_currentStep < 2 ? _nextStep : _createGroup),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14F195),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isCreating 
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(
                  _currentStep < 2 ? l10n.next : l10n.createGroupAndPay,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
