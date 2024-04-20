import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart' as e;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:logger/logger.dart';
import '../../AppUtils.dart';
import '../../general_dialog_single_btn.dart';
import '../../secure_storage.dart';
import '../bluetooth_error.dart';
import '../models/new_ble_model.dart';
import 'ble_get_device.dart';
import 'ble_service.dart';

class NewBleController extends GetxController {
  String formattedMacAddress = '';
  var getMacAddress = '';
  var unlockRepeat=false;
  var categoryAddress="".obs;
  var categoryId="".obs;
  var isConnecting = false;
  int remainingSeconds = 1;
  Timer? timer;
  final ble=FlutterBluePlus.instance;
  final time = "0:00".obs;
  NewBleModel newBleModel = NewBleModel();
  BluetoothError? error;
  BluetoothDevice? device;
  Rx<Duration> duration=Duration().obs;
  String propertyId = "";
  String startDate = "";
  String endDate = "";
  String lockName = "";
  bool isBLEConnected = false;
  bool isAPICalled = true;
  bool isScannedDevice = false;
  RxString categoryName = "".obs;
  RxString categoryCode = "".obs;
  RxString categoryImage = "".obs;
  RxString selectedPlan = "".obs;
  RxString selectedPlanType = "".obs;
  RxString cardHolderName = "".obs;
  List<int> token = [];
  // late RentalData2 data1;
  // FOR TIMER
  Timer? timer2;
  int remainingseconds = 1;

  // FOR GETTING CURRENT TIME
  var dateTime = DateTime.now().obs;
  var timeString = ''.obs;
  var showFastenLock = false;
  var isGettingToken = false;
  Timer? scanningTimer;
  int scanningCounter = 0;

