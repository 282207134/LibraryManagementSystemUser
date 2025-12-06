import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';

class ImageHelper {
  static const String bucketName = 'book-covers';
  static const int signedUrlExpirySeconds = 60 * 60; // 1 hour

  // 解析封面图片URL
  static Future<String?> resolveCoverImageUrl(String? source) async {
    if (source == null || source.isEmpty) return null;

    // 如果是blob或data URL，直接返回
    if (source.startsWith('blob:') || source.startsWith('data:')) {
      return source;
    }

    // 如果已经是完整的URL，直接返回
    if (source.startsWith('http://') || source.startsWith('https://')) {
      // 检查是否是Supabase Storage的URL
      if (source.contains('/storage/v1/object/sign/') && source.contains('?token=')) {
        return source;
      }
      
      // 如果是公开URL，直接返回
      if (source.contains('/storage/v1/object/public/')) {
        return source;
      }
    }

    // 尝试从URL中提取bucket和path
    final storagePath = _extractStoragePath(source);
    if (storagePath != null) {
      // 先尝试获取公开URL
      final publicUrl = _getPublicUrl(storagePath['bucket']!, storagePath['path']!);
      if (publicUrl != null) return publicUrl;

      // 如果公开URL不可用，尝试创建签名URL
      final signedUrl = await _createSignedUrl(storagePath['bucket']!, storagePath['path']!);
      if (signedUrl != null) return signedUrl;
    }

    // 如果无法解析，尝试作为路径处理
    if (!source.startsWith('http')) {
      final publicUrl = _getPublicUrl(bucketName, source);
      if (publicUrl != null) return publicUrl;
    }

    // 最后返回原始URL
    return source;
  }

  static Map<String, String>? _extractStoragePath(String input) {
    if (input.startsWith('http')) {
      try {
        final url = Uri.parse(input);
        final pathSegments = url.pathSegments;
        
        // 查找storage相关的路径
        final storageIndex = pathSegments.indexOf('storage');
        if (storageIndex != -1 && pathSegments.length > storageIndex + 3) {
          final mode = pathSegments[storageIndex + 2]; // 'public' or 'sign'
          final bucket = pathSegments[storageIndex + 3];
          final path = pathSegments.sublist(storageIndex + 4).join('/');
          
          return {
            'bucket': bucket,
            'path': path,
          };
        }
      } catch (e) {
        print('Failed to parse storage path: $e');
      }
    } else {
      // 直接作为路径处理
      return {
        'bucket': bucketName,
        'path': input.replaceAll(RegExp(r'^/+'), ''),
      };
    }
    
    return null;
  }

  static String? _getPublicUrl(String bucket, String path) {
    try {
      final supabase = AppConfig.supabase;
      final response = supabase.storage.from(bucket).getPublicUrl(path);
      return response;
    } catch (e) {
      print('Failed to get public URL: $e');
      return null;
    }
  }

  static Future<String?> _createSignedUrl(String bucket, String path) async {
    try {
      final supabase = AppConfig.supabase;
      final response = await supabase.storage
          .from(bucket)
          .createSignedUrl(path, signedUrlExpirySeconds);
      
      return response;
    } catch (e) {
      print('Failed to create signed URL: $e');
      return null;
    }
  }
}

