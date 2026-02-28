import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:http/http.dart' as http;
import 'package:solchat/config/constants.dart';

final nftServiceProvider = Provider((ref) => NftService());

class NftModel {
  final String mintAddress;
  final String name;
  final String imageUrl;

  NftModel({required this.mintAddress, required this.name, required this.imageUrl});
}

class NftService {
  // Mainnet RPC
  final SolanaClient _client = SolanaClient(
    rpcUrl: Uri.parse('https://YOUR_HELIUS_RPC_URL_HERE'),
    websocketUrl: Uri.parse('wss://YOUR_HELIUS_WS_URL_HERE'),
  );

  static const String _metaplexProgramId = 'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';

  Future<List<NftModel>> fetchUserNfts(String walletAddress) async {
    try {
      final pubKey = Ed25519HDPublicKey.fromBase58(walletAddress);



      // Define programs to check
      final programs = [
        'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA', // Token Program
        'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb', // Token-2022
      ];

      final List<ProgramAccount> allTokenAccounts = [];

      for (final programId in programs) {
        try {
          final accounts = await _client.rpcClient.getTokenAccountsByOwner(
            walletAddress,
            TokenAccountsFilter.byProgramId(programId),
            encoding: Encoding.jsonParsed,
          );
          if (accounts.value.isNotEmpty) {

             allTokenAccounts.addAll(accounts.value);
          }
        } catch (e) {
          print('Error fetching for program $programId: $e');
        }
      }


      final List<NftModel> nfts = [];

      for (var account in allTokenAccounts) {
        final dynamic data = account.account.data;
        dynamic parsed;
        try {
          // Attempt to access 'parsed' field dynamically to handle both 
          // ParsedSplTokenProgramAccountData and ParsedSplToken2022ProgramAccountData
          parsed = data.parsed;
        } catch (e) {
          // If data is binary or doesn't have 'parsed', skip it
          continue;
        }
        
        String amount;
        int decimals;
        String mintAddress;
        
        try {
          if (parsed is Map<String, dynamic>) {
             final info = parsed['info'] as Map<String, dynamic>;
             amount = info['tokenAmount']['amount'];
             decimals = info['tokenAmount']['decimals'];
             mintAddress = info['mint'];
          } else {
             final info = parsed.info;
             final tokenAmount = info.tokenAmount;
             amount = tokenAmount.amount;
             decimals = tokenAmount.decimals;
             mintAddress = info.mint;
          }



          // Filter for NFTs (Amount = 1, Decimals = 0)
          if ((amount == '1' || amount == '1.0') && decimals == 0) {

            final nft = await _fetchNftMetadata(mintAddress);
            if (nft != null) {

              nfts.add(nft);
            }
          }
        } catch (e) {
             print('Error parsing account data: $e');
        }
      }




      // 2. Fetch Compressed NFTs (cNFTs) via DAS API
      try {
        final cNfts = await _fetchCompressedNfts(walletAddress);
        nfts.addAll(cNfts);
      } catch (e) {
        print('Error fetching cNFTs: $e');
      }


      return nfts;
    } catch (e) {
      print('Error fetching NFTs: $e');
      return [];
    }
  }

  Future<List<NftModel>> _fetchCompressedNfts(String walletAddress) async {
    // Only works if the configured RPC supports DAS API (e.g. Helius, Triton)
    // api.mainnet-beta.solana.com DOES NOT SUPPORT THIS.
    
    // Check if using default non-DAS RPC
    if (AppConstants.solanaDasApiUrl.contains('api.mainnet-beta')) {
      print('Skipping cNFT fetch: configured RPC does not support DAS API.');
      return [];
    }

    try {
      final response = await http.post(
        Uri.parse(AppConstants.solanaDasApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 'my-id',
          'method': 'getAssetsByOwner',
          'params': {
            'ownerAddress': walletAddress,
            'page': 1,
            'limit': 1000,
            'displayOptions': {
              'showFungible': false,
              'showNativeBalance': false,
            }
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['error'] != null) {
          print('DAS API Error: ${json['error']}');
          return [];
        }

        final result = json['result'];
        final items = result['items'] as List<dynamic>;
        
        return items.map((item) {
          final content = item['content'];
          final files = content['files'] as List<dynamic>?;
          String? imageUrl;
          
          if (files != null && files.isNotEmpty) {
             imageUrl = files.first['uri']; // Often the safest bet
          } 
          
          // Fallback to json_uri if files is empty or problematic
          if (imageUrl == null || imageUrl.isEmpty) {
             imageUrl = content['links']?['image'];
          }

          return NftModel(
            mintAddress: item['id'],
            name: content['metadata']['name'] ?? 'Unknown NFT',
            imageUrl: imageUrl ?? 'https://via.placeholder.com/150',
          );
        }).toList();

      } else {
        print('DAS API HTTP Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Exception fetching cNFTs: $e');
    }
    return [];
  }

  Future<NftModel?> _fetchNftMetadata(String mintAddress) async {
    try {
      // 2. Find Metadata PDA
      final programId = Ed25519HDPublicKey.fromBase58(_metaplexProgramId);
      final mintKey = Ed25519HDPublicKey.fromBase58(mintAddress);

      final pda = await Ed25519HDPublicKey.findProgramAddress(
        seeds: [
          'metadata'.codeUnits,
          programId.bytes,
          mintKey.bytes,
        ],
        programId: programId,
      );

      // 3. Fetch Account Info
      final accountInfo = await _client.rpcClient.getAccountInfo(
         pda.toBase58(),
         encoding: Encoding.base64,
      );

      if (accountInfo == null) return null;

      final data = (accountInfo.value?.data as List<dynamic>?)?.cast<int>();
      if (data == null) return null;
      
      // 4. Manually Parse Metaplex Data (Simplified)
      // Reference: https://github.com/metaplex-foundation/metaplex-program-library/blob/master/token-metadata/program/src/state.rs
      
      // Skip 1 byte (key) + 32 bytes (update authority) + 32 bytes (mint)
      // Total 65 bytes offset to start of Data struct
      int offset = 1 + 32 + 32;
      
      // Retrieve Name (String)
      final nameLength = _readU32(data, offset);
      offset += 4;
      // String bytes are usually padded to 32 bytes in legacy, but strictly it's length then bytes
      final nameBytes = data.sublist(offset, offset + nameLength);
      // Remove padding (null bytes)
      final name = utf8.decode(nameBytes).replaceAll(RegExp(r'\u0000'), '').trim();
      offset += nameLength;

      // Symbol
      final symbolLength = _readU32(data, offset);
      offset += 4;
      offset += symbolLength; // Skip symbol

      // URI
      final uriLength = _readU32(data, offset);
      offset += 4;
      final uriBytes = data.sublist(offset, offset + uriLength);
      final uri = utf8.decode(uriBytes).replaceAll(RegExp(r'\u0000'), '').trim();

      // 5. Fetch JSON from URI
      if (uri.isNotEmpty) {
        final response = await http.get(Uri.parse(uri));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final image = json['image'] as String?;
          if (image != null) {
            return NftModel(
              mintAddress: mintAddress,
              name: name,
              imageUrl: image,
            );
          }
        }
      }
    } catch (e) {
      // Quiet fail for individual NFT parsing errors
    }
    return null;
  }

  int _readU32(List<int> data, int offset) {
    return data[offset] | (data[offset + 1] << 8) | (data[offset + 2] << 16) | (data[offset + 3] << 24);
  }
}
