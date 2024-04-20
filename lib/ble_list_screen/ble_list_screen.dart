import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_sample/ble_list_screen/ble_list_controller.dart';
import 'package:get/get.dart';

class BleListScreen extends StatefulWidget {
  const BleListScreen({super.key});

  @override
  State<BleListScreen> createState() => _BleListScreenState();
}

class _BleListScreenState extends State<BleListScreen> {
  final controller = Get.put(BleListController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Scanner'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.scanResult();
        },
        child: StreamBuilder(
          stream: controller.scanResult.value,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (controller.devices.value.isNotEmpty) {
                return ListView.builder(
                  itemCount: controller.devices.value.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        controller.connectToDevice(controller.devices.value[index]);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.devices.value[index].localName,
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              controller.devices.value[index].id.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text("No devices found"),
                );
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
          },
        ),
      ),
    );
  }
}
