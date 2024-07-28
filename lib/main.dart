import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:food_delivery/location/api.dart';
import 'package:food_delivery/restaurant/api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_options.dart';
import 'common/api.dart';
import 'common/components.dart';
import 'order/api.dart';
import 'order/order.dart';
import 'user/api.dart';
import 'user/user.dart';
import 'restaurant/restaurant.dart';

SnackBarThemeData? snackBarTheme(ColorScheme? colorScheme) {
  return (colorScheme != null)
      ? SnackBarThemeData(
          actionTextColor: colorScheme.primary,
          disabledActionTextColor: colorScheme.secondary,
          backgroundColor: colorScheme.secondaryContainer,
          contentTextStyle: TextStyle(color: colorScheme.onSecondaryContainer),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
          behavior: SnackBarBehavior.floating,
          closeIconColor: colorScheme.primary,
          actionBackgroundColor: colorScheme.primaryContainer,
          disabledActionBackgroundColor: colorScheme.secondaryContainer,
        )
      : null;
}

// SystemUiOverlayStyle? systemUiOverlayStyle(ColorScheme? colorScheme) {
//   return (colorScheme != null)
//       ? SystemUiOverlayStyle(
//           systemNavigationBarColor: ElevationOverlay.applySurfaceTint(
//               colorScheme.surface, colorScheme.surfaceTint, 3),
//           statusBarColor: ElevationOverlay.applySurfaceTint(
//               colorScheme.surface, colorScheme.surfaceTint, 3),
//           systemNavigationBarIconBrightness:
//               colorScheme.brightness == Brightness.dark
//                   ? Brightness.light
//                   : Brightness.dark,
//           statusBarBrightness: colorScheme.brightness,
//           statusBarIconBrightness: colorScheme.brightness == Brightness.dark
//               ? Brightness.light
//               : Brightness.dark,
//         )
//       : null;
// }

AppBarTheme? appBarTheme(ColorScheme? colorScheme) {
  return (colorScheme != null)
      ? AppBarTheme(
          backgroundColor: ElevationOverlay.applySurfaceTint(
              colorScheme.surface, colorScheme.surfaceTint, 3),
          foregroundColor: colorScheme.primary,
          // systemOverlayStyle: systemUiOverlayStyle(colorScheme),
        )
      : null;
}

