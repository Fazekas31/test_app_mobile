import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Solicita permissão e retorna a posição atual com alta precisão.
  /// Lança exceptions se o usuário negar ou se o GPS estiver desligado.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica se o GPS está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('O serviço de localização está desativado.');
    }

    // 2. Verifica permissões
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissões negadas permanentemente. Abra as configurações.');
    }

    // 3. Retorna a posição (Requisito: Accuracy e Timestamp vêm aqui)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
