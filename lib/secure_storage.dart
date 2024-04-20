import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  // // FOR WRITING THE DATA
  Future writeSecureData(String key, String value) async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  // // FOR READING THE DATA
  Future readSecureData(String key) async {
    var readData = await _storage.read(key: key);
    return readData;
  }

  // // FOR DELETING TEH DATA
  Future deleteSecureData(String key) async {
    var deleteData = await _storage.delete(key: key);
    return deleteData;
  }

  // // FOR DELETING TEH DATA
  Future deleteAllData() async {
    var deleteData = await _storage.deleteAll();
    return deleteData;
  }
}
