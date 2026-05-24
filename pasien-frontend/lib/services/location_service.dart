import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Mendapatkan alamat lengkap berbasis koordinat GPS saat ini.
  static Future<String> getCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah layanan GPS aktif di perangkat
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan GPS (Location Services) dinonaktifkan di perangkat Anda.');
    }

    // 2. Cek dan minta izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.');
    }

    // 3. Dapatkan koordinat GPS saat ini
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4. Ubah koordinat (Reverse Geocoding) menjadi nama Alamat
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Buat string alamat yang rapi dan detail
        String street = place.street ?? '';
        String subLocality = place.subLocality ?? ''; // Kelurahan/Desa
        String locality = place.locality ?? ''; // Kecamatan
        String subAdministrativeArea = place.subAdministrativeArea ?? ''; // Kabupaten/Kota
        String administrativeArea = place.administrativeArea ?? ''; // Provinsi
        String postalCode = place.postalCode ?? '';

        List<String> addressParts = [];
        if (street.isNotEmpty) addressParts.add(street);
        if (subLocality.isNotEmpty) addressParts.add(subLocality);
        if (locality.isNotEmpty) addressParts.add(locality);
        if (subAdministrativeArea.isNotEmpty) addressParts.add(subAdministrativeArea);
        if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
        if (postalCode.isNotEmpty) addressParts.add('Kodepos $postalCode');

        return addressParts.join(', ');
      }
      return 'Alamat tidak ditemukan dari GPS';
    } catch (e) {
      return Future.error('Gagal melakukan geocoding koordinat: $e');
    }
  }
}
