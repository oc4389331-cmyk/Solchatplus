import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Wallet del proyecto (Fee Wallet)
  static const String projectFeeWallet = '575z43vmBjh4dKjG42TQXJBKRCHTkEWMbhLXseDCuQKh'; 
  
  static const double chatCreationFeeSol = 0.01;
  static const double chatCreationFeeSkr = 31.0;

  static const double transactionFee = 0.0001;

  // Solana RPC URLs
  // Standard Mainnet RPC (Using Helius via env)
  static String get solanaRpcUrl => dotenv.env['SOLANA_RPC_URL'] ?? 'https://YOUR_HELIUS_RPC_URL_HERE';
  // DAS API (Read API) for Compressed NFTs 
  static String get solanaDasApiUrl => dotenv.env['SOLANA_RPC_URL'] ?? 'https://YOUR_HELIUS_RPC_URL_HERE'; 

  // Tokens
  static const String skrMintAddress = 'SKRbvo6Gf7GondiT3BbTfuRDPqLWei4j2Qy2NPGZhW3'; 
  static const int skrDecimals = 6; 

}
