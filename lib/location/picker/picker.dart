import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:food_delivery/common/components.dart';
import 'package:food_delivery/location/bing_maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as lm;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'classes.dart';

/// Principal widget to show Flutter map using osm api with pick up location marker and search bar.
/// you can track you current location, search for a location and select it.
/// navigate easily in the map to selecte location.

class FlutterLocationPicker extends StatefulWidget {
  /// [onPicked] : (callback) is trigger when you clicked on select location,return current [PickedData] of the Marker
  ///
  final void Function(PickedData pickedData) onPicked;

  /// [onChanged] : (callback) is trigger when you change marker location on map,return current [PickedData] of the Marker
  ///
  final void Function(PickedData pickedData)? onChanged;

  /// [onError] : (callback) is trigger when an error occurs while fetching location
  ///
  final void Function(Exception e)? onError;

  /// [initPosition] :(LatLng?) set the initial location of the pointer on the map
  ///
  final LatLng? initPosition;

  /// [mapLanguage] : (String) set the language of the map and address text (default = 'en')
  ///
  final String mapLanguage;

  /// [countryFilter] : (String) set the list of country codes to filter search results to them (example: 'eg,us') (default = null)
  ///
  final String? countryFilter;

  /// [selectLocationButtonText] : (String) set the text of the select location button (default = 'Set Current Location')
  ///
  final String selectLocationButtonText;

  /// [selectLocationButtonLeadingIcon] : (Widget) set the leading icon of the select location button
  ///
  final Widget? selectLocationButtonLeadingIcon;

  /// [initZoom] : (double) set initialized zoom in specific location  (default = 17)
  ///
  final double initZoom;

  /// [stepZoom] : (double) set default step zoom value (default = 1)
  ///
  final double stepZoom;

  /// [minZoomLevel] : (double) set default zoom value (default = 2)
  ///
  final double minZoomLevel;

  /// [maxZoomLevel] : (double) set default zoom value (default = 18.4)
  ///
  final double maxZoomLevel;

  /// [maxBounds] : (LatLngBounds?) set default max bounds of the map (default = null)
  ///
  final LatLngBounds? maxBounds;

  /// [loadingWidget] : (Widget) show custom  widget until the map finish initialization
  ///
  final Widget? loadingWidget;

  /// [trackMyPosition] : (bool) if is true, map will track your your location on the map initialization and makes inittial position of the pointer your current location (default = false)
  ///
  final bool trackMyPosition;

  /// [showCurrentLocationPointer] : (bool) if is true, your current location will be shown on the map (default = true)
  ///
  final bool showCurrentLocationPointer;

  /// [showZoomController] : (bool) enable/disable zoom in and zoom out buttons (default = true)
  ///
  final bool showZoomController;

  /// [showLocationController] : (bool) enable/disable locate me button (default = true)
  ///
  final bool showLocationController;

  /// [showSelectLocationButton] : (bool) enable/disable select location button (default = true)
  ///
  final bool showSelectLocationButton;

  /// [mapAnimationDuration] : (Duration) time duration of the move from point to point animation (default = Duration(milliseconds: 2000))
  ///
  final Duration mapAnimationDuration;

  /// [mapLoadingBackgroundColor] : (Color) change the background color of the loading screen before the map initialized
  ///
  final Color? mapLoadingBackgroundColor;

  /// [selectLocationButtonStyle] : (ButtonStyle) change the style of the select Location button
  ///
  final ButtonStyle? selectLocationButtonStyle;

  /// [selectLocationButtonWidth] : (double) change the width of the select Location button
  ///
  final double? selectLocationButtonWidth;

  /// [selectLocationButtonHeight] : (double) change the height of the select Location button
  ///
  final double? selectLocationButtonHeight;

  /// [selectedLocationButtonTextstyle] : set the style of the button text (default = TextStyle(fontSize: 20))
  ///
  final TextStyle selectedLocationButtonTextstyle;

  /// [selectLocationButtonPositionTop] : (double) change the top position of the select Location button (default = null)
  ///
  final double? selectLocationButtonPositionTop;

  /// [selectLocationButtonPositionRight] : (double) change the right position of the select Location button (default = 0)
  ///
  final double? selectLocationButtonPositionRight;

  /// [selectLocationButtonPositionLeft] : (double) change the left position of the select Location button (default = 0)
  ///
  final double? selectLocationButtonPositionLeft;

  /// [selectLocationButtonPositionBottom] : (double) change the bottom position of the select Location button (default = 3)
  ///
  final double? selectLocationButtonPositionBottom;

