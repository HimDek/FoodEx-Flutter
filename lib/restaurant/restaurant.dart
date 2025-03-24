import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../common/components.dart';
import '../location/api.dart';
import '../order/api.dart';
import 'api.dart';

final newVariantNameKey = GlobalKey<FormState>();
final newVariantPriceKey = GlobalKey<FormState>();
final productNameKey = GlobalKey<FormState>();

class RestaurantList extends StatefulWidget {
  final String query;
  final Function(Map) onRestaurantTap;
  const RestaurantList(
      {super.key, this.query = '', required this.onRestaurantTap});
  @override
  RestaurantListState createState() => RestaurantListState();
}

class RestaurantListState extends State<RestaurantList> {
  bool _isLoading = true;

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

  late List restaurantsData;
  _getData() async {
    try {
      restaurantsData = await getRestaurants(query: widget.query);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : RefreshIndicator.adaptive(
            onRefresh: () async {
              await _getData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  for (int i = 0; i < restaurantsData.length; i++)
                    GestureDetector(
                      onTap: () => widget.onRestaurantTap(restaurantsData[i]),
                      child: Restaurant(restaurantData: restaurantsData[i]),
                    ),
                ],
              ),
            ),
          );
  }
}

class RestaurantPage extends StatefulWidget {
  final Map restaurantData;

  const RestaurantPage({super.key, required this.restaurantData});

  @override
  RestaurantPageState createState() => RestaurantPageState();
}

class RestaurantPageState extends State<RestaurantPage> {
  final GlobalKey<ProductListState> _productListKey = GlobalKey();
  late bool _hasLoadedProductsData = false;
  late bool _hasLoadedDistance = false;
  late List _restaurantProductsData;
  late String _address = 'Loading...';
  late double _distance = 0;
  late int _duration = 0;

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

  void _getData() {
    _getProductsData();
    _getAddress();
    _getDistanceDuration();
  }

