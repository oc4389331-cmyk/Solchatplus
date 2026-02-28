import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/solana.dart';
import 'package:solana/base58.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'package:solana/encoder.dart';
import 'package:solana/dto.dart' show Encoding; // Only import Encoding to avoid Instruction conflict
import 'package:solchat/config/constants.dart';
import 'package:solchat/features/auth/auth_service.dart'; // To get current user wallet/connection
import 'dart:typed_data';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

final solanaServiceProvider = Provider((ref) => SolanaService(ref));

class SolanaService {
  final Ref _ref;
  static const _rpcUrl = 'https://YOUR_HELIUS_RPC_URL_HERE';
  static const _wsUrl = 'wss://YOUR_HELIUS_WS_URL_HERE';

  final SolanaClient _client = SolanaClient(
    rpcUrl: Uri.parse(_rpcUrl),
    websocketUrl: Uri.parse(_wsUrl),
  );

  SolanaService(this._ref);

  Future<String> sendSolPayment({
    required String senderAddress,
    required String recipientAddress,
    required double amount,
  }) async {
    // 1. Setup - Get Blockhash and Lamports
    final lamports = (amount * 1000000000).toInt();
    final feeLamports = (AppConstants.transactionFee * 1000000000).toInt();
    
    final blockhash = await _client.rpcClient.getLatestBlockhash();

    // 2. Create Instructions
    // Main Transfer
    final instruction1 = SystemInstruction.transfer(
      fundingAccount: Ed25519HDPublicKey.fromBase58(senderAddress), 
      recipientAccount: Ed25519HDPublicKey.fromBase58(recipientAddress),
      lamports: lamports,
    );

    // Project Fee Transfer
    final instruction2 = SystemInstruction.transfer(
      fundingAccount: Ed25519HDPublicKey.fromBase58(senderAddress),
      recipientAccount: Ed25519HDPublicKey.fromBase58(AppConstants.projectFeeWallet),
      lamports: feeLamports,
    );

    // 3. Compile Transaction Message
    final message = Message(instructions: [instruction1, instruction2]);
    final compiledMessage = message.compile(
      recentBlockhash: blockhash.value.blockhash, 
      feePayer: Ed25519HDPublicKey.fromBase58(senderAddress),
    );

    // 4. Create Transaction Object (Wire Format)
    // We need to wrap the message in a Transaction structure with dummy signatures
    // so the wallet can parse it correctly.
    final numSignatures = compiledMessage.header.numRequiredSignatures;
    final dummySignatures = List.generate(
      numSignatures, 
      (_) => Signature(List.filled(64, 0), publicKey: Ed25519HDPublicKey.fromBase58(senderAddress)),
    );
    
    final transaction = SignedTx(
      compiledMessage: compiledMessage,
      signatures: dummySignatures,
    );

    // 5. MWA: Connect and Send
    final scenario = await LocalAssociationScenario.create();
    scenario.startActivityForResult(null); // Launch wallet

    try {
      final client = await scenario.start();
      
      // Re-authorize using the stored address check if possible, or just re-authorize as new session
      final authResult = await client.authorize(
        identityUri: Uri.parse('https://solchat.app'), 
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'SolChat',
        cluster: 'mainnet-beta',
      );

      if (authResult?.publicKey == null) {
        throw Exception('Wallet authorization failed');
      }

      // Convert compiled transaction (with dummy sigs) to Uint8List for MWA
      final txBytes = Uint8List.fromList(transaction.toByteArray().toList());

      // 1. Request Signature Only
      final signedResult = await client.signTransactions(
        transactions: [txBytes],
      );

      if (signedResult.signedPayloads.isEmpty) {
         throw Exception('Transaction declined (Signing failed)');
      }

      final signedTxBytes = signedResult.signedPayloads.first;

      // 2. Broadcast via our manual HTTP method to ensure correct encoding
      final signature = await _broadcastTransaction(convert.base64Encode(signedTxBytes));
      
      return signature;

    } finally {
      await scenario.close();
    }
  }

