import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Retorna a posição atual ou lança um erro amigável se algo der errado (GPS desligado, sem permissão, etc)
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica se o GPS está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Por favor, ative o GPS do celular.');
    }

    // 2. Verifica as permissões
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissões de localização estão permanentemente bloqueadas.');
    }

    // 3. Tudo certo! Retorna as coordenadas.
    return await Geolocator.getCurrentPosition();
  }
}