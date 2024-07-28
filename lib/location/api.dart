import 'dart:convert';
import 'package:food_delivery/common/components.dart';
import 'package:food_delivery/location/bing_maps.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import './picker/picker.dart';
import '../common/api.dart';

Future<LocationData?> getLocation() async {
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  locationData = await location.getLocation();
  return locationData;
}

Future<void> storeCoordinates(double latitude, double longitude) async {
  await store('location', json.encode([latitude, longitude]));
}

Future<LatLng?> getLastCoordinates() async {
  final String? location = await readStorage('location');
  if (location == null) {
    return null;
  }
  return LatLng(json.decode(location)[0], json.decode(location)[1]);
}

Future<LatLng?> getCoordinates() async {
  var locationData = await getLocation();

  if (locationData == null ||
      locationData.latitude == null ||
      locationData.longitude == null) {
    return null;
  }

  storeCoordinates(locationData.latitude!, locationData.longitude!);

  return LatLng(locationData.latitude!, locationData.longitude!);
}

Future<String> getAddress(double latitude, double longitude) async {
  String address = "$latitude, $longitude";

  String url =
      'http://dev.virtualearth.net/REST/v1/Locations/$latitude,$longitude?vbpn=true&inclnb=1&key=$bingMapsApiKey';

  try {
    var response = await get(Uri.parse(url));
    var decodedResponse =
        json.decode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
    address = decodedResponse['resourceSets']?[0]?['resources']?[0]['address']
            ['formattedAddress'] ??
        "This Location is not accessible";
  } catch (e) {
    // do something
  }

  return address;
}

Future<List<Map<String, dynamic>>> searchLocation(String value) async {
  String url =
      'http://dev.virtualearth.net/REST/v1/Locations/$value?inclnb=1&key=$bingMapsApiKey';
  var response = await get(Uri.parse(url));
  var decodedResponse =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
  List<Map<String, dynamic>> options =
      decodedResponse['resourceSets']?[0]?['resources']
          .map((e) => {
                'displayname':
                    '${e['address']['neighborhood']}, ${e['address']['locality']}, ${e['address']['adminDistrict2']}, ${e['address']['countryRegion']}',
                'latitude': double.parse(e['point']['coordinates'][0]),
                'longitude': double.parse(e['point']['coordinates'][1]),
              })
          .toList();
  return options;
}

class LocationPicker extends StatefulWidget {
  final Function(LatLng location) onPicked;
  const LocationPicker({super.key, required this.onPicked});

  @override
  LocationPickerState createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLocationPicker(
        initPosition: homeKey.currentState!.location,
        searchBarBackgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
        selectLocationButtonStyle: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primaryContainer)),
        selectLocationButtonText: 'Select Location',
        searchbarBorderRadius: BorderRadius.circular(32),
        searchbarInputBorder:
            const OutlineInputBorder(borderSide: BorderSide.none),
        searchbarInputFocusBorderp:
            const OutlineInputBorder(borderSide: BorderSide.none),
        showSelectLocationButton: true,
        initZoom: 15,
        minZoomLevel: 5,
        maxZoomLevel: 18,
        trackMyPosition: false,
        onError: (e) => () {},
        onPicked: (pickedData) {
          widget.onPicked(LatLng(
              pickedData.latLong.latitude, pickedData.latLong.longitude));
        },
      ),
    );
  }
}

class PickedLocationDisplay extends StatefulWidget {
  final LatLng? location;
  final Function(LatLng location)? onLocationChanged;
  final Function(TapPosition tapPosition, LatLng location)? onTap;
  const PickedLocationDisplay(
      {super.key, this.location, this.onLocationChanged, this.onTap});

  @override
  PickedLocationDisplayState createState() => PickedLocationDisplayState();
}

class PickedLocationDisplayState extends State<PickedLocationDisplay>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng _location = homeKey.currentState!.location;
  late LatLng _pickedLocation = homeKey.currentState!.location;
  late AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );
  late bool _picked = false;

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _pickedLocation = widget.location!;
      _picked = true;
    }
    setState(() {});
  }

  void _animatedMapMove(LatLng destLocation, {double destZoom = 15}) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);
    // Create a animation controller that has a duration and a TickerProvider.
    if (mounted) {
      _animationController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1000));
    }
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation = CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn);

    _animationController.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: Key('map-${_location.latitude}-${_location.longitude}'),
      options: MapOptions(
        initialCenter: (_picked) ? _pickedLocation : _location,
        initialZoom: 15,
        minZoom: 2,
        maxZoom: 20,
        interactionOptions:
            const InteractionOptions(flags: ~InteractiveFlag.all),
        onTap: widget.onTap ??
            (TapPosition tapPosition, LatLng location) {
              if (widget.onLocationChanged != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPicker(
                      onPicked: (location) {
                        Navigator.pop(context);
                        _pickedLocation = location;
                        _picked = true;
                        setState(() {});
                        _animatedMapMove(location, destZoom: 15);
                        widget.onLocationChanged!(_pickedLocation);
                      },
                    ),
                  ),
                );
              }
            },
      ),
      mapController: _mapController,
      children: [
        const BingMapsTileLayer(
          apiKey: bingMapsApiKey,
          imagerySet: BingMapsImagerySet.road,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: (_picked) ? _pickedLocation : _location,
              width: 64,
              height: 116,
              rotate: true,
              child: Container(
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.place,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
                  size: 64,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
