import 'package:get/get.dart';
import 'package:liquid_galaxy/view/home_view.dart';
import 'package:liquid_galaxy/routes/route_error.dart';
import 'package:liquid_galaxy/view/setting_view.dart';

class AppRoutes {
  static final List<GetPage> pages = [
    GetPage(name: '/', page: () => HomeView()),
    GetPage(name: '/route_error', page: () => const RouteErrorView()),
    GetPage(name: '/settings', page: () =>  SettingView()),
  ];
}