  /// [showSearchBar] : (bool) enable/disable search bar (default = true)
  ///
  final bool showSearchBar;

  /// [searchBarBackgroundColor] : (Color) change the background color of the search bar
  ///
  final Color? searchBarBackgroundColor;

  /// [searchBarTextColor] : (Color) change the color of the search bar text
  ///
  final Color? searchBarTextColor;

  /// [searchBarHintText] : (String) change the hint text of the search bar
  ///
  final String searchBarHintText;

  /// [searchBarHintColor] : (Color) change the color of the search bar hint text
  ///
  final Color? searchBarHintColor;

  /// [searchbarInputBorder] : (OutlineInputBorder) change the border of the search bar
  ///
  final OutlineInputBorder? searchbarInputBorder;

  /// [searchbarInputFocusBorder] : (OutlineInputBorder) change the border of the search bar when focused
  ///
  final OutlineInputBorder? searchbarInputFocusBorderp;

  /// [searchbarBorderRadius] : (BorderRadiusGeometry) change the border radius of the search bar
  ///
  final BorderRadiusGeometry? searchbarBorderRadius;

  /// [searchbarDebounceDuration] : (Duration) change the duration of search debounce
  ///
  final Duration? searchbarDebounceDuration;

  /// [zoomButtonsColor] : (Color) change the color of the zoom buttons icons
  ///
  final Color? zoomButtonsColor;

  /// [zoomButtonsBackgroundColor] : (Color) change the background color of the zoom buttons
  ///
  final Color? zoomButtonsBackgroundColor;

  /// [locationButtonsColor] : (Color) change the color of the location button icon
  ///
  final Color? locationButtonsColor;

  /// [locationButtonBackgroundColor] : (Color) change the background color of the location button
  ///
  final Color? locationButtonBackgroundColor;

  /// [markerIcon] : (IconData) change the marker icon of the map (default = Icon(icons.location_on, color: Colors.blue, size: 50))
  ///
  final Widget? markerIcon;

  /// [markerIconOffset] : (double) change the marker icon offset in y direction (default = 50.0)
  ///
  final double markerIconOffset;

  /// [showContributorBadgeForOSM] : (bool) for copyright of osm, we need to add badge in bottom of the map (default false)
  ///
  final bool showContributorBadgeForOSM;

  /// [contributorBadgeForOSMColor] : (Color) change the color of the badge (default Colors.grey[300])
  ///
  final Color? contributorBadgeForOSMColor;

  /// [contributorBadgeForOSMTextColor] : (Color) change the color of the badge text (default Colors.blue)
  ///
  final Color contributorBadgeForOSMTextColor;

  /// [contributorBadgeForOSMText] : (String) change the text of the badge (default 'OpenStreetMap contributors')
  ///
  final String contributorBadgeForOSMText;

  // [contributorBadgeForOSMPositionTop] : (double) change the position of the badge from top (default 0)
  ///
  final double? contributorBadgeForOSMPositionTop;

  /// [contributorBadgeForOSMPositionLeft] : (double) change the position of the badge from left (default null)
  ///
  final double? contributorBadgeForOSMPositionLeft;

  /// [contributorBadgeForOSMPositionRight] : (double) change the position of the badge from right (default 0)
  ///
  final double? contributorBadgeForOSMPositionRight;

  /// [contributorBadgeForOSMPositionBottom] : (double) change the position of the badge from bottom (default -6)
  ///
  final double? contributorBadgeForOSMPositionBottom;

  const FlutterLocationPicker({
    super.key,
    required this.onPicked,
    this.onChanged,
    this.selectedLocationButtonTextstyle = const TextStyle(fontSize: 20),
    this.onError,
    this.initPosition,
    this.stepZoom = 1,
    this.initZoom = 17,
    this.minZoomLevel = 2,
    this.maxZoomLevel = 18.4,
    this.maxBounds,
    this.mapLanguage = 'en',
    this.countryFilter,
    this.selectLocationButtonText = 'Set Current Location',
    this.mapAnimationDuration = const Duration(milliseconds: 2000),
    this.trackMyPosition = false,
    this.showZoomController = true,
    this.showLocationController = true,
    this.showSelectLocationButton = true,
    this.showCurrentLocationPointer = true,
    this.selectLocationButtonStyle,
    this.selectLocationButtonWidth,
    this.selectLocationButtonHeight,
    this.selectLocationButtonPositionTop,
    this.selectLocationButtonPositionRight = 0,
    this.selectLocationButtonPositionLeft = 0,
    this.selectLocationButtonPositionBottom = 3,
    this.showSearchBar = true,
    this.searchBarBackgroundColor,
    this.searchBarTextColor,
    this.searchBarHintText = 'Search location',
    this.searchBarHintColor,
    this.searchbarInputBorder,
    this.searchbarInputFocusBorderp,
    this.searchbarBorderRadius,
    this.searchbarDebounceDuration,
    this.mapLoadingBackgroundColor,
    this.locationButtonBackgroundColor,
    this.zoomButtonsBackgroundColor,
    this.zoomButtonsColor,
    this.locationButtonsColor,
    this.markerIcon,
    this.markerIconOffset = 50.0,
    this.showContributorBadgeForOSM = false,
    this.contributorBadgeForOSMColor,
    this.contributorBadgeForOSMTextColor = Colors.blue,
    this.contributorBadgeForOSMText = 'OpenStreetMap contributors',
    this.contributorBadgeForOSMPositionTop,
    this.contributorBadgeForOSMPositionLeft,
    this.contributorBadgeForOSMPositionRight = 0,
    this.contributorBadgeForOSMPositionBottom = -6,
    Widget? loadingWidget,
    this.selectLocationButtonLeadingIcon,
  }) : loadingWidget = loadingWidget ?? const CircularProgressIndicator();

