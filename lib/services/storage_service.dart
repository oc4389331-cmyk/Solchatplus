import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  late FirebaseStorage _storage;
  final _uuid = const Uuid();

  StorageService() {
    _initializeStorage();
  }

  void _initializeStorage() {
    // Initialization now happens inside _performUpload to support fallback retries
    print('StorageService: Initialized (Lazy initialization per upload)');
  }

  // 1. Prepare Image (Compress & Save Locally)
  Future<File?> compressAndSaveImage(File file) async {
    try {
      // 1. Get/Create Local Directory
      final directory = await _getLocalDirectory();
      if (directory == null) {
        print('StorageService: Could not access local directory');
        return null;
      }

      final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = '${directory.path}/$fileName';

      print('StorageService: Compressing image: ${file.path}');
       
      // 2. Compress
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60,
        minWidth: 1024, // Use slightly higher resolution for modern devices
        minHeight: 1024,
      );

      if (result == null) {
        print('StorageService: Compression failed: result is null');
        return null;
      }

      File compressedFile = File(result.path);

      if (!await compressedFile.exists()) {
        print('StorageService: Compressed file does not exist at ${result.path}');
        return null;
      }

      int size = await compressedFile.length();
      print('StorageService: Compressed size: $size bytes');
      
      if (size == 0) {
        print('StorageService: Compression produced a 0-byte file');
        return null;
      }
      
      // "Si tamaño > 500KB, volver a comprimir" (Increased limit slightly for better quality)
      if (size > 500 * 1024) {
         print('StorageService: Size > 500KB, re-compressing...');
         final tempPath2 = '${directory.path}/IMG_${DateTime.now().millisecondsSinceEpoch}_low.jpg';
         var result2 = await FlutterImageCompress.compressAndGetFile(
            compressedFile.absolute.path,
            tempPath2,
            quality: 40,
            minWidth: 800,
            minHeight: 800,
         );
         
         if (result2 != null) {
            final file2 = File(result2.path);
            if (await file2.exists() && await file2.length() > 0) {
               // Delete intermediate ONLY if we have a new successful compression
               try {
                 if (await compressedFile.exists()) await compressedFile.delete();
               } catch (e) {
                 print('StorageService: Non-critical error deleting temp file: $e');
               }
               compressedFile = file2;
               print('StorageService: Re-compressed size: ${await compressedFile.length()} bytes');
            } else {
               print('StorageService: Re-compression failed or produced empty file');
            }
         }
      }

      return compressedFile;
    } catch (e) {
      print('StorageService: Compression error: $e');
      return null;
    }
  }

  // 2. Encode to Base64 (fallback for Storage 404)
  Future<String?> encodeFileToBase64(File file) async {
    try {
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      // Return with data URI prefix
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('StorageService: Base64 encoding error: $e');
      return null;
    }
  }

  // 3. Upload (Disabled in favor of Base64 to avoid Firebase Plan issues)
  Future<String?> uploadImage(File file, String chatId) async {
    print('StorageService: Cloud upload disabled. Using Base64 fallback.');
    return await encodeFileToBase64(file);
  }

  // 3. Download & Save
  Future<String?> downloadAndSaveImage(String url, String fileName) async {
    try {
       final directory = await _getLocalDirectory();
       if (directory == null) return null;

       final localPath = '${directory.path}/$fileName';
       final file = File(localPath);

       if (await file.exists()) {
         return localPath;
       }

       final response = await http.get(Uri.parse(url));
       if (response.statusCode == 200) {
         await file.writeAsBytes(response.bodyBytes);
         return localPath;
       }
    } catch (e) {
      print('StorageService: Download error: $e');
    }
    return null;
  }

  // Helper: Get Directory
  Future<Directory?> _getLocalDirectory() async {
    // Robust directory selection fallback strategy
    Directory? directory;
    
    try {
      if (Platform.isAndroid) {
        // Try to use a "public" but app-specific folder first (doesn't need MANAGE_EXTERNAL_STORAGE)
        // This is safer than direct path access
        final appDocDir = await getApplicationDocumentsDirectory();
        directory = Directory('${appDocDir.path}/SolChatPlus/images');
      } else {
        final appDocDir = await getApplicationDocumentsDirectory();
        directory = Directory('${appDocDir.path}/SolChatPlus/images');
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } catch (e) {
       print('StorageService: Error getting local directory: $e');
       // Last resort fallback
       try {
         final tempDir = await getTemporaryDirectory();
         return tempDir;
       } catch (e2) {
         print('StorageService: Critical error getting any directory: $e2');
         return null;
       }
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) return true;
    final state = await permission.status;
    if (state.isPermanentlyDenied) return false;
    
    final result = await permission.request();
    return result.isGranted;
  }
  
  // 4. Delete from Storage
  Future<void> deleteFromStorage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }
}
