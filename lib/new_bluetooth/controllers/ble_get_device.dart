import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../secure_storage.dart';


class BleGetDevice {

/*  Future<BluetoothDevice> getScannedDevice(ble,getMacAddress) async {
    final streamController = StreamController<List<ScanResult>>();
    final completer = Completer<BluetoothDevice>();
    Timer? timer;
    int counter = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter++;
      if (counter >= 15) {
        timer.cancel();
        completer.completeError("noresultfound");
      }
    });
    streamController.addStream(FlutterBluePlus.scanResults);
    // var mac = await readMacAddress();

    final subscription = streamController.stream.listen((event) {
      for (ScanResult result in event) {
        print("Saved Mac Address : ${result}");
        print( "Device Mac AddressDATA : ${result.advertisementData.manufacturerData} , ${result.advertisementData.localName}, ${result.device.id}");
        if (getMacAddress.toString().toLowerCase() == result.advertisementData.advName.toLowerCase()) {
          completer.complete(result.device);
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();
    timer.cancel();
    return result;
  }*/
  // Future<BluetoothDevice> getScannedDevice( String getMacAddress) async {
  //   final completer = Completer<BluetoothDevice>();
  //   final List<ScanResult> scanResults = [];
  //   bool isScanning = false; // Track whether scanning is currently running
  //
  //   // Start scanning for devices
  //   FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
  //   isScanning = true; // Update scanning status
  //
  //   // Listen for scan results
  //   final StreamSubscription<List<ScanResult>> scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
  //     for (ScanResult result in results) {
  //       scanResults.add(result);
  //       // Check if the device with the specified name is found
  //       if (result.advertisementData.localName == getMacAddress) {
  //         if (isScanning) {
  //           FlutterBluePlus.stopScan(); // Stop scanning once the desired device is found
  //           isScanning = false; // Update scanning status
  //         }
  //         completer.complete(result.device);
  //         return; // Exit the loop once the device is found
  //       }
  //     }
  //   });
  //
  //   // Wait for the scanning period to complete
  //   await Future.delayed(Duration(seconds: 15));
  //
  //   // If no device is found, complete with an error
  //   if (!completer.isCompleted) {
  //     if (isScanning) {
  //       FlutterBluePlus.stopScan(); // Stop scanning if it's still running
  //       isScanning = false; // Update scanning status
  //     }
  //     completer.completeError("noresultfound");
  //   }
  //
  //   // Cancel the scan subscription
  //   await scanSubscription.cancel();
  //
  //   return completer.future;
  // }


  Future<BluetoothDevice> getScannedDevice() async {
    final streamController = StreamController<List<ScanResult>>();

    streamController.addStream(FlutterBluePlus.scanResults);
    var mac = await readMacAddress();
    final completer = Completer<BluetoothDevice>();
    final subscription = streamController.stream.listen((event) {
      for (ScanResult result in event) {
        // print("Saved Mac Address 1: ${mac}");
        // print(
        //     "Device Mac Address : ${result}");
        if (mac.toString().toLowerCase() ==
            convertManuDataToMac(result.advertisementData.manufacturerData)
                .toLowerCase()) {
          completer.complete(result.device);
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();

    return result;
  }
  Future<bool> checkLockStatus(getMacAddress) async {
    final streamController = StreamController<List<ScanResult>>();
    final completer = Completer<bool>();
    Timer? timer;
    int counter = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter++;
      if (counter >= 15) {
        timer.cancel();
        completer.completeError("noresultfound");
      }
    });
    streamController.addStream(FlutterBluePlus.scanResults);
    // var mac = await readMacAddress();

    bool isLockOpen = false;
    final subscription = streamController.stream.listen((event) {
      for (ScanResult result in event) {
        print("Saved Mac Address : ${result}");
        print("Saved Mac getMacAddress : ${getMacAddress}");
        print(
            "Device Mac Address : ${result.advertisementData.manufacturerData} , ${result.advertisementData.localName}");
        if (getMacAddress.toString().toLowerCase() ==
            convertManuDataToMac(result.advertisementData.manufacturerData)
                .toLowerCase()) {
          String lockState =
          checkManuDataLockStatus(result.advertisementData.manufacturerData)
              .toLowerCase();

          if (lockState == "01") {
            isLockOpen = false;
            completer.complete(isLockOpen);
          } else {
            isLockOpen = true;
            completer.complete(isLockOpen);
          }
        }
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    await streamController.close();
    timer.cancel();
    return result;
  }
  String checkManuDataLockStatus(Map<int, List<int>> manufacturerData) {
    try {
      String macAddress = "";
      List<int> encodedMac = [];
      manufacturerData.forEach((key, value) {
        encodedMac = value;
      });

      for (int i = 0; i < encodedMac.length; i++) {
        String hex = encodedMac[i].toRadixString(16).padLeft(2, '0');
        macAddress = macAddress + hex;
      }

      print("FULLMAC--" + macAddress);

      if (macAddress.length > 16) {
        return '${macAddress.substring(16, 18)}';
      } else {
        return "01";
      }
    } catch (e) {
      return "01";
    }
  }



  Future<BluetoothDevice> getConnectedDevice() async {
    try {
      // Retrieve a list of connected devices
      var devices = await FlutterBluePlus.connectedDevices;

      // Check if there are no connected devices
      if (devices.isEmpty) {
        throw "No Device Connected!";
      }

      // Search for the device with the specified name
      for (var device in devices) {
        print("Connected Device: ${device.name}");
        if (device.name == "8bottle") {
          return device; // Return the device if found
        }
      }

      // If no device with the specified name is found
      throw "Device '8Bottle' not found among connected devices!";
    } catch (e) {
      throw "Error retrieving connected device: $e";
    }
  }


  Future<String> readMacAddress() async {
    var macAdd = await SecureStorage().readSecureData('macAddress');
    String value = macAdd.toUpperCase();
    return value;
  }

  String convertManuDataToMac(Map<int, List<int>> manufacturerData) {
    try {
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
    } catch (e) {
      return "0";
    }
  }
}
