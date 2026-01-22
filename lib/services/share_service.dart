import 'package:share_plus/share_plus.dart';
import '../models/models.dart';

class ShareService {
  static Future<void> shareEstablishment(Establishment establishment) async {
    final String text = '''
¡Mira este lugar en QuevedoTour! 🌟

📍 ${establishment.name}
📝 ${establishment.description}
🏠 Dirección: ${establishment.address}

Descarga QuevedoTour para ver más lugares increíbles.
''';

    await Share.share(
      text,
      subject: 'Te comparto un lugar increíble en Quevedo: ${establishment.name}',
    );
  }

  static Future<void> shareApp() async {
    const String text = '¡Descarga QuevedoTour y descubre lo mejor de Quevedo! 🇪🇨';
    await Share.share(text);
  }
}