NavigationBarThemeData? navigationBarTheme(ColorScheme? colorScheme) {
  return (colorScheme != null)
      ? NavigationBarThemeData(
          surfaceTintColor: colorScheme.surfaceTint,
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.primary.withAlpha(64),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        )
      : null;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.requestPermission();
  await firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  final fcmtoken = await firebaseMessaging.getToken();
  await store('fcmtoken', fcmtoken);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
        return MaterialApp(
          scaffoldMessengerKey: scaffoldKey,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            appBarTheme: appBarTheme(lightColorScheme),
            snackBarTheme: snackBarTheme(lightColorScheme),
            navigationBarTheme: navigationBarTheme(lightColorScheme),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            appBarTheme: appBarTheme(darkColorScheme),
            snackBarTheme: snackBarTheme(darkColorScheme),
            navigationBarTheme: navigationBarTheme(darkColorScheme),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: Home(
            homeKey: homeKey,
          ),
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  final Key homeKey;

  const Home({required this.homeKey}) : super(key: homeKey);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ProductListState> _productListKey = GlobalKey();

  late SystemUiOverlayStyle _currentStyle;
  late List pendingOrdersData = [];
  late List completedOrdersData = [];
  late Map cartData = {'restaurant': 0, 'entries': []};
  late Map userData = {};
  late List selectedProducts = [];
  late List productsData = [];
  late List cartRestaurantProductsData = [];
  late int cartCount = 0;
  late double cartTotalPrice = 0;
  late LatLng location = const LatLng(0, 0);
  late String address = '';
  late bool hasLoadedLocation = false;
  late bool isLoadingLocation = true;
  late bool hasLoadedOrdersData = false;
  late bool isLoadingOrdersData = true;
  late bool hasLoadedCartData = false;
  late bool isLoadingCartData = true;
  late bool hasLoadedcartRestaurantProductsData = false;
  late bool isLoadingcartRestaurantProductsData = true;
  late bool hasLoadedUserData = false;
  late bool isLoadingUserData = true;
  late bool hasLoadedProductsData = false;
  late bool isLoadingProductsData = true;
  late int pageIndex = 0;

  Future<bool> _onWillPop() async {
    if (pageIndex == 0) {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    } else {
      setState(() {
        pageIndex = 0;
      });
      return false;
    }
  }

  Future<void> setupInteractedMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['open'] == 'order') {
      goToOrders();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return OrderPage(
              preLoadedData: {'id': int.parse(message.data['id'])});
        }),
      );
    }
  }

  void _listenForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title ?? ''),
            content: Text(notification.body ?? ''),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
              TextButton(
                onPressed: () => _handleMessage(message),
                child: const Text('View now'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> getData() async {
    await getLocation();
    await updateOrdersData();
    if (userData['profile']?['kind'] == 'R') {
      await updateProductsData((userData['profile'] ?? {'id': 0})['id']);
    } else if (userData['profile']?['kind'] == 'C' ||
        userData['profile']?['kind'] == null) {
      await updateCartData();
    }
    await setupInteractedMessage();
  }

  Future<void> updateProductsData(int restaurantId) async {
    try {
      setState(() {
        isLoadingProductsData = true;
      });
      productsData = await getProducts(query: 'restaurant=$restaurantId');
      setState(() {
        hasLoadedProductsData = true;
        isLoadingProductsData = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUserData() async {
    try {
      setState(() {
        isLoadingUserData = true;
      });
      String? fcmtoken = await readStorage('fcmtoken');
      Map fetchedUserData = await getSelfUser(() => {});
      setState(() {
        userData = fetchedUserData;
        hasLoadedUserData = true;
        isLoadingUserData = false;
      });
      if (fetchedUserData['profile'] != null &&
          fetchedUserData['profile']?['fcmtoken'] != fcmtoken) {
        updateProfile(() => null, {'fcmtoken': fcmtoken});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateCartData() async {
    try {
      setState(() {
        isLoadingCartData = true;
      });
      cartCount = 0;
      cartTotalPrice = 0;
      cartData =
          json.decode((await readStorage('cart')) ?? json.encode(cartData));
      if (!hasLoadedCartData ||
          (cartRestaurantProductsData.isEmpty
                  ? {
                      'restaurant': {'id': 0}
                    }
                  : cartRestaurantProductsData[0])['restaurant']['id'] !=
              cartData['restaurant']) {
        await updateCartRestaurantProductsData();
      }
      if (cartRestaurantProductsData.isNotEmpty &&
          cartRestaurantProductsData[0]['restaurant']['available'] == false) {
        for (int i = 0; i < (cartData['entries'] ?? []).length; i++) {
          await removeFromCart(i);
        }
        return await updateCartData();
      }
      for (int i = 0; i < (cartData['entries'] ?? []).length; i++) {
        if (!cartRestaurantProductsData
            .any((e) => e['id'] == cartData['entries'][i]['product'])) {
          await removeFromCart(i);
          return await updateCartData();
        }
        if (cartRestaurantProductsData.any((e) =>
            (e['id'] == cartData['entries'][i]['product'] &&
                e['available'] == false))) {
          await removeFromCart(i);
          return await updateCartData();
        }
        int productCount = 0;
        double productPrice = 0;
        for (var variant in cartRestaurantProductsData.firstWhere(
            (e) => e['id'] == cartData['entries'][i]['product'])['variants']) {
          productCount +=
              ((cartData['entries'][i]['quantities']['${variant['id']}']) ?? 0)
                  as int;
          productPrice +=
              (((cartData['entries'][i]['quantities']['${variant['id']}']) ?? 0)
                      as int) *
                  variant['price'];
        }
        cartCount += productCount;
        cartTotalPrice += productPrice;
        if (productPrice == 0) {
          await removeFromCart(
            cartData['entries'].indexWhere(
                (e) => e['product'] == cartData['entries'][i]['product']),
          );
          return await updateCartData();
        }
      }
      setState(() {
        hasLoadedCartData = true;
        isLoadingCartData = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateCartRestaurantProductsData() async {
    try {
      setState(() {
        isLoadingcartRestaurantProductsData = true;
      });
      cartRestaurantProductsData =
          await getProducts(query: 'restaurant=${cartData['restaurant']}');
      setState(() {
        hasLoadedcartRestaurantProductsData = true;
        isLoadingcartRestaurantProductsData = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateOrdersData() async {
    try {
      setState(() {
        isLoadingOrdersData = true;
      });
      if (!hasLoadedUserData) {
        await updateUserData();
      }
      List fetchedPendingOrdersData = [];
      List fetchedCompletedOrdersData = [];
      if (userData['profile'] != null) {
        fetchedPendingOrdersData = await getPendingOrders(() {});
        fetchedCompletedOrdersData = await getPastOrders(() {});
      }
      setState(() {
        pendingOrdersData = fetchedPendingOrdersData;
        completedOrdersData = fetchedCompletedOrdersData;
        hasLoadedOrdersData = true;
        isLoadingOrdersData = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getLocation() async {
    updateLocation();
    await readLocation();
  }

  Future<void> readLocation() async {
    location = await getLastCoordinates() ?? location;
    await updateAddress();
  }

  Future<void> updateLocation() async {
    setState(() {
      isLoadingLocation = true;
    });
    LatLng? fetchedLocation = await getCoordinates();
    if (fetchedLocation != null) {
      if (!hasLoadedLocation) {
        location = fetchedLocation;
      }
      hasLoadedLocation = true;
    }
    isLoadingLocation = false;
    await updateAddress();
  }

  Future<String> updateAddress() async {
    try {
      address = await getAddress(location.latitude, location.longitude);
      setState(() {});
      return address;
    } catch (e) {
      debugPrint(e.toString());
      return "";
    }
  }

  void goToCart() => setState(() => pageIndex = 1);

  void goToOrders() => setState(() {
        if (userData['profile']?['kind'] == 'C') {
          pageIndex = 2;
        } else {
          pageIndex = 1;
        }
      });

  void _changeColor() {
    setState(() {
      _currentStyle =
          Theme.of(context).appBarTheme.systemOverlayStyle?.copyWith(
                    statusBarColor: Colors.transparent,
                  ) ??
              const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 20, right: 4),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(64, 0, 0, 0), blurRadius: 1)
        ],
        color: ElevationOverlay.applySurfaceTint(
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceTint,
            3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: (_searchController.text.isNotEmpty)
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
              : const Icon(Icons.search_rounded),
        ),
        onChanged: (query) => getData(),
      ),
    );
  }

  Widget _page({required int index}) {
    if ((userData['profile'] ?? {})['kind'] == 'R' && index == 0) {
      return hasLoadedProductsData
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await updateProductsData(userData['profile']?['id']);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ProductList(
                      key: _productListKey,
                      productsData: productsData,
                      onCart: getData,
                      onSelected: (selected) {
                        setState(() {
                          selectedProducts = selected;
                        });
                      },
                    ),
                  ),
                ),
                if (isLoadingProductsData)
                  Padding(
                    padding: const EdgeInsets.all(128),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withAlpha(224),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Text("Refreshing..."),
                    ),
                  ),
              ],
            )
          : Container(
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.surface),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
    }
    if (((userData['profile'] ?? {})['kind'] == 'C' && index == 0) ||
        ((userData['profile'] ?? {})['kind'] == null && index == 0)) {
      return hasLoadedLocation
          ? Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: FoodPage(),
                ),
                SafeArea(
                  child: _buildSearchBar(),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  if (isLoadingLocation)
                    const CircularProgressIndicator.adaptive(),
                  const SizedBox(height: 32),
                  Text(isLoadingLocation
                      ? "Fetching your location"
                      : "Could not fetch your location"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return Scaffold(
                            body: LocationPicker(
                              onPicked: (location) {
                                homeKey.currentState!.location = location;
                                homeKey.currentState!.hasLoadedLocation = true;
                                Navigator.pop(context);
                                homeKey.currentState!.setState(() {});
                              },
                            ),
                          );
                        }),
                      );
                    },
                    child: const Text('Set Manually'),
                  ),
                ],
              ),
            );
    }
    if (((userData['profile'] ?? {})['kind'] == 'C' && index == 1) ||
        ((userData['profile'] ?? {})['kind'] == null && index == 1)) {
      return CartPage(
        cartData: cartData,
        productsData: cartRestaurantProductsData,
        totalPrice: cartTotalPrice,
      );
    }
    if (((userData['profile'] ?? {})['kind'] == 'C' && index == 2) ||
        ((userData['profile'] ?? {})['kind'] == 'R' && index == 1) ||
        ((userData['profile'] ?? {})['kind'] == 'D' && index == 0)) {
      return OrderList(
        pendingOrdersData: pendingOrdersData,
        completedOrdersData: completedOrdersData,
      );
    }
    if (((userData['profile'] ?? {})['kind'] == 'C' && index == 3) ||
        ((userData['profile'] ?? {})['kind'] == null && index == 2) ||
        ((userData['profile'] ?? {})['kind'] == 'R' && index == 2) ||
        ((userData['profile'] ?? {})['kind'] == 'D' && index == 1)) {
      return Profile(userData: userData);
    }
    return Profile(userData: userData);
  }

  @override
  void initState() {
    super.initState();
    _listenForegroundMessage();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    _changeColor();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentStyle,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: userData['profile']?['kind'] == 'R' && pageIndex == 0
              ? AppBar(
                  title: ListTile(
                    title: Text(selectedProducts.isNotEmpty
                        ? 'Edit Products'
                        : userData['profile']['restaurantName']),
                    subtitle: selectedProducts.isEmpty
                        ? Text(
                            isLoadingUserData
                                ? 'Loading...'
                                : userData['profile']['available']
                                    ? 'Open'
                                    : 'Closed',
                          )
                        : null,
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                    subtitleTextStyle: TextStyle(
                      fontSize: 12,
                      color:
                          userData['profile']['available'] && !isLoadingUserData
                              ? Theme.of(context).appBarTheme.foregroundColor
                              : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  actions: [
                    if (selectedProducts.isNotEmpty)
                      if (!isLoadingProductsData)
                        for (Widget widget in [
                          IconButton(
                            icon: const Icon(Icons.done_all_rounded),
                            onPressed: () {
                              setState(() {
                                selectedProducts = List.from(productsData
                                    .map((e) => e['id'])
                                    .toList(growable: false));
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_done_rounded),
                            onPressed: () {
                              setState(() {
                                selectedProducts = [];
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Product'),
                                    content: const Text(
                                        'Are you sure you want to delete the selected products?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          setState(() {
                                            isLoadingProductsData = true;
                                          });
                                          await deleteProducts(
                                              () => {}, selectedProducts);
                                          setState(() {
                                            selectedProducts = [];
                                            updateProductsData(
                                                userData['profile']?['id']);
                                          });
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            onPressed: () {
                              showMenu(
                                context: context,
                                position:
                                    const RelativeRect.fromLTRB(100, 100, 0, 0),
                                items: [
                                  const PopupMenuItem(
                                    value: 'available',
                                    child: Text('Mark as available'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'unavailable',
                                    child: Text('Mark as unavailable'),
                                  ),
                                ],
                                elevation: 8.0,
                              ).then((value) async {
                                if (value == 'available') {
                                  setState(() {
                                    isLoadingProductsData = true;
                                  });
                                  await markAsAvailable(
                                      () => {}, selectedProducts);
                                  setState(() {
                                    updateProductsData(
                                        userData['profile']?['id']);
                                  });
                                } else if (value == 'unavailable') {
                                  setState(() {
                                    isLoadingProductsData = true;
                                  });
                                  await markAsUnavailable(
                                      () => {}, selectedProducts);
                                  setState(() {
                                    updateProductsData(
                                        userData['profile']?['id']);
                                  });
                                }
                              });
                            },
                          ),
                        ])
                          widget,
                    if (selectedProducts.isEmpty && !isLoadingUserData)
                      for (Widget widget in [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddEditProductPage(
                                    productData: {
                                      'restaurant': {
                                        'id': userData['profile']['id']
                                      }
                                    },
                                    onUpdate: () {
                                      setState(() {
                                        getData();
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded),
                          onPressed: () {
                            showMenu(
                              context: context,
                              position:
                                  const RelativeRect.fromLTRB(100, 100, 0, 0),
                              items: [
                                PopupMenuItem(
                                  value: 'toggleAvailability',
                                  child: Text(userData['profile']['available']
                                      ? 'Close Restaurant'
                                      : 'Open Restaurant'),
                                ),
                              ],
                              elevation: 8.0,
                            ).then((value) async {
                              if (value == 'toggleAvailability') {
                                setState(() {
                                  isLoadingUserData = true;
                                });
                                await toggleAvailability(() => {});
                                setState(() {
                                  updateUserData();
                                });
                              }
                            });
                          },
                        ),
                      ])
                        widget,
                  ],
                )
              : null,
          body: _page(index: pageIndex),
          bottomNavigationBar: NavigationBar(
            selectedIndex: pageIndex,
            onDestinationSelected: (int index) {
              if (((userData['profile'] ?? {})['kind'] == 'C' && index == 2) ||
                  ((userData['profile'] ?? {})['kind'] == 'R' && index == 1) ||
                  ((userData['profile'] ?? {})['kind'] == 'D' && index == 0)) {
                updateOrdersData();
              }
              if (((userData['profile'] ?? {})['kind'] == 'C' && index == 1) ||
                  ((userData['profile'] ?? {})['kind'] == null && index == 1)) {
                () async {
                  await updateCartRestaurantProductsData();
                  await updateCartData();
                }();
              }
              if (((userData['profile'] ?? {})['kind'] == 'R' && index == 0)) {
                updateProductsData(userData['profile']?['id']);
              }
              setState(() {
                pageIndex = index;
              });
            },
            destinations: [
              if ((userData['profile'] ?? {})['kind'] == 'C' ||
                  (userData['profile'] ?? {})['kind'] == 'R' ||
                  (userData['profile'] ?? {})['kind'] == null)
                NavigationDestination(
                  icon: const Icon(Icons.fastfood_outlined),
                  label: (userData['profile'] ?? {})['kind'] == 'R'
                      ? 'Your Products'
                      : 'Food',
                  selectedIcon: const Icon(Icons.fastfood),
                ),
              if ((userData['profile'] ?? {})['kind'] == 'C' ||
                  (userData['profile'] ?? {})['kind'] == null)
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: 'Cart',
                ),
              if ((userData['profile'] ?? {})['kind'] != null)
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: pendingOrdersData.isNotEmpty,
                    label: Text('${pendingOrdersData.length}'),
                    child: Icon(
                      (userData['profile'] ?? {})['kind'] == 'D'
                          ? Icons.delivery_dining_outlined
                          : Icons.receipt_long_outlined,
                    ),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: pendingOrdersData.isNotEmpty,
                    label: Text('${pendingOrdersData.length}'),
                    child: Icon(
                      (userData['profile'] ?? {})['kind'] == 'D'
                          ? Icons.delivery_dining
                          : Icons.receipt_long,
                    ),
                  ),
                  label: (userData['profile'] ?? {})['kind'] == 'C'
                      ? 'Your Orders'
                      : (userData['profile'] ?? {})['kind'] == 'D'
                          ? 'Deliveries'
                          : 'Orders',
                ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
          floatingActionButton: (userData['profile'] ?? {})['kind'] == 'R' &&
                  pageIndex == 0 &&
                  _productListKey.currentState != null
              ? MenuAnchor(
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return FloatingActionButton.extended(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                        setState(() {});
                      },
                      label: const Text('Categories'),
                      icon: Icon(controller.isOpen
                          ? Icons.list_alt_rounded
                          : Icons.menu_book_rounded),
                    );
                  },
                  consumeOutsideTap: true,
                  style: MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primaryContainer),
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  alignmentOffset: const Offset(0, 8),
                  menuChildren: <MenuItemButton>[
                    for (String category
                        in _productListKey.currentState!.categories)
                      MenuItemButton(
                        onPressed: () {
                          _productListKey.currentState!
                              .scrollToCategory(category);
                        },
                        child: Text(category),
                      ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
