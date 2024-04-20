class BluetoothError {
  String message;
  BluetoothErrorType type;

  BluetoothError(this.message, this.type);
}

enum BluetoothErrorType {
  TYPE_BLUETOOTH_UNAVAILABLE,
  TYPE_SCANNING_FAILED,
  GET_CHARACTERISTICS_FAILED,
  DEVICE_DISCONNECTED,
  CONNECT_DEVICE_ERROR,
}
