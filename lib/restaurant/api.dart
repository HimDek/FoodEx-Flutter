import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../common/components.dart';
import '../common/api.dart';
import '../user/api.dart';

Future<Map> getTravelDistanceDuration(latitude, longitude) async {
  try {
    final response = await get(Uri.parse(
        'https://dev.virtualearth.net/REST/v1/Routes?wayPoint.1=${homeKey.currentState!.location.latitude},${homeKey.currentState!.location.longitude}&wayPoint.2=$latitude,$longitude&optimize=timeWithTraffic&travelMode=Driving&key=$bingMapsApiKey'));
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return {
        'distance': data['resourceSets'][0]['resources'][0]['travelDistance'],
        'duration': data['resourceSets'][0]['resources'][0]['travelDuration']
      };
    } else {
      throw (data['errorDetails'][0]);
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

// REST API:

Future<List> getRestaurants({String query = ''}) async {
  try {
    final response = await get(Uri.parse('$baseUrl$restaurantsUrl?$query'));
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
    return [];
  }
}

Future<List> getProducts({String query = ''}) async {
  try {
    final response = await get(Uri.parse('$baseUrl$productsUrl?$query'));
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
    return [];
  }
}

Future<Map> createProduct(Function() doLogin, Map productData) async {
  try {
    await refreshToken(doLogin);

    MultipartRequest request =
        MultipartRequest('POST', Uri.parse('$baseUrl$productsUrl'));
    request.fields['name'] = productData['name'];
    request.fields['description'] = productData['description'];
    request.fields['category'] = productData['category'];
    request.fields['nonveg'] = '${productData['nonveg']}';
    request.fields['variants'] = jsonEncode(productData['variants']);
    request.headers['Authorization'] = 'Bearer ${await readjwtAccess()}';
    if (productData['image'] != null) {
      request.files.add(
        MultipartFile.fromBytes(
          'image',
          productData['image'].file.readAsBytesSync(),
          filename: productData['image'].file.path.split('/').last,
        ),
      );
    }
    StreamedResponse response = await request.send();
    var data = jsonDecode(await response.stream.bytesToString());
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

Future<Map> updateProduct(Function() doLogin, int id, Map productData) async {
  try {
    await refreshToken(doLogin);

    MultipartRequest request =
        MultipartRequest('PATCH', Uri.parse('$baseUrl$productsUrl$id/'));
    request.fields['name'] = productData['name'];
    request.fields['description'] = productData['description'];
    request.fields['category'] = productData['category'];
    request.fields['nonveg'] = '${productData['nonveg']}';
    request.fields['variants'] = jsonEncode(productData['variants']);
    request.headers['Authorization'] = 'Bearer ${await readjwtAccess()}';
    if (productData['image'] != null) {
      request.files.add(
        MultipartFile.fromBytes(
          'image',
          productData['image'].file.readAsBytesSync(),
          filename: productData['image'].file.path.split('/').last,
        ),
      );
    }
    StreamedResponse response = await request.send();
    var data = jsonDecode(await response.stream.bytesToString());
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

Future<int> deleteProducts(Function() doLogin, List products) async {
  try {
    await refreshToken(doLogin);

    final response = await post(Uri.parse('$baseUrl$productsDeleteUrl'), body: {
      'products': jsonEncode(products),
    }, headers: {
      'Authorization': 'Bearer ${await readjwtAccess()}',
    });
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return 0;
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
    return 1;
  }
}

Future<int> markAsAvailable(Function() doLogin, List products) async {
  try {
    await refreshToken(doLogin);

    final response =
        await post(Uri.parse('$baseUrl$productsBulkAvailableUrl'), body: {
      'products': jsonEncode(products),
    }, headers: {
      'Authorization': 'Bearer ${await readjwtAccess()}',
    });
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return 0;
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
    return 1;
  }
}

Future<int> markAsUnavailable(Function() doLogin, List products) async {
  try {
    await refreshToken(doLogin);

    final response =
        await post(Uri.parse('$baseUrl$productsBulkUnavailableUrl'), body: {
      'products': jsonEncode(products),
    }, headers: {
      'Authorization': 'Bearer ${await readjwtAccess()}',
    });
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return 0;
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
    return 1;
  }
}
