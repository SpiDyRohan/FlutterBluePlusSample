import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:encrypt/encrypt.dart' as e;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // FOR CURRENT LATITUDE AND LONGITUDE
  static var currentLatitude = 0.0.obs;
  static var currentLongitude = 0.0.obs;
  BluetoothCharacteristic? readCharacteristicsUnlock;
  BluetoothCharacteristic? writeCharacteristicsUnlock;
  List<int>? tokenTest;
  static int commandTokenId = 1;
  static int commandUnlock = 2;
  static int commandPower = 3;
  static int commandPswFirst = 4;
  static int commandPswSecond = 5;
  static int queryLock = 6;

  static String deviceId = "2B:80:03:85:3F:3A";
  static String serverUUID = "FEE7";
  static String writDataUUID = "36F5";
  static String readDataUUID = "36F6";

  /// COMMAND TO DETECT THE BATTERY LEVEL
  //var powerDetectionCommand = [2, 1, 1, 1, token[0], token[1], token[2], token[3], 0, 0, 0, 0, 0, 0, 0, 0];

  /// COMMAND TO GET TOKEN
  //var getTokenCommand = [6, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  /// FIRST COMMAND TO CHANGE THE PASSWORD
  //var changePassFirst = [5, 3, 6, oldPsw[0], oldPsw[1], oldPsw[2], oldPsw[3], oldPsw[4], oldPsw[5], token[0], token[1], token[2], token[3], 0, 0, 0];

  /// SECOND COMMAND TO CHANGE THE PASSWORD
  //var changePassSecond = [5, 4, 6, newPsw[0], newPsw[1], newPsw[2], newPsw[3], newPsw[4], newPsw[5], token[0], token[1], token[2], token[3], 0, 0, 0];

  /// COMMAND TO UNLOCK THE DEVICE
  //var unlockDeviceCommand = [5, 1, 6, 48, 48, 48, 48, 48, 48, token[0], token[1], token[2], token[3], 0, 0, 0];

  /// QUERY LOCK STATE
  //var queryLock = [5, E, 1, 1, token[0], token[1], token[2], token[3], 0, 0, 0, 0, 0, 0, 0, 0];

  /// MOTOR RESET INSTRUCTION
  //var motorReset = [5, C, 1, 1, token[0], token[1], token[2], token[3], 0, 0, 0, 0, 0, 0, 0, 0];

  /// INITIAL KEY
  //var initialKey = [32, 87, 47, 82, 54, 75, 63, 71, 48, 80, 65, 88, 17, 99, 45, 43];
  // GET THE TIME
  getTime(timeString) {
    final DateTime now = DateTime.now();
    final String formattedDateTime = formatDateTime(now);
    return formattedDateTime;
  }

  // FORMATTING THE TIME
  String formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
  }

  String formattedTime({required int timeInSecond}) {
    int hours = timeInSecond ~/ 3600;
    int sec = timeInSecond % 60;
    int min = ((timeInSecond % 3600) / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$hours:$minute:$second";
    //return "$hours:$minute";
  }

  static GetSnackBar successSnackBar(
      {String title = 'Success', String? message}) {
    Get.log("[$title] $message");
    return GetSnackBar(
      titleText: Text(title.tr,
          style: Get.textTheme.headline6!
              .merge(TextStyle(color: Get.theme.primaryColor))),
      messageText: Text(message!,
          style: Get.textTheme.caption!
              .merge(TextStyle(color: Get.theme.primaryColor))),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      backgroundColor: Colors.green,
      icon: Icon(Icons.check_circle_outline,
          size: 32, color: Get.theme.primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 5),
    );
  }

  static GetSnackBar errorSnackBar({String title = 'Error', String? message}) {
    Get.log("[$title] $message", isError: true);
    return GetSnackBar(
      titleText: Text(title.tr,
          style: Get.textTheme.headline6!
              .merge(TextStyle(color: Get.theme.primaryColor))),
      messageText: Text(message!.substring(0, min(message.length, 200)),
          style: Get.textTheme.caption!
              .merge(TextStyle(color: Get.theme.primaryColor))),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      backgroundColor: Colors.redAccent,
      icon: Icon(Icons.remove_circle_outline,
          size: 32, color: Get.theme.primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 8,
      duration: const Duration(seconds: 5),
    );
  }

  Uint8List encrypt(input) {
    // key must be 16 or 32 bytes - not sure how "mykey" could work
    // key should really be binary, not a String! Better to use a KDF.

    Uint8List inputArray = Uint8List.fromList(
      input,
    );

    Uint8List keyArray = Uint8List.fromList(
      [32, 87, 47, 82, 54, 75, 63, 71, 48, 80, 65, 88, 17, 99, 45, 43],
    );

    final key = e.Key.fromUtf8(const Utf8Decoder().convert(keyArray));
    final iv = e.IV.fromLength(16);

    final encrypter =
        e.Encrypter(e.AES(key, mode: e.AESMode.ecb, padding: null));

    final encrypted = encrypter.encryptBytes(inputArray, iv: iv);
    return encrypted.bytes;
  }

  Uint8List decrypt(input) {
    // key must be 16 or 32 bytes - not sure how "mykey" could work
    // key should really be binary, not a String! Better to use a KDF.

    Uint8List inputArray = Uint8List.fromList(
      input,
    );

    Uint8List keyArray = Uint8List.fromList(
      [32, 87, 47, 82, 54, 75, 63, 71, 48, 80, 65, 88, 17, 99, 45, 43],
    );

    final key = e.Key.fromUtf8(const Utf8Decoder().convert(keyArray));
    final iv = e.IV.fromLength(16);

    final encrypter =
        e.Encrypter(e.AES(key, mode: e.AESMode.ecb, padding: null));
    var enc = e.Encrypted(inputArray);
    final dec = encrypter.decryptBytes(enc, iv: iv);
    return Uint8List.fromList(dec);
  }
  Uint8List generateQueryStatusCommand(List<int> token) {
    var t0 = token[0];
    var t1 = token[1];
    var t2 = token[2];
    var t3 = token[3];

    var command = [5, 14, 1, 1, t0, t1, t2, t3,0, 0, 0, 0, 0, 0, 0, 0];
    var encryptCommand = encrypt(command);
    return encryptCommand;
  }
  Uint8List generateUnlockCommand(List<int> token) {
    var t0 = token[0];
    var t1 = token[1];
    var t2 = token[2];
    var t3 = token[3];

    var command = [5, 1, 6, 48, 48, 48, 48, 48, 48, t0, t1, t2, t3, 0, 0, 0];
    var encryptCommand = encrypt(command);
    return encryptCommand;
  }
}

final otpInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    counterText: '',
    //constraints: BoxConstraints(),
    focusedBorder: outlineInputBorder(),
    enabledBorder: outlineInputBorder());

OutlineInputBorder outlineInputBorder() => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
    borderSide: BorderSide(color: Colors.white10));

String functionMonthDateYear(String value) {
  DateTime date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(value);
  String formattedDate = DateFormat('MM/dd/yyyy').format(date);
  return formattedDate;
}

String functionTime(String value) {
  String time = DateFormat('h:mm a').format(DateTime.now());
  print(" time : $time");
  return time;
}
