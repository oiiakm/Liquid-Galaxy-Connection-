import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy/routes/route_config.dart';
import 'routes/route_error.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      unknownRoute: GetPage(name: '/route_error', page: () => const RouteErrorView()),
      getPages: AppRoutes.pages,
    );
  }
}