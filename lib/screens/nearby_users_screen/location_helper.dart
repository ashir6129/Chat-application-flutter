import 'package:geolocator/geolocator.dart';

class LocationHelper {
  LocationHelper._();

  static const Map<String, List<double>> locationCoords = {
    'Current Location': [6.4281, 3.4219],
    'Lagos': [6.5244, 3.3792],
    'Lekki': [6.4590, 3.6015],
    'Ikeja': [6.6018, 3.3515],
    'Lekki Phase 1, Lagos, Nigeria': [6.4428, 3.4839],
    'Lekki Phase 2, Lagos, Nigeria': [6.4480, 3.5180],
    'Lekki Phase 3, Lagos, Nigeria': [6.4520, 3.5350],
    'Lekki Phase 4, Lagos, Nigeria': [6.4550, 3.5500],
    'Lekki Conservation Centre, Lagos, Nigeria': [6.4419, 3.5357],
    'Victoria Island, Lagos, Nigeria': [6.4281, 3.4219],
    'Ikoyi, Lagos, Nigeria': [6.4549, 3.4246],
    'Yaba, Lagos, Nigeria': [6.5095, 3.3790],
    'Surulere, Lagos, Nigeria': [6.5000, 3.3667],
    'Mushin, Lagos, Nigeria': [6.5283, 3.3500],
    'Ojodu, Lagos, Nigeria': [6.6224, 3.3533],
  };

  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }
}
