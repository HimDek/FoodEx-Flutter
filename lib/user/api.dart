import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../common/api.dart';
import '../common/components.dart';

Future<int> getPhoneOtp(String number) async {
  try {
    Response response = await post(Uri.parse(baseUrl + getPhoneOTPUrl),
        body: {'number': number});
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

Future<int> getEmailOtp(String email) async {
  try {
    Response response =
        await post(Uri.parse(baseUrl + getEmailOTPUrl), body: {'email': email});
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

Future<int> register(String email, int emailOtp, String phone, int phoneOtp,
    String firstName, String lastName) async {
  try {
    Response response = await post(Uri.parse(baseUrl + usersUrl), body: {
      'email': email,
      'emailotp': '$emailOtp',
      'phone': phone,
      'phoneotp': '$phoneOtp',
      'first_name': firstName,
      'last_name': lastName,
    });

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      await login(email, emailOtp);
      return 0;
    } else {
      throw (jsonDecode(response.body.toString())['detail'] ??
          response.reasonPhrase ??
          response.statusCode);
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

Future<int> login(String email, int otp) async {
  String fullTokenUrl = baseUrl + tokenUrl;

  try {
    Response response = await post(Uri.parse(fullTokenUrl),
        body: {'email': email, 'password': '$otp'});

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      var data = jsonDecode(response.body.toString());
      await savejwt(data['access'], data['refresh']);
      return 0;
    } else {
      throw (jsonDecode(response.body.toString())['detail'] ??
          response.reasonPhrase ??
          response.statusCode);
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

Future<void> logout() async {
  await deletejwt();
}

Future<int> refreshToken(Function() doLogin) async {
  try {
    var token = await readjwtRefresh();
    Response response = await post(Uri.parse(baseUrl + tokenRefreshUrl),
        body: {'refresh': token});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      await savejwt(data['access'], data['refresh']);
      return 0;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    doLogin();
    return 1;
  }
}

Future<Map> getSelfUser(Function() doLogin) async {
  try {
    await refreshToken(doLogin);
    final response = await get(Uri.parse(baseUrl + selfUserUrl),
        headers: {'Authorization': 'Bearer ${await readjwtAccess()}'});
    var data = jsonDecode(response.body.toString());
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return data;
    } else {
      throw (data['detail']);
    }
  } catch (e) {
    return {};
  }
}

Future<int> updateProfile(Function() doLogin, profileData) async {
  try {
    await refreshToken(doLogin);
    MultipartRequest request =
        MultipartRequest('PATCH', Uri.parse('$baseUrl$profilesUrl'));
    request.headers['Authorization'] = 'Bearer ${await readjwtAccess()}';
    if (profileData['restaurantname'] != null) {
      request.fields['restaurantname'] = profileData['restaurantname'];
    }
    if (profileData['phone'] != null && profileData['phoneotp'] != null) {
      request.fields['phone'] = profileData['phone'];
      request.fields['phoneotp'] = profileData['phoneotp'];
    }
    if (profileData['email'] != null && profileData['emailotp'] != null) {
      request.fields['email'] = profileData['email'];
      request.fields['emailotp'] = profileData['emailotp'];
    }
    if (profileData['fcmtoken'] != null) {
      request.fields['fcmtoken'] = profileData['fcmtoken'];
    }
    if (profileData['first_name'] != null) {
      request.fields['first_name'] = profileData['first_name'];
    }
    if (profileData['last_name'] != null) {
      request.fields['last_name'] = profileData['last_name'];
    }
    if (profileData['available'] != null) {
      request.fields['available'] = profileData['available'].toString();
    }
    if (profileData['upiID'] != null) {
      request.fields['upiID'] = profileData['upiID'];
    }
    if (profileData['image'] != null) {
      request.files.add(
        MultipartFile.fromBytes(
          'image',
          profileData['image'].file.readAsBytesSync(),
          filename: profileData['image'].file.path.split('/').last,
        ),
      );
    }
    StreamedResponse response = await request.send();
    var data = jsonDecode(await response.stream.bytesToString());

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

Future<int> toggleAvailability(Function() doLogin) async {
  return await updateProfile(() => null, {
    'available':
        homeKey.currentState!.userData['profile']['available'] ? false : true
  });
}
