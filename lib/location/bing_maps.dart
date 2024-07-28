import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

// All compatible imagery sets
enum BingMapsImagerySet {
  road('RoadOnDemand', zoomBounds: (min: 0, max: 21)),
  canvasLight('CanvasLight', zoomBounds: (min: 0, max: 21));

  final String urlValue;
  final ({int min, int max}) zoomBounds;

  const BingMapsImagerySet(this.urlValue, {required this.zoomBounds});
}

// Custom tile provider that contains the quadkeys logic
// Note that you can also extend from the CancellableNetworkTileProvider
class BingMapsTileProvider extends NetworkTileProvider {
  BingMapsTileProvider({super.headers});

  String _getQuadKey(int x, int y, int z) {
    final quadKey = StringBuffer();
    for (int i = z; i > 0; i--) {
      int digit = 0;
      final int mask = 1 << (i - 1);
      if ((x & mask) != 0) digit++;
      if ((y & mask) != 0) digit += 2;
      quadKey.write(digit);
    }
    return quadKey.toString();
  }

  @override
  Map<String, String> generateReplacementMap(
    String urlTemplate,
    TileCoordinates coordinates,
    TileLayer options,
  ) =>
      super.generateReplacementMap(urlTemplate, coordinates, options)
        ..addAll(
          {
            'culture': 'en-GB', // Or your culture value of choice
            'subdomain': options.subdomains[
                (coordinates.x + coordinates.y) % options.subdomains.length],
            'quadkey': _getQuadKey(coordinates.x, coordinates.y, coordinates.z),
          },
        );
}

// Custom `TileLayer` wrapper that can be inserted into a `FlutterMap`
class BingMapsTileLayer extends StatelessWidget {
  const BingMapsTileLayer({
    super.key,
    required this.apiKey,
    required this.imagerySet,
  });

  final String apiKey;
  final BingMapsImagerySet imagerySet;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: get(
        Uri.parse(
          'http://dev.virtualearth.net/REST/V1/Imagery/Metadata/${imagerySet.urlValue}?output=json&include=ImageryProviders&key=$apiKey',
        ),
      ),
      builder: (context, response) {
        if (response.data == null) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return TileLayer(
          urlTemplate: (((((jsonDecode(response.data!.body)
                          as Map<String, dynamic>)['resourceSets']
                      as List<dynamic>)[0] as Map<String, dynamic>)['resources']
                  as List<dynamic>)[0] as Map<String, dynamic>)['imageUrl']
              as String,
          tileProvider: BingMapsTileProvider(),
          subdomains: const ['t0', 't1', 't2', 't3'],
          minNativeZoom: imagerySet.zoomBounds.min,
          maxNativeZoom: imagerySet.zoomBounds.max,
        );
      },
    );
  }
}
