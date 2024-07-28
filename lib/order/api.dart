import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../common/api.dart';
import '../common/components.dart';
import '../user/api.dart';

Future<int> addToCart(productData) async {
  Map cart = json.decode((await readStorage('cart')) ?? '{}');
  if (cart.isEmpty ||
      (cart['entries'] ?? []).length == 0 ||
      (cart['restaurant'] ?? 0) == productData['restaurant']['id']) {
    bool done = false;
    cart['entries'] = cart['entries'] ?? [];
    for (int i = 0; i < cart['entries'].length; i++) {
      if (cart['entries'][i]['product'] == productData['id']) {
        String variantId = '${productData['variants'][0]['id']}';
        cart['entries'][i]['quantities'][variantId] =
            cart['entries'][i]['quantities'][variantId] + 1;
        cart['restaurant'] = productData['restaurant']['id'];
        done = true;
        break;
      }
    }
    if (!done) {
      cart['entries'].add({
        'product': productData['id'],
        'quantities': {
          '${productData['variants'][0]['id']}': 1,
          for (int i = 1; i < productData['variants'].length; i++)
            '${productData['variants'][i]['id']}': 0
        },
        'instruction': ''
      });
      cart['restaurant'] = productData['restaurant']['id'];
    }
    await store('cart', json.encode(cart));
    return 0;
  } else if ((cart['restaurant'] ?? 0) != productData['restaurant']['id']) {
    showSnackbar('Add');
  }
  return 1;
}

Future<void> changeQuantity(
    int index, String variantId, List variants, int quantity) async {
  Map cart = json.decode((await readStorage('cart')) ?? '{}');
  cart['entries'][index]['quantities'][variantId] = quantity;
  int totalQuantity = 0;
  for (Map variant in variants) {
    totalQuantity +=
        cart['entries'][index]['quantities']['${variant['id']}'] as int;
  }
  if (totalQuantity == 0) {
    cart['entries'].removeAt(index);
    await store('cart', json.encode(cart));
  }
  await store('cart', json.encode(cart));
}

Future<void> removeFromCart(int index) async {
  Map cart = json.decode((await readStorage('cart')) ?? '{}');
  cart['entries'].removeAt(index);
  await store('cart', json.encode(cart));
}

Future<void> addVariant(int index, String variantId) async {
  Map cart = json.decode((await readStorage('cart')) ?? '{}');
  cart['entries'][index]['quantities'][variantId] = 1;
  await store('cart', json.encode(cart));
}

// REST API:

Future<double> getDeliveryCharge(
    int restaurantId, String latitude, String longitude) async {
  try {
    Response response = await post(
      Uri.parse('$baseUrl$deliveryChargeUrl'),
      body: {
        'restaurant': '$restaurantId',
        'latitude':
            '${homeKey.currentState!.location.latitude}'.substring(0, 9),
        'longitude':
            '${homeKey.currentState!.location.longitude}'.substring(0, 9),
      },
    );
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      var data = jsonDecode(response.body.toString());
      return double.parse('${data['value']}');
    } else {
      throw "Could not fetch delivery Charge";
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return 0;
  }
}

Future<Map> placeOrder(Function() doLogin) async {
  try {
    await refreshToken(doLogin);
    Map cart = json.decode((await readStorage('cart')) ?? '{}');

    List content = [];
    for (int i = 0; i < cart['entries'].length; i++) {
      content.add({
        'product': cart['entries'][i]['product'],
        'quantities': cart['entries'][i]['quantities'],
        'instruction': cart['entries'][i]['instruction'],
      });
    }

    Response response = await post(Uri.parse(baseUrl + ordersUrl), headers: {
      'Authorization': 'Bearer ${await readjwtAccess()}'
    }, body: {
      'content': jsonEncode(content),
      'latitude': '${homeKey.currentState!.location.latitude}'.substring(0, 9),
      'longitude':
          '${homeKey.currentState!.location.longitude}'.substring(0, 9),
    });
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<List> getPendingOrders(Function() doLogin) async {
  try {
    await refreshToken(doLogin);

    Response response = await get(Uri.parse(baseUrl + pendingOrdersUrl),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'});
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      var data = jsonDecode(response.body.toString());
      return data;
    } else {
      throw "Could not fetch orders";
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return [];
  }
}

Future<List> getPastOrders(Function() doLogin) async {
  try {
    await refreshToken(doLogin);

    Response response = await get(Uri.parse(baseUrl + pastOrdersUrl),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'});
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      var data = jsonDecode(response.body.toString());
      return data;
    } else {
      throw "Could not fetch orders";
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return [];
  }
}

Future<Map> getOrder(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);

    Response response = await get(Uri.parse('$baseUrl$ordersUrl$id/'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> cancelOrder(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(Uri.parse('$baseUrl$orderCancelUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> acceptOrder(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(Uri.parse('$baseUrl$orderAcceptUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> orderCookingFinished(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(
        Uri.parse('$baseUrl$orderCookingFinishedUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> orderPickedUp(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(Uri.parse('$baseUrl$orderPickedUpUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> orderArrived(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(Uri.parse('$baseUrl$orderArrivedUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> orderDelivered(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(Uri.parse('$baseUrl$orderDeliveredUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> orderPaidToRestaurant(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(
        Uri.parse('$baseUrl$orderPaidToRestaurantUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}

Future<Map> orderPaidToRestaurantConfirm(Function() doLogin, int id) async {
  try {
    await refreshToken(doLogin);
    Response response = await post(
        Uri.parse('$baseUrl$orderPaidToRestaurantConfirmUrl'),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'},
        body: {'id': '$id'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
    final snackBar = SnackBar(
      showCloseIcon: true,
      content: Text('Request Failed! $e.'),
    );
    scaffold.showSnackBar(snackBar);
    return {};
  }
}