  @override
  State<FlutterLocationPicker> createState() => _FlutterLocationPickerState();
}

class _FlutterLocationPickerState extends State<FlutterLocationPicker>
    with TickerProviderStateMixin {
  /// Creating a new instance of the MapController class.
  MapController _mapController = MapController();

  // Create a animation controller that has a duration and a TickerProvider.
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  LatLng initPosition = const LatLng(30.0443879, 31.2357257);
  Timer? _debounce;
  bool isLoading = true;
  late void Function(Exception e) onError;
  late Position? currentPosition;

  /// It returns true if the text is RTL, false if it's LTR
  ///
  /// Args:
  ///   text (String): The text to be checked for RTL directionality.
  ///
  /// Returns:
  ///   A boolean value.

  Future<Position?> _lastKnownPosition() async {
    return currentPosition;
  }

  /// If location services are enabled, check if we have permissions to access the location. If we don't
  /// have permissions, request them. If we have permissions, return the current position
  ///
  /// Returns:
  ///   A Future<Position> object.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      const error = lm.PermissionDeniedException("Location Permission is denied");
      onError(error);
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(error);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const error =
          lm.PermissionDeniedException("Location Permission is denied forever");
      onError(error);
      // Permissions are denied forever, handle appropriately.
      return Future.error(error);
    }

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      while (!await Geolocator.isLocationServiceEnabled()) {}
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    return position;
  }

  /// Create a animation controller, add a listener to the controller, and
  /// then forward the controller with the new location
  ///
  /// Args:
  ///   destLocation (LatLng): The LatLng of the destination location.
  ///   destZoom (double): The zoom level you want to animate to.
  void _animatedMapMove(LatLng destLocation, double destZoom) {
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
          vsync: this, duration: widget.mapAnimationDuration);
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

  /// The function `onLocationChanged` updates the current position with the given latitude and
  /// longitude, then retrieves data and calls the `onChanged` callback with the retrieved value.
  ///
  /// Args:
  ///   latitude (double): The latitude parameter represents the current latitude coordinate of the
  /// location. It is a double value that specifies the north-south position on the Earth's surface.
  ///   longitude (double): The longitude parameter represents the current longitude coordinate of the
  /// location.
  void onLocationChanged(LatLng latLng) {
    setNameCurrentPos(latLng);
    pickData(latLng).then(
      (value) {
        if (widget.onChanged != null) widget.onChanged!(value);
      },
    );
  }

  /// It takes the latitude and longitude of the current location and uses the OpenStreetMap API to get
  /// the address of the location
  ///
  /// Args:
  ///   latitude (double): The latitude of the location.
  ///   longitude (double): The longitude of the location.
  void setNameCurrentPos(LatLng latLng) async {
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1&accept-language=${widget.mapLanguage}';

    try {
      var response = await client.get(Uri.parse(url));
      var decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
      _searchController.text =
          decodedResponse['display_name'] ?? "This Location is not accessible";
      setState(() {});
    } on Exception catch (e) {
      onError(e);
    }
  }

  /// It takes the poiner of the map and sends a request to the OpenStreetMap API to get the address of
  /// the poiner
  ///
  /// Returns:
  ///   A Future object that will eventually contain a PickedData object.
  Future<PickedData> pickData(LatLng center) async {
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${center.latitude}&lon=${center.longitude}&zoom=18&addressdetails=1&accept-language=${widget.mapLanguage}';
    var response = await client.get(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
    String displayName = "This Location is not accessible";
    Map<String, dynamic> address;

    if (decodedResponse['display_name'] != null) {
      displayName = decodedResponse['display_name'];
      address = decodedResponse['address'];
    } else {
      center = const LatLng(0, 0);
      address = decodedResponse as Map<String, dynamic>;
    }
    return PickedData(center, displayName, address);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _mapController = MapController();
    _animationController =
        AnimationController(duration: widget.mapAnimationDuration, vsync: this);
    onError = widget.onError ?? (e) => debugPrint(e.toString());

    /// Checking if the trackMyPosition is true or false. If it is true, it will get the current
    /// position of the user and set the initLate and initLong to the current position. If it is false,
    /// it will set the initLate and initLong to the [initPosition].latitude and
    /// [initPosition].longitude.
    if (widget.trackMyPosition) {
      _determinePosition().then((currentPosition) {
        initPosition =
            LatLng(currentPosition.latitude, currentPosition.longitude);

        onLocationChanged(initPosition);
        _animatedMapMove(initPosition, 18.0);
      }, onError: (e) => onError(e)).whenComplete(
        () => setState(
          () {
            isLoading = false;
          },
        ),
      );
    } else if (widget.initPosition != null) {
      initPosition =
          LatLng(widget.initPosition!.latitude, widget.initPosition!.longitude);
      onLocationChanged(initPosition);
      setState(() {
        isLoading = false;
      });
    } else {
      onLocationChanged(initPosition);
      setState(() {
        isLoading = false;
      });
    }

    /// The above code is listening to the mapEventStream and when the mapEventMoveEnd event is
    /// triggered, it calls the setNameCurrentPos function.
    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        LatLng center =
            LatLng(event.camera.center.latitude, event.camera.center.longitude);
        onLocationChanged(center);
      }
    });

    super.initState();
  }

  /// The dispose() function is called when the widget is removed from the widget tree and is used to
  /// clean up resources
  @override
  void dispose() {
    _mapController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _options.length > 5 ? 5 : _options.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.location_on, color: widget.searchBarTextColor),
          title: Text(
            _options[index].displayname,
            style: TextStyle(color: widget.searchBarTextColor),
          ),
          onTap: () {
            LatLng center =
                LatLng(_options[index].latitude, _options[index].longitude);
            _animatedMapMove(center, 18.0);
            onLocationChanged(center);

            _focusNode.unfocus();
            _options.clear();
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor),
    );
    OutlineInputBorder inputFocusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: widget.searchBarBackgroundColor ??
              Theme.of(context).colorScheme.surface,
          borderRadius:
              widget.searchbarBorderRadius ?? BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            TextFormField(
              style: TextStyle(color: widget.searchBarTextColor),
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.searchBarHintText,
                border: widget.searchbarInputBorder ?? inputBorder,
                focusedBorder:
                    widget.searchbarInputFocusBorderp ?? inputFocusBorder,
                hintStyle: TextStyle(color: widget.searchBarHintColor),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _options.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    color: widget.searchBarTextColor,
                  ),
                ),
              ),
              onChanged: (String value) {
                if (_debounce?.isActive ?? false) {
                  _debounce?.cancel();
                }
                setState(() {});
                _debounce = Timer(
                  widget.searchbarDebounceDuration ??
                      const Duration(milliseconds: 500),
                  () async {
                    var client = http.Client();
                    try {
                      String url =
                          'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1&accept-language=${widget.mapLanguage}${widget.countryFilter != null ? '&countrycodes=${widget.countryFilter}' : ''}';
                      var response = await client.get(Uri.parse(url));
                      var decodedResponse =
                          jsonDecode(utf8.decode(response.bodyBytes))
                              as List<dynamic>;
                      _options = decodedResponse
                          .map((e) => OSMdata(
                              displayname: e['display_name'],
                              latitude: double.parse(e['lat']),
                              longitude: double.parse(e['lon'])))
                          .toList();
                      setState(() {});
                    } on Exception catch (e) {
                      onError(e);
                    } finally {
                      client.close();
                    }
                  },
                );
              },
            ),
            StatefulBuilder(
              builder: ((context, setState) {
                return _buildListView();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControllerButtons() {
    return PositionedDirectional(
      bottom: 72,
      end: 16,
      child: Column(
        children: [
          if (widget.showZoomController)
            FloatingActionButton(
              heroTag: "btn1",
              shape: const CircleBorder(),
              backgroundColor: widget.zoomButtonsBackgroundColor,
              onPressed: () {
                _animatedMapMove(_mapController.camera.center,
                    _mapController.camera.zoom + widget.stepZoom);
              },
              child: Icon(
                Icons.zoom_in,
                color: widget.zoomButtonsColor,
              ),
            ),
          const SizedBox(height: 16),
          if (widget.showZoomController)
            FloatingActionButton(
              heroTag: "btn2",
              shape: const CircleBorder(),
              backgroundColor: widget.zoomButtonsBackgroundColor,
              onPressed: () {
                _animatedMapMove(_mapController.camera.center,
                    _mapController.camera.zoom - widget.stepZoom);
              },
              child: Icon(
                Icons.zoom_out,
                color: widget.zoomButtonsColor,
              ),
            ),
          const SizedBox(height: 22),
          if (widget.showLocationController)
            FloatingActionButton(
              heroTag: "btn3",
              backgroundColor: widget.locationButtonBackgroundColor,
              onPressed: () async {
                _lastKnownPosition().then(
                  (position) {
                    if (position != null) {
                      LatLng center =
                          LatLng(position.latitude, position.longitude);
                      _animatedMapMove(center, 18);
                      onLocationChanged(center);
                    }
                  },
                );
                _determinePosition().then(
                  (position) {
                    LatLng center =
                        LatLng(position.latitude, position.longitude);
                    _animatedMapMove(center, 18);
                    onLocationChanged(center);
                  },
                );
              },
              child:
                  Icon(Icons.my_location, color: widget.locationButtonsColor),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Positioned.fill(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: initPosition,
          initialZoom: widget.initZoom,
          maxZoom: widget.maxZoomLevel,
          minZoom: widget.minZoomLevel,
          cameraConstraint: (widget.maxBounds != null
              ? CameraConstraint.contain(bounds: widget.maxBounds!)
              : const CameraConstraint.unconstrained()),
          backgroundColor:
              widget.mapLoadingBackgroundColor ?? const Color(0xFFE0E0E0),
          keepAlive: true,
        ),
        mapController: _mapController,
        children: [
          const BingMapsTileLayer(
            apiKey: bingMapsApiKey,
            imagerySet: BingMapsImagerySet.road,
          ),
          if (widget.showCurrentLocationPointer) _buildCurrentLocation(),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return CurrentLocationLayer(
      style: const LocationMarkerStyle(
        markerDirection: MarkerDirection.heading,
        headingSectorRadius: 60,
        markerSize: Size(18, 18),
      ),
    );
  }

  Widget _buildMarker() {
    return Positioned.fill(
      bottom: widget.markerIconOffset,
      child: IgnorePointer(
        child: Center(
          child: widget.markerIcon ??
              const Icon(
                Icons.location_pin,
                color: Colors.blue,
                size: 50,
              ),
        ),
      ),
    );
  }

  Widget _buildSelectButton() {
    return Positioned(
      top: widget.selectLocationButtonPositionTop,
      bottom: widget.selectLocationButtonPositionBottom,
      left: widget.selectLocationButtonPositionLeft,
      right: widget.selectLocationButtonPositionRight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WideButton(
            widget.selectLocationButtonText,
            leadingIcon: widget.selectLocationButtonLeadingIcon,
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              LatLng center = LatLng(_mapController.camera.center.latitude,
                  _mapController.camera.center.longitude);
              pickData(center).then((value) {
                widget.onPicked(value);
              }, onError: (e) => onError(e)).whenComplete(
                () => setState(
                  () {
                    isLoading = false;
                  },
                ),
              );
            },
            style: widget.selectLocationButtonStyle,
            textStyle: widget.selectedLocationButtonTextstyle,
            width: widget.selectLocationButtonWidth,
            height: widget.selectLocationButtonHeight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMap(),
        if (!isLoading) _buildMarker(),
        if (isLoading) Center(child: widget.loadingWidget!),
        SafeArea(
          child: Stack(
            children: [
              _buildControllerButtons(),
              if (widget.showSearchBar) _buildSearchBar(),
              if (widget.showSelectLocationButton) _buildSelectButton(),
            ],
          ),
        )
      ],
    );
  }
}

class WideButton extends StatelessWidget {
  const WideButton(
    this.text, {
    super.key,
    this.padding = 0.0,
    this.height = 45,
    this.width,
    required this.onPressed,
    this.style,
    this.textStyle = const TextStyle(fontSize: 20),
    this.leadingIcon,
  });

  final String text;
  final double padding;
  final double? height;
  final double? width;
  final ButtonStyle? style;
  final TextStyle textStyle;
  final Widget? leadingIcon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: width ??
          (MediaQuery.of(context).size.width <= 500
              ? MediaQuery.of(context).size.width
              : 350),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
