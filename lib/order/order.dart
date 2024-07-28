import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery/location/api.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../common/components.dart';
import 'api.dart';

class CartPage extends StatefulWidget {
  final Map cartData;
  final List productsData;
  final double totalPrice;

  const CartPage(
      {super.key,
      required this.cartData,
      required this.productsData,
      required this.totalPrice});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  late double? deliveryCharge = null;
  late bool placing = false;

  Future<void> _getDeliveryCharge() async {
    try {
      setState(() {
        deliveryCharge = null;
      });
      if (widget.productsData.isNotEmpty) {
        deliveryCharge = await getDeliveryCharge(
          widget.productsData[0]['restaurant']['id'],
          '${homeKey.currentState!.location.latitude}',
          '${homeKey.currentState!.location.longitude}',
        );
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getDeliveryCharge();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return homeKey.currentState!.hasLoadedCartData
        ? (widget.cartData['entries'] ?? []).length == 0
            ? const Center(
                child: Text('Your Cart is Empty'),
              )
            : RefreshIndicator.adaptive(
                onRefresh: () async {
                  await homeKey.currentState!
                      .updateCartRestaurantProductsData();
                  await homeKey.currentState!.updateCartData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      for (int i = 0;
                          i < widget.cartData['entries'].length;
                          i++)
                        CartEntry(
                          cartEntryData: widget.cartData['entries'][i],
                          index: i,
                          productData: widget.productsData.firstWhere(
                            (e) =>
                                e['id'] ==
                                widget.cartData['entries'][i]['product'],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Product Total: ',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '₹${widget.totalPrice}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      if (deliveryCharge != 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Delivery Charge: ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '${deliveryCharge ?? 'Loading...'}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      if (deliveryCharge != 0)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Order Total: ',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(
                                deliveryCharge == null
                                    ? 'Loading...'
                                    : '₹${widget.totalPrice + (deliveryCharge ?? 0)}',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          height: 320,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              PickedLocationDisplay(
                                location: homeKey.currentState!.location,
                                onLocationChanged: (location) async {
                                  homeKey.currentState!.location = location;
                                  await homeKey.currentState!.updateAddress();
                                  await _getDeliveryCharge();
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 64),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black87,
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: Colors.white70,
                                  ),
                                  title: Text(homeKey.currentState!.address),
                                  subtitle: const Text(
                                      'Tap to edit Delivery Location'),
                                  titleTextStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer;
                                }
                                return Theme.of(context)
                                    .colorScheme
                                    .primaryContainer;
                              },
                            ),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer
                                      .withAlpha(128);
                                }
                                return Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer;
                              },
                            ),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            textStyle: const WidgetStatePropertyAll(
                              TextStyle(fontSize: 24),
                            ),
                            minimumSize: const WidgetStatePropertyAll(
                              Size(double.infinity, 40),
                            ),
                            maximumSize: const WidgetStatePropertyAll(
                              Size.infinite,
                            ),
                          ),
                          onPressed: (deliveryCharge ?? 0) == 0 || placing
                              ? null
                              : () async {
                                  try {
                                    setState(() {
                                      placing = true;
                                    });
                                    await placeOrder(() => {});
                                    homeKey.currentState!.updateOrdersData();
                                    setState(() {
                                      placing = false;
                                    });
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                },
                          child: Text(
                            deliveryCharge == null || placing
                                ? 'Please wait'
                                : deliveryCharge == 0
                                    ? 'Not deliverable to this location'
                                    : 'Place Order',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
        : Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class CartEntry extends StatelessWidget {
  final Map cartEntryData;
  final Map productData;
  final int index;

  const CartEntry(
      {super.key,
      required this.cartEntryData,
      required this.index,
      required this.productData});

  Future<void> _addVariant(Map variant) async {
    String variantId = '${variant['id']}';
    await addVariant(index, variantId);
    cartEntryData['quantities'][variantId] = 1;
    await homeKey.currentState!.updateCartData();
  }

  Future<void> _changeQuantity(
      String variantId, List variants, int value) async {
    cartEntryData['quantities'][variantId] = value;
    await changeQuantity(index, variantId, variants, value);
    await homeKey.currentState!.updateCartData();
  }

  @override
  Widget build(BuildContext context) {
    late List<Map> unselectedVariants = [];
    late double total = 0;
    for (var variant in productData['variants']) {
      if (((cartEntryData['quantities']['${variant['id']}']) ?? 0) == 0) {
        unselectedVariants.add(variant);
      } else {
        total +=
            variant['price'] * cartEntryData['quantities']['${variant['id']}'];
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(64),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 256,
                  child: productData['image'] != null
                      ? CachedNetworkImage(
                          imageUrl: productData['image'],
                          imageBuilder: (context, imageProvider) =>
                              SizedBox.expand(
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                            ),
                          ),
                          errorWidget: (context, url, error) => SizedBox.expand(
                            child: Image.asset(
                              'assets/food.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : SizedBox.expand(
                          child: Image.asset(
                            'assets/food.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 96),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.restaurant,
                      color: Colors.white70,
                    ),
                    title: Text(productData['name']),
                    subtitle: Text(productData['restaurant']['restaurantName']),
                    titleTextStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      productData['description'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < productData['variants'].length; i++)
              if (((cartEntryData['quantities']
                          ['${productData['variants'][i]['id']}']) ??
                      0) >
                  0)
                VariantEntry(
                  cartEntryData: cartEntryData,
                  index: i,
                  changeQuantity: _changeQuantity,
                  productData: productData,
                ),
            if (unselectedVariants.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add:',
                      style: TextStyle(fontSize: 20),
                    ),
                    VariantSelector(
                      variants: unselectedVariants,
                      onSelected: (index) {
                        _addVariant(unselectedVariants[index]);
                      },
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '₹$total',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VariantSelector extends StatelessWidget {
  final List variants;
  final void Function(int index) onSelected;

  final TextEditingController variantController = TextEditingController();

  VariantSelector(
      {super.key, required this.variants, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      width: 256,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      ),
      controller: variantController,
      requestFocusOnTap: true,
      label: const Text('Select variant'),
      onSelected: (index) {
        onSelected(index ?? 0);
      },
      dropdownMenuEntries: [
        for (int i = 0; i < variants.length; i++)
          DropdownMenuEntry<int>(
            value: i,
            label: '${variants[i]['name']} ₹${variants[i]['price']}',
            enabled: variantController.text != '$i',
          )
      ],
    );
  }
}

class VariantEntry extends StatelessWidget {
  final Map cartEntryData;
  final Map productData;
  final int index;
  final void Function(String variantId, List variants, int quantity)
      changeQuantity;

  VariantEntry(
      {super.key,
      required this.cartEntryData,
      required this.index,
      required this.changeQuantity,
      required this.productData});

  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _quantityController.text =
        '${cartEntryData['quantities']['${productData['variants'][index]['id']}']}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                productData['variants'][index]['name'],
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '₹${productData['variants'][index]['price']}',
                style: const TextStyle(fontSize: 16),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => changeQuantity(
                        '${productData['variants'][index]['id']}',
                        productData['variants'],
                        int.parse(_quantityController.text) - 1),
                    icon: const Icon(Icons.remove_circle_rounded),
                  ),
                  SizedBox(
                    width: 64,
                    child: Form(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 8, right: 8),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          helperText: 'Quantity',
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            changeQuantity(
                                '${productData['variants'][index]['id']}',
                                productData['variants'],
                                int.parse(value));
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => changeQuantity(
                        '${productData['variants'][index]['id']}',
                        productData['variants'],
                        int.parse(_quantityController.text) + 1),
                    icon: const Icon(Icons.add_circle_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 24, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_quantityController.text} x ₹${productData['variants'][index]['price']}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '₹${productData['variants'][index]['price'] * double.parse(_quantityController.text)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrderPage extends StatefulWidget {
  final Map preLoadedData;
  final bool past;

  const OrderPage({super.key, required this.preLoadedData, this.past = false});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  final Map status = {
    'PL': 'Placed',
    'CK': 'Cooking',
    'WT': 'Waiting for Pickup',
    'PU': 'Picked Up',
    'AR': 'Arrived at location',
    'DL': 'Delivered',
    'XC': 'Cancelled',
    'XR': 'Cancelled by restaurant',
    'XD': 'Cancelled by delivery partner',
    'LD': 'Loading...',
  };

  late Map orderData = {};
  late bool _isRefreshing = true;
  late SystemUiOverlayStyle _currentStyle;
  late String _placedOn;
  late String _restaurantAddress = 'Loading...';
  late String _deliveryAddress = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _getData() async {
    if (orderData['restaurant'] != null) _getRestaurantAddress();
    if (orderData['latitude'] != null && orderData['longitude'] != null) {
      _getDeliveryAddress();
    }
    await _getOrderData();
    _getRestaurantAddress();
    _getDeliveryAddress();
  }

  Future<void> _getOrderData() async {
    try {
      setState(() {
        orderData = widget.preLoadedData;
      });
      if (!widget.past) {
        orderData = await getOrder(() => {}, widget.preLoadedData['id']);
      }
      setState(() {
        _isRefreshing = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getRestaurantAddress() async {
    getAddress(double.parse(orderData['restaurant']['latitude']),
            double.parse(orderData['restaurant']['longitude']))
        .then(
      (address) {
        List splitAddress = address.split(', ');
        splitAddress.removeRange(3, 5);
        setState(() {
          _restaurantAddress = splitAddress.join(', ');
        });
      },
    );
  }

  Future<void> _getDeliveryAddress() async {
    getAddress(double.parse(orderData['latitude']),
            double.parse(orderData['longitude']))
        .then(
      (address) {
        List splitAddress = address.split(', ');
        splitAddress.removeRange(3, 5);
        setState(() {
          _deliveryAddress = splitAddress.join(', ');
        });
      },
    );
  }

  void _changeColor() {
    setState(() {
      _currentStyle =
          Theme.of(context).appBarTheme.systemOverlayStyle?.copyWith(
                    statusBarColor: Colors.transparent,
                  ) ??
              const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    });
  }

  @override
  Widget build(BuildContext context) {
    _placedOn = readableDateTime(orderData['placedOn']) ?? 'Loading';
    _changeColor();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentStyle,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Badge(
              isLabelVisible:
                  homeKey.currentState!.pendingOrdersData.isNotEmpty,
              label: Text('${homeKey.currentState!.pendingOrdersData.length}'),
              child: const Icon(Icons.arrow_back),
            ),
            onPressed: () {
              Navigator.popUntil(context, (route) {
                return route.isFirst;
              });
            },
          ),
          title: const Text('Order Details'),
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: widget.past ? () async {} : _getOrderData,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            orderData['restaurant']?['restaurantName'] ??
                                'Loading',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            'Order #${orderData['id']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Placed on: ',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(_placedOn, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status: ',
                              style: TextStyle(fontSize: 14)),
                          Text(
                            status[orderData['status'] ?? 'LD'],
                            style: TextStyle(
                              fontSize: 14,
                              color: orderData['status'] == 'PL'
                                  ? Theme.of(context).colorScheme.primary
                                  : orderData['status'] == 'CK'
                                      ? Colors.orange.harmonizeWith(
                                          Theme.of(context).colorScheme.primary)
                                      : orderData['status'] == 'WT'
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : orderData['status'] == 'PU'
                                              ? Colors.orange.harmonizeWith(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary)
                                              : orderData['status'] == 'AR'
                                                  ? Colors.orange.harmonizeWith(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary)
                                                  : orderData['status'] == 'DL'
                                                      ? Colors.green
                                                          .harmonizeWith(
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary)
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0;
                        i < (orderData['entries']?.length ?? 0);
                        i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                            OrderEntry(orderEntryData: orderData['entries'][i]),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Product Total: ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            '₹${orderData['productTotal'] ?? 'Loading'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Charge: ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            '₹${orderData['deliveryCharge'] ?? 'Loading'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Total: ',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '₹${(orderData['productTotal'] ?? 0) + (orderData['deliveryCharge'] ?? 0)}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.past)
                      OrderStatusUpdate(
                        orderData: orderData,
                        onClick: () {
                          orderData['status'] = 'LD';
                          setState(() {});
                        },
                        onUpdate: () {
                          _getOrderData();
                          setState(() {});
                        },
                      ),
                    ListTile(
                      onTap: () => href(context,
                          scheme: 'tel',
                          path:
                              '+91${orderData['restaurant']?['user']?['username'] ?? 'Loading'}'),
                      leading: Icon(
                        Icons.phone_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      title: Text(
                          '+91 ${orderData['restaurant']?['user']?['username'] ?? 'Loading'}'),
                      subtitle: const Text('Contact Restaurant'),
                    ),
                    ListTile(
                      onTap: () => href(
                        context,
                        url:
                            'https://www.google.com/maps/search/${orderData['restaurant']['latitude']},${orderData['restaurant']['longitude']}',
                      ),
                      leading: Icon(
                        Icons.storefront_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(_restaurantAddress),
                      subtitle: const Text('Restaurant Location'),
                    ),
                    ListTile(
                      onTap: () => href(
                        context,
                        url:
                            'https://www.google.com/maps/search/${orderData['latitude']},${orderData['longitude']}',
                      ),
                      leading: Icon(
                        Icons.room_service_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      title: Text(_deliveryAddress),
                      subtitle: const Text('Delivery Location'),
                    ),
                    if (orderData['deliveryMan'] != null)
                      OrderProfile(profile: orderData['deliveryMan']),
                    if (orderData['customer'] != null)
                      OrderProfile(profile: orderData['customer']),
                  ],
                ),
              ),
              if (_isRefreshing)
                const Padding(
                    padding: EdgeInsets.all(48),
                    child: RefreshProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderEntry extends StatelessWidget {
  final Map orderEntryData;

  const OrderEntry({super.key, required this.orderEntryData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderEntryData['product']['name'],
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                '₹${orderEntryData['subtotal']}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        for (int i = 0; i < orderEntryData['variants'].length; i++)
          if (orderEntryData['variants'][i]['quantity'] > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${orderEntryData['variants'][i]['name']} (${orderEntryData['variants'][i]['quantity']} x ₹${orderEntryData['variants'][i]['cost']})'),
                Text('₹${orderEntryData['variants'][i]['price']}'),
              ],
            ),
      ],
    );
  }
}

class Order extends StatelessWidget {
  final Map orderData;
  final Map status = {
    'PL': 'Placed',
    'CK': 'Cooking',
    'WT': 'Waiting for Pickup',
    'PU': 'Picked Up',
    'AR': 'Arrived at location',
    'DL': 'Delivered',
    'XC': 'Cancelled',
    'XR': 'Cancelled by restaurant',
    'XD': 'Cancelled by delivery partner',
    'LD': 'Loading...',
  };

  Order({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    String placedOn = readableDateTime(orderData['placedOn']) ?? 'Loading';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: orderData['status'] == 'PL'
              ? Theme.of(context).colorScheme.primaryContainer
              : orderData['status'] == 'CK'
                  ? Colors.orange
                      .harmonizeWith(
                          Theme.of(context).colorScheme.primaryContainer)
                      .withAlpha(64)
                  : orderData['status'] == 'WT'
                      ? Theme.of(context).colorScheme.primaryContainer
                      : orderData['status'] == 'PU'
                          ? Colors.orange
                              .harmonizeWith(Theme.of(context)
                                  .colorScheme
                                  .primaryContainer)
                              .withAlpha(64)
                          : orderData['status'] == 'AR'
                              ? Colors.orange
                                  .harmonizeWith(Theme.of(context)
                                      .colorScheme
                                      .primaryContainer)
                                  .withAlpha(64)
                              : orderData['status'] == 'DL'
                                  ? Colors.green
                                      .harmonizeWith(Theme.of(context)
                                          .colorScheme
                                          .primaryContainer)
                                      .withAlpha(64)
                                  : Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withAlpha(64),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderData['restaurant']['restaurantName'],
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  '₹${orderData['productTotal'] + orderData['deliveryCharge']}',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status[orderData['status']],
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  placedOn,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if ((homeKey.currentState!.userData['profile'] ?? {})['kind'] !=
                'C')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Customer: ${orderData['customer']['user']['first_name']} ${orderData['customer']['user']['last_name']}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            for (int i = 0; i < orderData['entries'].length; i++)
              OrderEntry(orderEntryData: orderData['entries'][i]),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery and Service',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '₹${orderData['deliveryCharge']}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final List pendingOrdersData;
  final List completedOrdersData;

  const OrderList(
      {super.key,
      required this.pendingOrdersData,
      required this.completedOrdersData});

  @override
  Widget build(BuildContext context) {
    return homeKey.currentState!.hasLoadedOrdersData
        ? Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                RefreshIndicator.adaptive(
                  onRefresh: () async {
                    await homeKey.currentState!.updateOrdersData();
                  },
                  child: ListView(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (pendingOrdersData.isEmpty &&
                          completedOrdersData.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: ListTile(
                              leading: const Icon(
                                Icons.receipt_long_rounded,
                                size: 64,
                              ),
                              title: const Text('No Orders'),
                              subtitle: Text(
                                (homeKey.currentState!.userData['profile'] ??
                                            {})['kind'] ==
                                        'C'
                                    ? 'You have never ordered from us. Add items to cart from the Food page to place an order.'
                                    : (homeKey.currentState!
                                                    .userData['profile'] ??
                                                {})['kind'] ==
                                            'R'
                                        ? 'No one has ever ordered from your restaurant.'
                                        : 'You have never delivered any orders.',
                              ),
                            ),
                          ),
                        ),
                      for (var order in pendingOrdersData)
                        GestureDetector(
                          child: Order(
                            orderData: order,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return OrderPage(
                                    preLoadedData: order,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      for (var order in completedOrdersData)
                        GestureDetector(
                          child: Order(orderData: order),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return OrderPage(
                                    preLoadedData: order,
                                    past: true,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                if (homeKey.currentState!.isLoadingOrdersData)
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                      child: const Text('Refreshing...'),
                    ),
                  )
              ],
            ),
          )
        : Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class OrderProfile extends StatelessWidget {
  final Map profile;

  const OrderProfile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(64),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                profile['kind'] == 'D'
                    ? Icons.delivery_dining_rounded
                    : Icons.face,
                size: 32,
                color: profile['kind'] == 'D'
                    ? Colors.orange
                        .harmonizeWith(Theme.of(context).colorScheme.primary)
                    : Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                  '${profile['user']['first_name']} ${profile['user']['last_name']}'),
              subtitle:
                  Text(profile['kind'] == 'D' ? 'Delivery Person' : 'Customer'),
            ),
            ListTile(
              onTap: () => href(context,
                  scheme: 'tel', path: '+91${profile['user']['username']}'),
              leading: Icon(
                Icons.phone_rounded,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              title: Text('+91 ${profile['user']['username']}'),
            )
          ],
        ),
      ),
    );
  }
}

class OrderStatusUpdate extends StatelessWidget {
  final Map orderData;
  final void Function() onClick;
  final void Function() onUpdate;

  const OrderStatusUpdate(
      {super.key,
      required this.orderData,
      required this.onUpdate,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        if ((homeKey.currentState!.userData['profile']['kind'] == 'R' &&
                ['PL', 'CK', 'WT'].contains(orderData['status'])) ||
            (homeKey.currentState!.userData['profile']['kind'] == 'D' &&
                ['PL', 'PU', 'AR'].contains(orderData['status'])) ||
            (homeKey.currentState!.userData['profile']['kind'] == 'C' &&
                orderData['status'] == 'PL'))
          // Cancel
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.error),
              foregroundColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.onError),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              if (await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content:
                      const Text('Are you sure you want to cancel the order?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('No'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              )) {
                onClick();
                await cancelOrder(() => {}, orderData['id']);
                onUpdate();
                homeKey.currentState!.updateOrdersData();
              }
            },
          ),
        if (homeKey.currentState!.userData['profile']['kind'] == 'R' &&
            orderData['status'] == 'PL')
          // Accept
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green
                  .harmonizeWith(Theme.of(context).colorScheme.primary)),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onSecondary),
            ),
            child: const Text(
              'Accept Order',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              onClick();
              await acceptOrder(() => {}, orderData['id']);
              onUpdate();
              homeKey.currentState!.updateOrdersData();
            },
          ),
        if (homeKey.currentState!.userData['profile']['kind'] == 'R' &&
            orderData['status'] == 'CK')
          // Cooking Finished
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green
                  .harmonizeWith(Theme.of(context).colorScheme.primary)),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onSecondary),
            ),
            child: const Text(
              'Cooking Finished',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              onClick();
              await orderCookingFinished(() => {}, orderData['id']);
              onUpdate();
              homeKey.currentState!.updateOrdersData();
            },
          ),
        if (homeKey.currentState!.userData['profile']['kind'] == 'D' &&
            orderData['status'] == 'WT')
          // Picked Up
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary),
            ),
            child: const Text(
              'Picked Up',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              onClick();
              await orderPickedUp(() => {}, orderData['id']);
              onUpdate();
              homeKey.currentState!.updateOrdersData();
            },
          ),
        if (homeKey.currentState!.userData['profile']['kind'] == 'D' &&
            orderData['status'] == 'PU')
          // Arrived
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green
                  .harmonizeWith(Theme.of(context).colorScheme.primary)),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onSecondary),
            ),
            child: const Text(
              'Arrived',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              onClick();
              await orderArrived(() => {}, orderData['id']);
              onUpdate();
              homeKey.currentState!.updateOrdersData();
            },
          ),
        if (homeKey.currentState!.userData['profile']['kind'] == 'D' &&
            orderData['status'] == 'AR')
          for (Widget widget in [
            // Take Payment
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green
                    .harmonizeWith(Theme.of(context).colorScheme.primary)),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: const Text(
                'Take Payment',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Scan to Pay with UPI'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Thanks for ordering from us',
                            style: TextStyle(fontSize: 18),
                          ),
                          const Text(
                            'Bon Appétit!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          UPIPaymentQRCode(
                            upiDetails: UPIDetails(
                              upiID: orderData['deliveryMan']['upiID'],
                              payeeName:
                                  'FoodEx delivery partner ${orderData['deliveryMan']['user']['first_name']} ${orderData['deliveryMan']['user']['last_name']}',
                              amount: (orderData['productTotal'] ?? 0) +
                                  (orderData['deliveryCharge'] ?? 0),
                              transactionNote:
                                  'FoodEx Order #${orderData['id']} Payment',
                            ),
                            upiQRErrorCorrectLevel: UPIQRErrorCorrectLevel.high,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            '₹${(orderData['productTotal'] ?? 0) + (orderData['deliveryCharge'] ?? 0)}',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Paying: ${orderData['deliveryMan']['user']['first_name']} ${orderData['deliveryMan']['user']['last_name']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            'UPI ID: ${orderData['deliveryMan']['upiID']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // Delivered
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green
                    .harmonizeWith(Theme.of(context).colorScheme.primary)),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: const Text(
                'Delivered',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                if (await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text(
                        'Are you sure? Please mark as delivered only after receiving payment from the customer'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Go back'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Mark as Delivered'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                )) {
                  onClick();
                  await orderDelivered(() => {}, orderData['id']);
                  onUpdate();
                  homeKey.currentState!.updateOrdersData();
                }
              },
            ),
          ])
            widget,
        if (homeKey.currentState!.userData['profile']['kind'] == 'D' &&
            orderData['status'] == 'DL' &&
            orderData['paymentStatus'] == 'RC')
          for (Widget widget in [
            // Pay Restaurant
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green
                    .harmonizeWith(Theme.of(context).colorScheme.primary)),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: const Text(
                'Pay Restaurant',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => href(
                context,
                scheme: 'upi',
                host: 'pay',
                path:
                    '?pa=${orderData['restaurant']['upiID']}&pn=${orderData['restaurant']['restaurantName']}&am=${orderData['productTotal']}&cu=INR&mc=0000&mode=02&purpose=00&tn=FoodEx%20Order%20#${orderData['id']}%20Payment',
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green
                    .harmonizeWith(Theme.of(context).colorScheme.primary)),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: const Text(
                'Paid to Restaurant',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                if (await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text(
                        'Are you sure? Please mark as Paid to Restaurant only after you paid the restaurant'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Go back'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Mark as Paid'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                )) {
                  onClick();
                  await orderPaidToRestaurant(() => {}, orderData['id']);
                  onUpdate();
                  homeKey.currentState!.updateOrdersData();
                }
              },
            ),
          ])
            widget,
        if (homeKey.currentState!.userData['profile']['kind'] == 'R' &&
            orderData['status'] == 'DL' &&
            orderData['paymentStatus'] == 'WT')
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green
                  .harmonizeWith(Theme.of(context).colorScheme.primary)),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onSecondary),
            ),
            child: const Text(
              'Payment Received',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              if (await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text(
                      'Are you sure? Please mark as Payment Received only after you received payment for this order from our delivery partner after delivery'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Go back'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Mark as Payment Received'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              )) {
                onClick();
                await orderPaidToRestaurantConfirm(() => {}, orderData['id']);
                onUpdate();
                homeKey.currentState!.updateOrdersData();
              }
            },
          ),
      ],
    );
  }
}
