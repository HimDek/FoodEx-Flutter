import 'package:latlong2/latlong.dart';

class OSMdata {
  final String displayname;
  final double latitude;
  final double longitude;
  const OSMdata(
      {required this.displayname,
      required this.latitude,
      required this.longitude});
  @override
  String toString() {
    return '$displayname, $latitude, $longitude';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayname == displayname;
  }

  @override
  int get hashCode => Object.hash(displayname, latitude, longitude);
}

class PickedData {
  final LatLng latLong;
  final String address;
  final Map<String, dynamic> addressData;

  const PickedData(this.latLong, this.address, this.addressData);
}
