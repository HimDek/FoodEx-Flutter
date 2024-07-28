import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
final homeKey = GlobalKey<HomeState>();

const bingMapsApiKey =
    'Avp1HW_M-FcjR-yGlkZxwSGjBoMpHZejnAB1XjcCqh23apgSMBoaaNJ3_CZDdqYy';

String readableBytes(bytes, decimal) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimal)} ${suffixes[i]}';
}

void showSnackbar(String message) {
  final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
  final snackBar = SnackBar(
    showCloseIcon: true,
    content: Text(message),
  );
  scaffold.showSnackBar(snackBar);
}

Future<void> copyToClipBoard(context, String text,
    {message = 'Copied to Clipboard'}) async {
  await Clipboard.setData(ClipboardData(text: text));
  final snackBar = SnackBar(
    showCloseIcon: true,
    margin: const EdgeInsets.all(8),
    content: Text(message),
    // action: SnackBarAction(
    //   label: 'Undo',
    //   onPressed: () {
    //     // Some code to undo the change.
    //   },
    // ),
  );
  scaffoldKey.currentState!.showSnackBar(snackBar);
}

String? readableDateTime(String? dateTime) {
  if (dateTime == null) return null;
  DateTime parsedDateTime = DateTime.parse(dateTime);
  List<String> monthName = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  // List<String> weekdayName = [
  //   'Sunday',
  //   'Monday',
  //   'Tuesday',
  //   'Wednesday',
  //   'Thursday',
  //   'Friday',
  //   'Saturday'
  // ];
  String hour = (parsedDateTime.hour % 12).toString();
  String minute = parsedDateTime.minute.toString().padLeft(2, '0');
  String amPm = parsedDateTime.hour < 12 ? 'AM' : 'PM';
  String month = monthName[parsedDateTime.month];
  return '$hour:$minute $amPm, $month ${parsedDateTime.day}, ${parsedDateTime.year}';
}

Future<int> href(context,
    {String scheme = '',
    String host = '',
    String path = '',
    String url = ''}) async {
  try {
    if (url != '') {
      await copyToClipBoard(context, url, message: 'Link copied');
      await launchUrl(Uri.parse(url));
    } else {
      if (scheme == 'mailto') {
        await copyToClipBoard(context, path, message: 'Email ID copied');
      } else if (scheme == 'tel') {
        await copyToClipBoard(context, path, message: 'Phone number copied');
      } else if (scheme == 'http' || scheme == 'https') {
        await copyToClipBoard(context, url, message: 'Link copied');
      }
      await launchUrl(Uri(scheme: scheme, host: host, path: path),
          mode: LaunchMode.externalApplication);
    }
    return 0;
  } catch (e) {
    return 1;
  }
}
