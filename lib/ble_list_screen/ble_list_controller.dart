import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class BleListController extends GetxController{
  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  Rx<Stream<List<ScanResult>>> get scanResult => FlutterBluePlus.scanResults.obs;


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
   startScanning();
  }
  void startScanning() async {
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.value.contains(result.device)) {
          // setState(() {

            if(result.device.advName!=""){
              devices.value.add(result.device);
            }else{

            }
          // });
        }
      }
    }).onError((error){
      print("Error"+error);

    });
  }
  Future<void> connectToDevice(BluetoothDevice device) async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));


    if(device.isConnected){
      device.disconnect();
    }else{
      await device.connect();
      if(device.advName=="8bottle"){
        Get.toNamed(Routes.newBle,arguments: {
          "device":device
        });
      }else{

      }
    }

    // Once connected, you can perform operations on the device.
  }
  void subscribeToNotifications(BluetoothDevice device, Guid characteristicId) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            print('Notification received: $value');
          });
        }
      }
    }
  }


/*  void readCharacteristic(BluetoothDevice device, Guid characteristicId) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          List<int> value = await characteristic.read();
          print('Read value: $value');
        }
      }
    }
  }
  void writeCharacteristic(BluetoothDevice device, Guid characteristicId, List<int> data) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          await characteristic.write(data);
          print('Data written successfully.');
        }
      }
    }
  }*/



}