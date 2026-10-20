import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

/// Ouvre la galerie (ou la caméra) et prépare l'image : dimensions et couleur dominante,
/// utilisées pour afficher la carte avant chargement et pour la recherche par image.
Future<PickedImage?> pickImage({ImageSource source = ImageSource.gallery}) async {
  final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
  if (file == null) return null;
  final bytes = await file.readAsBytes();

  final full = await (await ui.instantiateImageCodec(bytes)).getNextFrame();
  final width = full.image.width;
  final height = full.image.height;
  full.image.dispose();

  final small = await (await ui.instantiateImageCodec(bytes, targetWidth: 16, targetHeight: 16)).getNextFrame();
  final data = await small.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  small.image.dispose();
  var r = 0, g = 0, b = 0, n = 0;
  if (data != null) {
    for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
      r += data.getUint8(i);
      g += data.getUint8(i + 1);
      b += data.getUint8(i + 2);
      n++;
    }
  }
  String hex(int v) => (n == 0 ? 0xd9 : v ~/ n).toRadixString(16).padLeft(2, '0');

  final name = file.name.isNotEmpty ? file.name : 'image.jpg';
  return PickedImage(
    bytes: bytes,
    filename: name,
    width: width,
    height: height,
    dominantColor: '#${hex(r)}${hex(g)}${hex(b)}',
  );
}
