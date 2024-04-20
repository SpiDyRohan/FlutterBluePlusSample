import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class NewBleModel {
  BluetoothSuccessType? status;
  BluetoothAdapterState? bluetoothState;
  List<ScanResult>? scanResults;
  // BluetoothDevice? bluetoothDevice;
  List<BluetoothService>? services = [];
  BluetoothCharacteristic? readCharacteristics;
  BluetoothCharacteristic? writeCharacteristics;
  // List<int>? token;

  NewBleModel({
    this.status,
    // this.bluetoothDevice,
    this.bluetoothState = BluetoothAdapterState.unknown,
    this.scanResults,
    this.services,
    this.readCharacteristics,
    this.writeCharacteristics,
    /*this.token*/
  });
}

enum BluetoothSuccessType {
  BLUETOOTH_ENABLED,
  SCANNING_DEVICES,
  CONNECTING_DEVICE,
  DEVICE_CONNECTED,
  RETRIEVED_CHARACTERISTICS,
  RETRIEVED_SERVICES,
  RETRIEVED_TOKEN,
  ISSUED_UNLOCK_COMMAND,
  DEVICE_UNLOCKED,
  DEVICE_LOCK_FAILED
}
