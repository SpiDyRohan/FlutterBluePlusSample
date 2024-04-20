import 'package:flutter_blue_plus_sample/ble_list_screen/ble_list_screen.dart';
import 'package:get/get.dart';

import '../new_bluetooth/bindings/new_ble_binding.dart';
import '../new_bluetooth/views/new_ble_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initialRoute = Routes.bleListScreen;

  static final routes = [
    GetPage(
        name: Routes.bleListScreen,
        page: () => BleListScreen()),
    GetPage(
        name: Routes.newBle,
        page: () => NewBleScreen(),
        binding: NewBleBinding()),
  ];
}