  // Manual RPC call to bypass package encoding issues
  Future<String> _broadcastTransaction(String base64Tx) async {
    final response = await http.post(
      Uri.parse(_rpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode({
        "jsonrpc": "2.0",
        "id": DateTime.now().millisecondsSinceEpoch,
        "method": "sendTransaction",
        "params": [
          base64Tx,
          {
            "encoding": "base64",
            "preflightCommitment": "confirmed"
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('RPC Error: ${response.statusCode} - ${response.body}');
    }

    final json = convert.jsonDecode(response.body);
    if (json['error'] != null) {
      throw Exception('Blockchain Error: ${json['error']['message']}');
    }

    return json['result'] as String;
  }

  // Manual Account Info check to bypass package encoding issues
  Future<bool> _manualGetAccountInfo(String address) async {
    try {
      final response = await http.post(
        Uri.parse(_rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({
          "jsonrpc": "2.0",
          "id": DateTime.now().millisecondsSinceEpoch,
          "method": "getAccountInfo",
          "params": [
            address,
            {
              "encoding": "base64"
            }
          ]
        }),
      );
      
      if (response.statusCode != 200) {
         print('DEBUG: getAccountInfo failed with status ${response.statusCode}');
         return false; 
      }
      
      final json = convert.jsonDecode(response.body);
      if (json['error'] != null) {
         print('DEBUG: getAccountInfo failed with error ${json['error']}');
         return false;
      }
      
      final value = json['result']['value'];
      return value != null;
    } catch (e) {
      print('DEBUG: getAccountInfo exception: $e');
      return false;
    }
  }

  Future<String> sendSplPayment({
    required String senderAddress,
    required String recipientAddress,
    required String mintAddress,
    required double amount,
    int decimals = 9,
  }) async {
    final sender = Ed25519HDPublicKey.fromBase58(senderAddress);
    final recipient = Ed25519HDPublicKey.fromBase58(recipientAddress);
    final mint = Ed25519HDPublicKey.fromBase58(mintAddress);

    // 1. Get Blockhash
    final blockhash = await _client.rpcClient.getLatestBlockhash();

    // 2. Derive ATAs
    // Reverting to standard ATA derivation to fix compilation error.
    // If InvalidAccountData persists, we might need to verify if the sender uses a non-standard account.
    final senderAta = await findAssociatedTokenAddress(
      owner: sender,
      mint: mint,
    );
    
    // Check if Sender ATA exists (Crucial Fix for InvalidAccountData)
    // Using manual check to bypass potential encoding issues in library
    final senderExists = await _manualGetAccountInfo(senderAta.toBase58());

    if (!senderExists) {
       throw Exception('Your SKR wallet is not initialized. Please receive at least 1 SKR from another wallet to activate it.');
    }

    // 3. Derive Recipient ATA
    final recipientAta = await findAssociatedTokenAddress(
      owner: recipient,
      mint: mint,
    );

    // 3. Check if Recipient ATA exists
    final recipientExists = await _manualGetAccountInfo(recipientAta.toBase58());

    final instructions = <Instruction>[];

    // 4. Check if Recipient ATA exists
    if (!recipientExists) {
      // User policy: Do NOT create ATA for recipient to avoid rent drain.
      // Recipient must initialize their own token account.
      throw Exception('Recipient has not initialized their SKR wallet.');
    }

    // 5. Add SPL Transfer Instruction
    final rawAmount = (amount * pow(10, decimals)).toInt();
    
    instructions.add(
      TokenInstruction.transfer(
        source: senderAta,
        destination: recipientAta,
        owner: sender,
        amount: rawAmount,
      ),
    );

    // 6. Add Project Fee (SOL)
    final feeLamports = (AppConstants.transactionFee * 1000000000).toInt();
    instructions.add(
      SystemInstruction.transfer(
        fundingAccount: sender,
        recipientAccount: Ed25519HDPublicKey.fromBase58(AppConstants.projectFeeWallet),
        lamports: feeLamports,
      ),
    );

    // 7. Compile Message
    final message = Message(instructions: instructions.cast<Instruction>()); // Ensure cast just in case
    final compiledMessage = message.compile(
      recentBlockhash: blockhash.value.blockhash,
      feePayer: sender,
    );

    // 8. Create Transaction and Sign/Send via MWA
    final numSignatures = compiledMessage.header.numRequiredSignatures;
    final dummySignatures = List.generate(
      numSignatures, 
      (_) => Signature(List.filled(64, 0), publicKey: sender),
    );
    
    final transaction = SignedTx(
      compiledMessage: compiledMessage,
      signatures: dummySignatures,
    );

    final scenario = await LocalAssociationScenario.create();
    scenario.startActivityForResult(null);

    try {
      final client = await scenario.start();
      
      final authResult = await client.authorize(
        identityUri: Uri.parse('https://solchat.app'), 
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'SolChat',
        cluster: 'mainnet-beta',
      );

      if (authResult?.publicKey == null) {
        throw Exception('Wallet authorization failed');
      }

      final txBytes = Uint8List.fromList(transaction.toByteArray().toList());

      // 1. Request Signature Only
      final signedResult = await client.signTransactions(
        transactions: [txBytes],
      );

      if (signedResult.signedPayloads.isEmpty) {
         throw Exception('Transaction declined (Signing failed)');
      }
      
      final signedTxBytes = signedResult.signedPayloads.first;

      // 2. Broadcast via our manual HTTP method
      final signature = await _broadcastTransaction(convert.base64Encode(signedTxBytes));

      return signature;

    } finally {
      await scenario.close();
    }
  }

  Future<String> payChatCreationFee(String senderAddress) async {
    // Similar logic for chat creation fee
    return 'mock_creation_signature';
  }
}
