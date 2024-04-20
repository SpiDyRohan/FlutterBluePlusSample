import 'package:get/get.dart';

import '../controllers/new_ble_controller.dart';

class NewBleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewBleController());
  }
}
