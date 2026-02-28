import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  final String? imagePath;

  const FullScreenImage({
    super.key,
    this.imageUrl,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (imagePath != null && File(imagePath!).existsSync()) {
      imageProvider = FileImage(File(imagePath!));
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('data:image/')) {
        imageProvider = MemoryImage(base64Decode(imageUrl!.split(',').last));
      } else {
        imageProvider = CachedNetworkImageProvider(imageUrl!);
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: imageProvider != null
            ? PhotoView(
                imageProvider: imageProvider,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF14F195)),
                ),
                errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
              )
            : _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'Could not load image',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
