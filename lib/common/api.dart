import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> savejwt(accessToken, refreshToken) async {
  await storage.write(key: 'jwtAccess', value: accessToken);
  await storage.write(key: 'jwtRefresh', value: refreshToken);
}

Future<void> deletejwt() async {
  await storage.delete(key: 'jwtAccess');
  await storage.delete(key: 'jwtRefresh');
}

Future<String> readjwtAccess() async {
  if (await storage.containsKey(key: 'jwtAccess')) {
    return (await storage.read(key: 'jwtAccess')) ?? '';
  } else {
    return '';
  }
}

Future<String> readjwtRefresh() async {
  if (await storage.containsKey(key: 'jwtRefresh')) {
    return (await storage.read(key: 'jwtRefresh')) ?? '';
  } else {
    return '';
  }
}

Future<void> store(String key, dynamic value) async {
  await storage.write(key: key, value: value);
}

Future<String?> readStorage(String key) async {
  if (await storage.containsKey(key: key)) {
    return await storage.read(key: key);
  } else {
    return null;
  }
}

const String baseUrl = 'https://api.foodex.barakbits.com/';

const String getOTPUrl = 'api/user/otp/';
const String getEmailOTPUrl = 'api/user/emailotp/';
const String tokenUrl = 'api/token/';
const String tokenRefreshUrl = 'api/token/refresh/';

const String usersUrl = 'api/user/';
const String selfUserUrl = 'api/user/self/';
const String profilesUrl = 'api/user/profile/';

const String restaurantsUrl = 'api/restaurant/';
const String deliveryChargeUrl = 'api/restaurant/deliverycharge/';
const String productsUrl = 'api/restaurant/product/';
const String productsDeleteUrl = 'api/restaurant/product/bulkdelete/';
const String productsBulkAvailableUrl = 'api/restaurant/product/bulkavailable/';
const String productsBulkUnavailableUrl =
    'api/restaurant/product/bulkunavailable/';

const String ordersUrl = 'api/order/';
const String pendingOrdersUrl = 'api/order/pending/';
const String pastOrdersUrl = 'api/order/past/';

const String orderCancelUrl = 'api/order/cancel/';
const String orderAcceptUrl = 'api/order/accept/';
const String orderCookingFinishedUrl = 'api/order/cookingfinished/';
const String orderPickedUpUrl = 'api/order/pickedup/';
const String orderArrivedUrl = 'api/order/arrived/';
const String orderDeliveredUrl = 'api/order/delivered/';

const String orderPaidToRestaurantUrl = 'api/order/paidtorestaurant/';
const String orderPaidToRestaurantConfirmUrl =
    'api/order/paidtorestaurantconfirm/';
