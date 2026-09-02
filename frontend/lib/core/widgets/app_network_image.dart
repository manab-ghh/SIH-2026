import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Universal image widget supporting:
/// 1. Base64 data URIs (`data:image/...;base64,...`)
/// 2. Raw `Uint8List` image bytes
/// 3. Remote `http://` / `https://` URLs with caching
/// 4. Graceful loading placeholders and error fallbacks
class AppProductImage extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppProductImage({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContent = _buildImageContent();

    if (borderRadius != null) {
      imageContent = ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildImageContent() {
    // 1. Direct Uint8List raw bytes
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return _buildFallback();
    }

    // 2. Base64 Data URI (e.g. data:image/png;base64,... or data:image/jpeg;base64,...)
    if (url.startsWith('data:image')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64Data =
            commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final decodedBytes = base64Decode(base64Data);
        return Image.memory(
          decodedBytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } catch (_) {
        return _buildFallback();
      }
    }

    // 3. Remote HTTP / HTTPS URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) =>
            placeholder ??
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
        errorWidget: (_, __, ___) => errorWidget ?? _buildFallback(),
      );
    }

    // 4. Fallback default
    return _buildFallback();
  }

  Widget _buildFallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            size: 28,
            color: AppColors.textMuted,
          ),
        );
  }
}
