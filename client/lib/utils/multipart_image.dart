import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

/// Builds a multipart file with a correct image content-type for Multer.
Future<http.MultipartFile> multipartImageFile({
  required String field,
  required XFile image,
  required int index,
}) async {
  final bytes = await image.readAsBytes();
  final filename = _resolveFilename(image, index);

  return http.MultipartFile.fromBytes(
    field,
    bytes,
    filename: filename,
    contentType: _contentTypeFor(image, filename),
  );
}

String _resolveFilename(XFile image, int index) {
  if (image.name.isNotEmpty) return image.name;

  final mime = image.mimeType?.toLowerCase() ?? '';
  if (mime.contains('png')) return 'image_$index.png';
  if (mime.contains('webp')) return 'image_$index.webp';
  if (mime.contains('gif')) return 'image_$index.gif';
  return 'image_$index.jpg';
}

MediaType _contentTypeFor(XFile image, String filename) {
  final mime = image.mimeType?.toLowerCase();
  if (mime != null && mime.startsWith('image/')) {
    final parts = mime.split('/');
    if (parts.length == 2) return MediaType(parts[0], parts[1]);
  }

  final ext = filename.contains('.')
      ? filename.split('.').last.toLowerCase()
      : 'jpg';

  switch (ext) {
    case 'png':
      return MediaType('image', 'png');
    case 'gif':
      return MediaType('image', 'gif');
    case 'webp':
      return MediaType('image', 'webp');
    case 'jpeg':
    case 'jpg':
    default:
      return MediaType('image', 'jpeg');
  }
}