  Future<void> _getProductsData() async {
    try {
      _restaurantProductsData =
          await getProducts(query: 'restaurant=${widget.restaurantData['id']}');
      setState(() {
        _hasLoadedProductsData = true;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getAddress() async {
    getAddress(double.parse(widget.restaurantData['latitude']),
            double.parse(widget.restaurantData['longitude']))
        .then(
      (address) {
        List splitAddress = address.split(', ');
        splitAddress.removeRange(3, 5);
        setState(() {
          _address = splitAddress.join(', ');
        });
      },
    );
  }

  Future<void> _getDistanceDuration() async {
    getTravelDistanceDuration(widget.restaurantData['latitude'],
            widget.restaurantData['longitude'])
        .then(
      (value) => {
        setState(() {
          _hasLoadedDistance = true;
          _distance = value['distance'];
          _duration = value['duration'];
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(widget.restaurantData['restaurantName']),
          subtitle:
              Text(widget.restaurantData['available'] ? 'Open' : 'Closed'),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 12,
            color: widget.restaurantData['available']
                ? Theme.of(context).appBarTheme.foregroundColor
                : Theme.of(context).colorScheme.error,
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: homeKey.currentState!.cartCount > 0,
              label: Text('${homeKey.currentState!.cartCount}'),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            onPressed: () {
              Navigator.pop(context);
              homeKey.currentState!.goToCart();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getProductsData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 256,
                      child: widget.restaurantData['image'] != null
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget.restaurantData['image'],
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/food.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/food.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                onTap: () => href(
                  context,
                  url:
                      'https://www.google.com/maps/search/${widget.restaurantData['latitude']},${widget.restaurantData['longitude']}',
                ),
                leading: Icon(
                  Icons.location_on_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(_address),
                subtitle: const Text('Location'),
              ),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              ListTile(
                leading: Icon(
                  Icons.route_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title:
                    Text(_hasLoadedDistance ? '$_distance Km' : 'Loading...'),
                subtitle: const Text('Distance'),
              ),
              const SizedBox(height: 16),
              _hasLoadedProductsData
                  ? ProductList(
                      key: _productListKey,
                      productsData: _restaurantProductsData,
                      onCart: () => setState(() {}),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: _hasLoadedProductsData
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
                    in _productListKey.currentState?.categories ?? [])
                  MenuItemButton(
                    onPressed: () {
                      _productListKey.currentState!.scrollToCategory(category);
                    },
                    child: Text(category),
                  ),
              ],
            )
          : null,
    );
  }
}

class Restaurant extends StatelessWidget {
  final Map restaurantData;

  const Restaurant({super.key, required this.restaurantData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(64),
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                image: DecorationImage(
                  image: AssetImage('assets/food.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              height: 256,
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
                  Icons.storefront,
                  color: Colors.white70,
                ),
                title: Text(restaurantData['restaurantName']),
                trailing: restaurantData['available']
                    ? null
                    : Text(
                        'Closed',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ),
            if (!restaurantData['available'])
              Positioned.fill(
                child: SizedBox.expand(
                  child: Container(color: Colors.grey.withAlpha(128)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  final List productsData;
  final void Function() onCart;
  final void Function(List selected)? onSelected;

  const ProductList(
      {super.key,
      required this.productsData,
      required this.onCart,
      this.onSelected});

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  late bool selectMode = false;
  late List categories = [];
  late List<PageStorageKey> pageStorageKeys = [];
  late List<GlobalKey> keys = [];
  late List<ExpansionTileController> expansionTilecontrollers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.productsData.length; i++) {
      if (!categories.contains(widget.productsData[i]['category'])) {
        categories.add(widget.productsData[i]['category']);
        pageStorageKeys.add(PageStorageKey(
            '${widget.key.hashCode}-${widget.productsData[i]['category']}'));
        keys.add(GlobalKey());
        expansionTilecontrollers.add(ExpansionTileController());
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void scrollToCategory(String category) {
    for (int i = 0; i < categories.length; i++) {
      if (categories[i] == category) {
        expansionTilecontrollers[i].expand();
        Scrollable.ensureVisible(
          keys[i].currentContext!,
          duration: const Duration(milliseconds: 500),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var category in categories)
          Container(
            key: keys[categories.indexOf(category)],
            child: ExpansionTile(
              key: pageStorageKeys[categories.indexOf(category)],
              controller:
                  expansionTilecontrollers[categories.indexOf(category)],
              title: Text(category == '' ? 'Others' : category),
              initiallyExpanded: true,
              maintainState: true,
              children: [
                for (var productData in widget.productsData
                    .where((e) => e['category'] == category))
                  GestureDetector(
                    onLongPress: widget.onSelected != null
                        ? () {
                            selectMode = true;
                            homeKey.currentState!.selectedProducts
                                .add(productData['id']);
                            widget.onSelected!(
                                homeKey.currentState!.selectedProducts);
                          }
                        : null,
                    onTap: () {
                      if (selectMode) {
                        if (homeKey.currentState!.selectedProducts
                            .contains(productData['id'])) {
                          homeKey.currentState!.selectedProducts
                              .remove(productData['id']);
                          if (homeKey.currentState!.selectedProducts.isEmpty) {
                            selectMode = false;
                          }
                        } else {
                          homeKey.currentState!.selectedProducts
                              .add(productData['id']);
                        }
                        widget.onSelected!(
                            homeKey.currentState!.selectedProducts);
                      }
                    },
                    child: Stack(
                      children: [
                        Product(
                          productData: productData,
                          onCart: () async {
                            await homeKey.currentState!.updateCartData();
                            widget.onCart();
                          },
                          inCart: (homeKey.currentState!.cartData['entries'] ??
                                  [])
                              .any((e) => e['product'] == productData['id']),
                        ),
                        if (selectMode)
                          Positioned.fill(
                            child: SizedBox.expand(
                              child: Container(
                                color: homeKey.currentState!.selectedProducts
                                        .contains(productData['id'])
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(64)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class Product extends StatefulWidget {
  final Map productData;
  final bool inCart;
  final void Function() onCart;

  const Product(
      {super.key,
      required this.productData,
      required this.onCart,
      required this.inCart});

  @override
  ProductState createState() => ProductState();
}

class ProductState extends State<Product> {
  late bool _addingToCart = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(64),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Stack(
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                          height: 256,
                          child: widget.productData['image'] != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.productData['image'],
                                  imageBuilder: (context, imageProvider) =>
                                      SizedBox.expand(
                                    child: Image(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      SizedBox.expand(
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
                            title: Text(widget.productData['name']),
                            subtitle: Text(
                              widget.productData['nonveg'] ? 'Non Veg' : 'Veg',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.productData['nonveg']
                                    ? Colors.red.harmonizeWith(
                                        Theme.of(context).colorScheme.primary)
                                    : Colors.green.harmonizeWith(
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            trailing: widget.productData['available'] ==
                                        false ||
                                    (widget.productData['restaurant']
                                                ['available'] ==
                                            false &&
                                        homeKey.currentState!
                                                .userData['profile']['kind'] ==
                                            'C')
                                ? Text(
                                    'Not Available',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.harmonizeWith(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                  )
                                : null,
                            titleTextStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.onPrimary),
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.primary),
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16)),
                            textStyle: const WidgetStatePropertyAll(
                                TextStyle(fontSize: 16))),
                        onPressed: (homeKey.currentState!.userData['profile'] ??
                                    {})['kind'] ==
                                'R'
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return AddEditProductPage(
                                      productData: widget.productData,
                                      onUpdate: () => Navigator.pop(context),
                                    );
                                  }),
                                );
                              }
                            : widget.inCart
                                ? () {
                                    Navigator.pop(context);
                                    homeKey.currentState!.goToCart();
                                  }
                                : _addingToCart
                                    ? null
                                    : () async {
                                        setState(() {
                                          _addingToCart = true;
                                        });
                                        await addToCart(widget.productData);
                                        widget.onCart();
                                      },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon((homeKey.currentState!
                                              .userData['profile'] ??
                                          {})['kind'] ==
                                      'R'
                                  ? Icons.edit
                                  : widget.inCart
                                      ? Icons.shopping_cart_checkout_rounded
                                      : _addingToCart
                                          ? Icons.pending
                                          : Icons.add_shopping_cart_rounded),
                            ),
                            Text((homeKey.currentState!.userData['profile'] ??
                                        {})['kind'] ==
                                    'R'
                                ? 'Edit'
                                : widget.inCart
                                    ? 'View in cart'
                                    : _addingToCart
                                        ? 'Adding to cart'
                                        : 'Add to cart')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.productData['description'].isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, top: 16),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.productData['description'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      for (int i = 0;
                          i < widget.productData['variants'].length;
                          i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.productData['variants'][i]['name'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                '₹${widget.productData['variants'][i]['price']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if ((homeKey.currentState!.userData['profile'] ?? {})['kind'] ==
                    'C' &&
                (widget.productData['available'] == false ||
                    widget.productData['restaurant']['available'] == false))
              Positioned.fill(
                child: SizedBox.expand(
                  child: Container(color: Colors.grey.withAlpha(128)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RestaurantList(
      query:
          'latitude=${homeKey.currentState!.location.latitude}&longitude=${homeKey.currentState!.location.longitude}',
      onRestaurantTap: (Map restaurantData) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantPage(restaurantData: restaurantData),
          ),
        );
      },
    );
  }
}

enum VegOrNonVeg { veg, nonVeg }

class AddEditProductPage extends StatefulWidget {
  final Map productData;
  final void Function() onUpdate;

  const AddEditProductPage(
      {super.key, required this.productData, required this.onUpdate});

  @override
  AddEditProductPageState createState() => AddEditProductPageState();
}

class AddEditProductPageState extends State<AddEditProductPage> {
  final TextEditingController _productnameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  late SystemUiOverlayStyle _currentStyle;
  late VegOrNonVeg? _vegOrNonVeg;
  late List _variants;
  late String _imageUrl;
  late FileImage? _image = null;

  @override
  void initState() {
    super.initState();
    _productnameController.text = widget.productData['name'] ?? '';
    _descriptionController.text = widget.productData['description'] ?? '';
    _categoryController.text = widget.productData['category'] ?? '';
    _vegOrNonVeg = (widget.productData['nonveg'] ?? false)
        ? VegOrNonVeg.nonVeg
        : VegOrNonVeg.veg;
    _variants = widget.productData['variants'] ?? [];
    _imageUrl = widget.productData['image'] ?? '';
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
    _changeColor();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentStyle,
      child: Scaffold(
        body: ListView(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                _image != null
                    ? SizedBox(
                        height: 256,
                        child: SizedBox.expand(
                          child: Image(
                            image: _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : _imageUrl == ''
                        ? Image.asset('assets/food.jpg')
                        : SizedBox(
                            height: 256,
                            child: CachedNetworkImage(
                              imageUrl: widget.productData['image'],
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
                              errorWidget: (context, url, error) =>
                                  SizedBox.expand(
                                child: Image.asset(
                                  'assets/food.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxHeight: 512,
                      maxWidth: 512,
                    );
                    if (image != null) {
                      setState(() {
                        _image = FileImage(File(image.path));
                        _imageUrl = '';
                      });
                    }
                  },
                  child: const Text('Change Image'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: productNameKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  validator: (value) {
                    return value != null
                        ? value.length < 4
                            ? 'Product Name must be atleast 4 characters'
                            : null
                        : null;
                  },
                  controller: _productnameController,
                  decoration: const InputDecoration(
                    label: Text('Product Name'),
                    hintText: 'Product Name',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    label: Text('Description'),
                    hintText: 'Description',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    label: Text('Category'),
                    hintText: 'Category',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              child: Row(
                children: [
                  Flexible(
                    child: ListTile(
                      title: const Text('Non Veg'),
                      leading: Radio<VegOrNonVeg>(
                        value: VegOrNonVeg.nonVeg,
                        groupValue: _vegOrNonVeg,
                        onChanged: (VegOrNonVeg? value) {
                          setState(() {
                            _vegOrNonVeg = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListTile(
                      title: const Text('Veg'),
                      leading: Radio<VegOrNonVeg>(
                        value: VegOrNonVeg.veg,
                        groupValue: _vegOrNonVeg,
                        onChanged: (VegOrNonVeg? value) {
                          setState(() {
                            _vegOrNonVeg = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            EditCreateVariants(
              variants: _variants,
              onChange: (List variants) {
                setState(() {
                  _variants = variants;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 12),
                  ),
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 24),
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () async {
                  if (productNameKey.currentState!.validate()) {
                    if (_variants.isEmpty) {
                      showSnackbar('Add atleast one variant');
                      return;
                    }
                    widget.onUpdate();
                    homeKey.currentState!.isLoadingProductsData = true;
                    homeKey.currentState!.setState(() {});
                    Map productData = {
                      'name': _productnameController.text,
                      'description': _descriptionController.text,
                      'category': _categoryController.text,
                      'image': _image,
                      'nonveg':
                          _vegOrNonVeg == VegOrNonVeg.nonVeg ? true : false,
                      'variants': _variants,
                    };
                    if (widget.productData['id'] == null) {
                      await createProduct(() => {}, productData);
                    } else {
                      await updateProduct(
                          () => {}, widget.productData['id'], productData);
                    }
                    await homeKey.currentState!.updateProductsData(
                        widget.productData['restaurant']['id']);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCreateVariants extends StatelessWidget {
  final List variants;
  final void Function(List variants) onChange;
  final TextEditingController _newNameContoller = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController();

  EditCreateVariants(
      {super.key, required this.variants, required this.onChange});

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      _newNameContoller.text = 'default';
    }
    return Column(
      children: [
        for (int i = 0; i < variants.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(variants[i]['name'])),
                const SizedBox(width: 20),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${variants[i]['price']}'),
                      IconButton(
                        onPressed: () {
                          List editedVariants = List.from(variants);
                          editedVariants.removeAt(i);
                          onChange(editedVariants);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        VariantForm(
          nameController: _newNameContoller,
          priceController: _newPriceController,
          addNewVariant: (String name, String price) {
            List editedVariants = List.from(variants);
            editedVariants.add({
              'name': name,
              'price': double.parse(price),
            });
            onChange(editedVariants);
          },
        )
      ],
    );
  }
}

class VariantForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final void Function(String name, String price) addNewVariant;

  const VariantForm(
      {super.key,
      required this.nameController,
      required this.priceController,
      required this.addNewVariant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Form(
              key: newVariantNameKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: TextFormField(
                controller: nameController,
                validator: (value) {
                  return (value ?? '').isEmpty
                      ? 'Variant Name can\'t be empty'
                      : null;
                },
                decoration: const InputDecoration(
                  label: Text('New Variant Name'),
                  hintText: 'Name of size, variant or option of the product',
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Form(
                    key: newVariantPriceKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return (value ?? '').isEmpty
                            ? 'Price can\'t be empty'
                            : null;
                      },
                      decoration: const InputDecoration(
                        prefix: Text('₹'),
                        label: Text('Price'),
                        hintText: 'Price',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  onPressed: () {
                    if (newVariantNameKey.currentState!.validate() &&
                        newVariantPriceKey.currentState!.validate()) {
                      addNewVariant(nameController.text, priceController.text);
                    }
                  },
                  child: const Row(
                    children: [
                      Text('Add'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