  // STREAM SUBSCRIPTION
  StreamSubscription? scanningSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    newBleModel.status = BluetoothSuccessType.BLUETOOTH_ENABLED;
     // lockName="";
    device=Get.arguments["device"];
    lockName=device!.advName;
    // if(device!.isConnected){
      checkBluetoothState();
    // }else{
    //
    // }
  }

  /// FUNCTION THE CHECK WHETHER BLUETOOTH IS ON OR OFF
  void checkBluetoothState() async {
    // printLogs("NewBleController checkBluetoothState ${lockName}");
    // await SecureStorage().writeSecureData("macAddress", lockName);

    FlutterBluePlus.adapterState.listen((event) {
      debugPrint("BluetoothState : $event");
      if (newBleModel.bluetoothState == event) {
        return;
      }
      newBleModel.bluetoothState = event;
      update();

      if (event == BluetoothAdapterState.unknown ||
          event == BluetoothAdapterState.off) {
        if (Platform.isAndroid) {
          enableBluetoothAndroid();
        }
      } else if (event == BluetoothAdapterState.on) {
        newBleModel.status = BluetoothSuccessType.BLUETOOTH_ENABLED;
        getLockDevice();
        //scanNearByDevices();
        update();
      } else if (event == BluetoothAdapterState.unavailable) {
        error = BluetoothError("Bluetooth is unavailable in this device!",
            BluetoothErrorType.TYPE_BLUETOOTH_UNAVAILABLE);
      }
    }).onError((e) {
      debugPrint("Error Bluetooth State: $e");
    });
  }
  void scanAndCheckDeviceStatus() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    BleGetDevice().checkLockStatus(getMacAddress).then((value) {
      printLogs("DheerajjScanning Success! : ${value}");
    }).onError((error, stackTrace) {
      Get.dialog(
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 400),
        WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: GeneralDialogSingleBtn(
            title:
            'This lock is not in the range. Please make sure you are near the lock!',
            onBtnClick: () {
              NewBleController().refresh();
              // Get.delete<NewBleController>();
              Get.back();
            },
            btnText: 'Ok',
          ),
        ),
      );
      print("DheerajjScanning failed!");
    });
  }
  void checkBondedDevices() {
    FlutterBluePlus.bondedDevices.then((value) {
      value.forEach((element) {
        Logger().i("BONDED DEVICE: $element");
      });
    }).onError((error, stackTrace) {
      Logger().i("BONDED ERROR : $error");
    });
  }

  void enableBluetoothAndroid() {
    FlutterBluePlus.turnOn();
  }

  Future<void> enableBluetoothIOS() async {
    // SystemSettings.bluetooth();
    // await Permission.bluetooth.request();
    Fluttertoast.showToast(msg: "Please enable bluetooth from settings!");
    // AppSettings.openBluetoothSettings();
  }


  void lockNotRangeDialog(){

    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG, msg: "This lock is not in the range. Please make sure you are near the lock!");
    NewBleController().refresh();
    // Get.delete<NewBleController>();
    Get.back();
  }

  void getLockDevice() {
    printLogs("Device Found getLockDevice");
    BleGetDevice().getConnectedDevice().then((value) {
      printLogs("Device Found Connected " + value.advName);
      this.device = value;
      print('Rohit1');
      _getServices(1);
    }).onError((error1, stackTrace) async {
      printLogs("SHUBHAM-ERROR2--" + lockName);
      printLogs("ERROR " + error1.toString());
      printLogs(stackTrace.toString());

      if (Platform.isAndroid || Platform.isIOS) {
        FlutterBluePlus.startScan(timeout: Duration(milliseconds: 5000)); // Adjust timeout as needed

        try {
          await SecureStorage().writeSecureData("macAddress", device!.advName);
          device = await BleGetDevice().getScannedDevice().then((value) {
            printLogs("ROHITTTT   value ${value.isConnected}");
            if(value.isConnected){
              device=value;
              update();

            }else{

            }
          }).onError((error, stackTrace) {
            printLogs("ROHITTTT   ERROR ${error}");
            printLogs("ROHITTTT   ERROR ${stackTrace.toString()}");
          });
        } catch (e) {
          printLogs("Error while scanning :$e");
          lockNotRangeDialog();
          return; // Exit the function if scanning fails
        }

        await device?.connect(autoConnect: true, timeout: Duration(seconds: 10)).then((value) {
          this.device = device;
          checkDeviceStateStream();
          newBleModel.status = BluetoothSuccessType.CONNECTING_DEVICE;
        }).onError((error, stackTrace) {
          printLogs("Invalid Device Data when connecting! : $error");
          lockNotRangeDialog();
        });

      }
    });
  }



  void startScanningTimer() {
    scanningTimer = Timer.periodic(Duration(seconds: 1), (_) {
      print("Scanning Timer Running $scanningCounter");
      scanningCounter++;
      if (scanningCounter > 10) {
        stopScanningTimer();
        scanningCounter = 0;
        error = BluetoothError(
            "Scanning Devices Failed!, Please restart bluetooth",
            BluetoothErrorType.TYPE_SCANNING_FAILED);
        update();
      }
    });
  }

  void stopScanningTimer() {
    scanningTimer!.cancel();
  }

  /// STOP SCAN FUNCTION
  void stopScanningDevices() {
    printLogs("NewBleController stopScanningDevices");
    scanningSubscription?.cancel();
    FlutterBluePlus.stopScan();
  }




  // CHECK DEVICE STATE
  checkDeviceStateStream() {
    device!.state.listen((event) {
      debugPrint("event in device state : $event"+"==="+isBLEConnected.toString() );
      if (event == BluetoothDeviceState.connected && isBLEConnected==false)  {
        isBLEConnected = true;
        // For avoiding multiple entries
        Future.delayed(const Duration(seconds: 5), () {
          isBLEConnected = false;
        });

        _getServices(4);
      } else if (event == BluetoothDeviceState.disconnected && !isConnecting) {
        /// clear device's gatt
        device!.clearGattCache().then((value) {
          /// remove device from mDevices
          device!.disconnect();
          error = BluetoothError(
              "Device Disconnected!", BluetoothErrorType.DEVICE_DISCONNECTED);
          update();
        }).catchError((_) {});
      } else {
        error = BluetoothError(
            "Device Disconnected!", BluetoothErrorType.DEVICE_DISCONNECTED);
        update();
      }
    });
  }

  void retry() {
    print("Bluetooth Success Type${newBleModel.status}");
    printLogs("Bluetooth Success Type${token}");
    newBleModel = NewBleModel();
    error = null;
    device = null;
    token = [];
    stopScanningDevices();
    checkBluetoothState();
    update();
  }

  void _getServices(int place) {
    printLogs("NewBleController _getServices $place");
    if (device != null) {

      printLogs("NewBleController discoverServices");

      BleGetService().getService(device!).then((value) async {
        printLogs("BLEGETSERVICES : ${value}");

        newBleModel.writeCharacteristics = value[0];
        newBleModel.readCharacteristics = value[1];

        /*if (token.isEmpty && !isGettingToken) {
          isGettingToken = true;
          getToken();
        }*/
        await value[1].setNotifyValue(true);
        await value[1].read();
        //if (token.isEmpty && !isGettingToken) {
        BleGetService()
            .getToken(value[0], value[1])
            .then((tokenResponse) async {
          isGettingToken = true;
          token = tokenResponse;
          newBleModel.status = BluetoothSuccessType.RETRIEVED_TOKEN;
          printLogs("BLE GET TOKEN : ${token}");

          /// FOR TESTING
          AppUtils().writeCharacteristicsUnlock = value[0];
          AppUtils().readCharacteristicsUnlock = value[1];
          AppUtils().tokenTest = token;
          print("write chara value[0]: ${value[0]}");
          print("read chara value[1] : ${value[1]}");
          BleGetService()
              .issueUnlockCommand(
                  getMacAddress, propertyId, token, value[0], value[1])
              .then((result) async {
                print("UNLOCK REPEAT ${unlockRepeat}");
                if(unlockRepeat==true){
                  unlockRepeat==false;
                  NewBleController().refresh();
                  // Get.delete<NewBleController>();
                  Get.back();
                  return true;
                }else{
                  Future.delayed(const Duration(seconds: 2), () {
                    // updateLockStatusAPI(device!);
                  });
                }
          });
          // }
        }).onError((error, stackTrace) {
          printLogs("BLE GET TOKEN ERROR $error");
          printLogs("BLE GET TOKEN ERROR ${stackTrace.toString()}");
        });

        //}

        //readCharacteristics();
      }).onError((error, stackTrace) {
        error ==
            BluetoothError("Unable to get device characteristics",
                BluetoothErrorType.GET_CHARACTERISTICS_FAILED);
        update();
      });
    } else {
      error ==
          BluetoothError("Unable to get device characteristics",
              BluetoothErrorType.GET_CHARACTERISTICS_FAILED);
      update();
    }
  }

  Duration getDurationFromNow(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    return dateTime.difference(now);
  }



  void issueTokenGenerateCommand() {
    newBleModel.writeCharacteristics
        ?.write(_generateTokenCommand(), withoutResponse: true);
    update();
  }

  void printLogs(String logs) {
    var logger = Logger();
    logger.d("BLE Logs: $logs");
  }
  void readAndWriteCharacteristic(BluetoothDevice device, Guid characteristicId) async {
    try {
      // Discover services for the device
      List<BluetoothService> services = await device.discoverServices();

      // Loop through each service to find the desired characteristic
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Check if the characteristic UUID matches the desired characteristicId
          if (characteristic.uuid == characteristicId) {
            // Read the value of the characteristic
            List<int> value = await characteristic.read();
            print('Read value: $value');

            // Write command to the characteristic
            await writeCharacteristic(device, characteristicId, utf8.encode('getbatter'));
            print('Command sent successfully.');

            return; // Exit the loop once the characteristic is found and written to
          }
        }
      }

      // If the desired characteristic is not found
      print('Characteristic with ID $characteristicId not found.');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> writeCharacteristic(BluetoothDevice device, Guid characteristicId, List<int> data) async {
    try {
      // Discover services for the device
      List<BluetoothService> services = await device.discoverServices();

      // Loop through each service to find the desired characteristic
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Check if the characteristic UUID matches the desired characteristicId
          if (characteristic.uuid == characteristicId) {
            // Write data to the characteristic
            await characteristic.write(data);
            print('Data written successfully.');
            return; // Exit the loop once the characteristic is found and written to
          }
        }
      }

      // If the desired characteristic is not found
      print('Characteristic with ID $characteristicId not found.');
    } catch (e) {
      print('Error: $e');
    }
  }
  /*Methods for Commands*/
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

    var encryptCommand = encrypt(command);
    return encryptCommand;
  }

  Uint8List _generateUnlockCommand() {
    var t0 = token[0];
    var t1 = token[1];
    var t2 = token[2];
    var t3 = token[3];

    var command = [5, 1, 6, 48, 48, 48, 48, 48, 48, t0, t1, t2, t3, 0, 0, 0];
    var encryptCommand = encrypt(command);
    return encryptCommand;
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

  // CONVERT SCAN RESULT MANUFACTURER DATA TO MAC ADDRESS
  String convertManuDataToMac(Map<int, List<int>> manufacturerData) {
    String macAddress = "";
    List<int> encodedMac = [];
    manufacturerData.forEach((key, value) {
      encodedMac = value;
    });

    for (int i = 0; i < encodedMac.length; i++) {
      String hex = encodedMac[i].toRadixString(16).padLeft(2, '0');
      macAddress = macAddress + hex;
    }

    if (macAddress.length > 12) {
      return '0103${macAddress.substring(0, 12)}';
    } else {
      return '0103$macAddress';
    }
  }

  void disconnectBLEDevice() {
    device?.disconnect();
  }

  startTimer(int seconds) {
    const duration = Duration(seconds: 1);
    remainingseconds = seconds;
    timer2 = Timer.periodic(duration, (timer) {
      if (remainingseconds == 0) {
        time.value = "0:00";
        timer.cancel();
      } else {
        int minutes = remainingseconds ~/ 60;
        int seconds = remainingseconds % 60;
        time.value =
            "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}";
        debugPrint("time: ${time.value}");
        debugPrint("remainingSeconds: $remainingseconds");
        remainingseconds--;
      }
    });
  }

  // OBTAINING MAC ADDRESS FROM THE SECURE STORAGE WHICH WE STORED IN SCAN QR DIALOG
  // readMacAddress() async {
  //   getMacAddress = await SecureStorage().readSecureData('macAddress');
  //   String value = getMacAddress.toUpperCase();
  //   addColon(value);
  //   return getMacAddress;
  // }

  // ADDING COLON IN MAC ADDRESS FOR ANDROID DEVICES
  addColon(getMacAddress) async {
    if (getMacAddress != null) {
      String result = await getMacAddress.substring(4);
      formattedMacAddress = result.replaceAllMapped(
          RegExp(r".{2}"), (match) => "${match.group(0)}:");
      formattedMacAddress =
          formattedMacAddress.substring(0, formattedMacAddress.length - 1);
      debugPrint("formattedMacAddress: $formattedMacAddress");
    }
  }


  Future<bool> getAndroidVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (int.parse(androidInfo.version.release) > 11) {
        return true;
      }

      debugPrint("version : ${androidInfo.version.release}");
      return false;
    }
    throw false;
  }

  @override
  void dispose() {
    Get.delete<NewBleController>();
    super.dispose();
  }
}
