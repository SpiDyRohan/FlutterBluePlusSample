import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/new_ble_controller.dart';

class NewBleScreen extends StatelessWidget {

  var controller = Get.put(NewBleController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:             Text("${controller.newBleModel.bluetoothState}"),
      ),
      body: GetBuilder<NewBleController>(builder: (controller) {
        return controller.newBleModel.bluetoothState != BluetoothAdapterState.on
            ? enableBluetoothView()
            : controller.error != null
            ? errorView()
            : Text(
            controller.newBleModel.status?.name ??
                'No Status Found!',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, color: Colors.black));
      }),
    );
  }

  Widget enableBluetoothView() {
    return Column(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Background color
            ),
            onPressed: () {
              print("BLUETooth STATE ${controller.newBleModel.bluetoothState}");
              //controller.checkBluetoothPermission();
              if (Platform.isAndroid) {
                controller.checkBluetoothState();
              } else {
                controller.enableBluetoothIOS();
              }
            },
            child: const Text("Enable Bluetooth"))
      ],
    );
  }

  Widget errorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.error!.message,
          style: const TextStyle(fontSize: 16.0),
        ),
        ElevatedButton(
            onPressed: () {
              controller.retry();
            },
            child: const Text("Retry!"))
      ],
    );
  }
}
