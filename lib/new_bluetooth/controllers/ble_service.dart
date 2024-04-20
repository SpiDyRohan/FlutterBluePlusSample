import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../AppUtils.dart';


class BleGetService {
  // final List<UnlockDataModel> itemList = [];
  // FOR TIMER
  Timer? timer;
  int remainingSeconds = 1;
  final time = "0:00".obs;

  Future<List<BluetoothCharacteristic>> getService(
      BluetoothDevice device) async {
    final streamController = StreamController<List<BluetoothService>>();

    // streamController.addStream(device.servicesList);
    List<BluetoothService> service=await device.discoverServices();
    streamController.add(service);
    final completer = Completer<List<BluetoothCharacteristic>>();
    streamController.stream.listen((event) {
      List<BluetoothCharacteristic> servicesList = [];
      print("Services ${event}");
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        sendCommands(device);
      });
      // Future.delayed(const Duration(milliseconds: 400),
      //         () => listenToDeviceNotifications(device));

      // for (var blueToothService in event) {
      //   if (blueToothService.uuid.toString().toUpperCase().substring(4, 8) == AppUtils.serverUUID)
      //   {
      //     for (var characteristics in blueToothService.characteristics)
      //     {
      //       if (characteristics.uuid.toString().toUpperCase().substring(4, 8) == AppUtils.writDataUUID)
      //       {
      //         servicesList.insert(0, characteristics);
      //       } else if (characteristics.uuid.toString().toUpperCase().substring(4, 8) ==  AppUtils.readDataUUID)
      //       {
      //         servicesList.insert(1, characteristics);
      //       }
      //     }
      //   }
      // }
      // if (servicesList.isNotEmpty) {
      //   completer.complete(servicesList);
      // } else {
      //   Future.error("Unable to get services");
      // }
    }).onError((error){
      print("error ${error}");

    });

    final result = await completer.future;
    // await subscription.cancel();
    await streamController.close();

    return result;
  }
  Future<void> sendCommands(BluetoothDevice device) async {
    List<BluetoothService>? services;
    BluetoothService? myImportantService;
    List<BluetoothCharacteristic>? characteristics;

    services = await device.discoverServices();

    for (BluetoothService s in services!) {
      if (s.uuid.toString() == '6e400001-b5a3-f393-e0a9-e50e24dcca9e')
        myImportantService = s;
    }
    characteristics = myImportantService?.characteristics;
    for (BluetoothCharacteristic c in characteristics!) {
      if (c.uuid.toString() == '6e400002-b5a3-f393-e0a9-e50e24dcca9e') {
        writeCharacteristics(c, "getfwver", 5,device);
        writeCharacteristics(c, "gethdver", 10,device);
        writeCharacteristics(c, "getbatter", 15,device);
        writeCharacteristics(c, "getpower", 20,device);
        writeCharacteristics(c, "getdate", 25,device);
        writeCharacteristics(c, "gettime", 30,device);
        writeCharacteristics(c, "calibration1", 35,device);
        writeCharacteristics(c, "getcapacity", 40,device);
      }
    }
  }
  void writeCharacteristics(BluetoothCharacteristic c,String code,int milliseconds,BluetoothDevice device) async {
    Future.delayed(Duration(milliseconds: milliseconds),() async{
      await c.write(utf8.encode(code));
    },);

    listenToDeviceNotifications(device);
  }
  void listenToDeviceNotifications(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (service.uuid.toString() == "6e400001-b5a3-f393-e0a9-e50e24dcca9e" &&  characteristic.uuid.toString() == "6e400003-b5a3-f393-e0a9-e50e24dcca9e") {
            await characteristic.setNotifyValue(true);
            characteristic.onValueReceived.listen((value) {
              String response = utf8.decode(value);
              print("response  from 8Bottle ${response}");
              if (response.contains("batter")) {
                print("RESPONSE ${response}");
                // batteryPrcnt = response;
                // getValueFromText(batteryPrcnt);
                // print('BatteryPercent : $batteryPrcnt');
              }
              else if (response.contains("date")) {
                print("RESPONSE 12 ${response}");

              }
              else if (response.contains("FWVER")) {
                print("RESPONSE 123 ${response}");

              }
              else if (response.contains("HDVER")) {
                print("RESPONSE 124 ${response}");

              }
              else if (response.contains("power")) {
                print("RESPONSE 125 ${response}");

              }
              else if (response.contains("time")) {
                print("RESPONSE 126 ${response}");

              }
              else if (response.contains("calibration1")) {
                print("RESPONSE 127 ${response}");

              }
              else if (response.contains('totalwater')) {
                print('Total water consumed $response');
                // extractIntegerValueForWaterConsumed(response);
                // calculatePercentage();
                print('DRINKING : $response');
              }
              else if (response.contains("water=")) {
                // getcapacity.value = response;
                // extractIntegerValue(getcapacity.value);
                print('getcapacity : $response');
              }
              else if (response.contains("water")) {
                // addWaterDataToList(response);
                print('GetWater: $response');
              }
              else if (response.contains("calibration2")) {
                // calibration2.value = response;
                print('calibration1 : $response');
              }
              else if (response.contains("formatting")) {
                print('formatting : $response');
              }
              else if (response.contains("setmaxcapacity")) {
                print('RESPONSE :: $response');
                //print('setmaxcapacity : ${setmaxcapacity.value}');
              }
              else if (response.contains("none")) {
                print('No Water drunk history Available');
                // if (response == 'none') {
                //   print("RESPONSE == NONE");
                //   int randomAmount = Random().nextInt(480) + 1;
                //   int randomHour = Random().nextInt(24);
                //   int randomMinute = Random().nextInt(60);
                //   String formattedTime =
                //       '${randomHour.toString().padLeft(2, '0')},${randomMinute.toString().padLeft(2, '0')}';
                //   waterList.add(WaterData(formattedTime, randomAmount));
                //   waterList.forEach((element) {
                //     totalWaterConsumed.value =
                //         element.amount + totalWaterConsumed.value;
                //   });
                //   calculatePercentage();
                // } else {
                //   print("RESPONSE id not NONE");
                //   List<String> responseParts = response.split(',');
                //   if (responseParts.length == 4) {
                //     String time = responseParts.sublist(0, 3).join(':');
                //     int amount = int.tryParse(responseParts[3]) ?? 0;
                //     waterList.add(WaterData(time, amount));
                //   }
                // }
                // waterList.forEach((data) {
                //   print('Time: ${data.time}, Amount: ${data.amount}');
                // });
              }
              else if (response.contains("settime")) {
                print("Device response :: $response");
              }
              else if (response.contains("day1water") ||
                  response.contains("day2water") ||
                  response.contains("day3water") ||
                  response.contains("day7water")) {
                print('WEEKWATER : ${response}');
              }
              else {
                print('ELSE:::${response}');
              }
            });
          } else {

          }
        }
      }
    } catch (error) {
      print('Error discovering services: $error');
    }
  }


  Future<int> issueQueryStatusCommand(
      List<int> token,
      BluetoothCharacteristic? writeCharacteristic,
      BluetoothCharacteristic? readCharacteristic) async {
    await writeCharacteristic?.write(
        AppUtils().generateQueryStatusCommand(token),
        withoutResponse: true);

    //readCharacteristic?.setNotifyValue(true);
    //readCharacteristic?.read();
    final streamController = StreamController<List<int>>();

    streamController.addStream(readCharacteristic!.value);
    final completer = Completer<int>();
    final subscription = streamController.stream.listen((event) {
      if (event != null && event.isNotEmpty) {
        var decryptedResponse = AppUtils().decrypt(event);
        Logger().i("DECRYPTED RESPONSE : $decryptedResponse");
        if (decryptedResponse != null &&
            decryptedResponse.isNotEmpty &&
            decryptedResponse[0] == 5 &&
            decryptedResponse[1] == 15 &&
            decryptedResponse[2] == 1 &&
            decryptedResponse[3] == 0) {
          //Device is Unlocked
          completer.complete(1);
          // update();
        } else if (decryptedResponse != null &&
            decryptedResponse.isNotEmpty &&
            decryptedResponse[0] == 5 &&
            decryptedResponse[1] == 15 &&
            decryptedResponse[2] == 1 &&
            decryptedResponse[3] == 1) {
          //Device is lock
          completer.complete(0);
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();

    return result;
  }
  Future<List<int>> getToken(BluetoothCharacteristic? writeCharacteristic,
      BluetoothCharacteristic? readCharacteristic) async {
    print("BLE SERVICE GET TOKEN CALLED!");
    await writeCharacteristic?.write(_generateTokenCommand(),
        withoutResponse: true);
    // readCharacteristic?.setNotifyValue(true);
    // readCharacteristic?.read();
    final streamController = StreamController<List<int>>();

    streamController.addStream(readCharacteristic!.value);
    final completer = Completer<List<int>>();
    final subscription = streamController.stream.listen((event) {
      if (event != null && event.isNotEmpty) {
        var decryptedResponse = AppUtils().decrypt(event);
        Logger().i("DECRYPTED RESPONSE1 : $decryptedResponse");
        if (decryptedResponse != null &&
            decryptedResponse.isNotEmpty &&
            decryptedResponse[0] == 6 &&
            decryptedResponse[1] == 2 &&
            decryptedResponse[2] == 8) {
          List<int> mToken = [
            decryptedResponse[3],
            decryptedResponse[4],
            decryptedResponse[5],
            decryptedResponse[6]
          ];
          completer.complete(mToken);
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();

    return result;
  }

  Future<void> issueUnlockCommand(
      String macAddress,
      String propertyId,
      List<int> token,
      BluetoothCharacteristic? writeCharacteristic,
      BluetoothCharacteristic? readCharacteristic) async {
    await writeCharacteristic?.write(AppUtils().generateUnlockCommand(token),
        withoutResponse: true);

    //readCharacteristic?.setNotifyValue(true);
    //readCharacteristic?.read();
    final streamController = StreamController<List<int>>();

    streamController.addStream(readCharacteristic!.value);
    final completer = Completer<void>();
    final subscription = streamController.stream.listen((event) {
      if (event != null && event.isNotEmpty) {
        var decryptedResponse = AppUtils().decrypt(event);
        Logger().i("DECRYPTED RESPONSE2 : $decryptedResponse");
        // String jsonString =
        //     json.encode(itemList);

        if (decryptedResponse != null &&
            decryptedResponse.isNotEmpty &&
            decryptedResponse[0] == 5 &&
            decryptedResponse[1] == 2 &&
            decryptedResponse[2] == 1 &&
            decryptedResponse[3] == 0) {
          completer.complete();
          // Get.back();
      //    Get.toNamed(Routes.availableRentalScreen);
          // update();
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();

    return result;
  }


  // FUNCTION FOR TIMER
  startTimer(int seconds) {
    debugPrint("in start timer");
    const duration = Duration(seconds: 1);
    remainingSeconds = seconds;
    timer = Timer.periodic(duration, (timer) {
      if (remainingSeconds == 0) {
        time.value = "0:00";
        timer.cancel();
      } else {
        int hours = remainingSeconds ~/ 3600;
        int minutes = remainingSeconds ~/ 60;
        int seconds = remainingSeconds % 60;
        time.value =
        "${hours.toString().padLeft(1, "0")}:${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}";
        debugPrint("time: ${time.value}");
        debugPrint("remainingSeconds: $remainingSeconds");
        remainingSeconds++;
      }
    });
  }
  Uint8List _generateTokenCommand() {
    var command = [
      6,
      1,
      1,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ];

    var encryptCommand = AppUtils().encrypt(command);
    return encryptCommand;
  }

  /// FUNCTION TO CHECK THE LOCK STATUS OF DEVICE

  Future<void> issueLockCommand(
      List<int> token,
      BluetoothCharacteristic? writeCharacteristic,
      BluetoothCharacteristic? readCharacteristic) async {
    await writeCharacteristic?.write(AppUtils().generateUnlockCommand(token),
        withoutResponse: true);
    final streamController = StreamController<List<int>>();
    streamController.addStream(readCharacteristic!.value);
    final completer = Completer<void>();
    final subscription = streamController.stream.listen((event) {
      if (event != null && event.isNotEmpty) {
        var decryptedResponse = AppUtils().decrypt(event);
        Logger().i("DECRYPTED RESPONSE3 : $decryptedResponse");

        if (decryptedResponse != null &&
            decryptedResponse.isNotEmpty &&
            decryptedResponse[0] == 5 &&
            decryptedResponse[1] == 8 &&
            decryptedResponse[2] == 1 &&
            decryptedResponse[3] == 0) {
          completer.complete();
          // Get.back();
          // Get.toNamed(Routes.availableRentalScreen);
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();

    return result;
  }
}
