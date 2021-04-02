import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saivault/bindings/main_binding.dart';
import 'package:saivault/config/theme_config.dart';
import 'package:saivault/controllers/main_controller.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/config/route_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initServices();


  runApp(GetBuilder(init:MainController(),builder:(control)=>MyApp()));
}

Future<void> initServices() async {
  await Get.putAsync<DBService>(() async => await DBService().init());
  await Get.putAsync<AppService>(() async => await AppService().init());
  Get.put<KeyService>(KeyService());
  Get.lazyPut<MainController>(() => new MainController());
  print('App Services initialized');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final control = Get.find<MainController>();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: MainBinding(),
      initialRoute: "/login",
      getPages: pages(),
      title: 'Saivault',
      themeMode: control.getThemeMode(),
      theme: ThemeConfig.lightTheme(),
      darkTheme: ThemeConfig.darkTheme(),
      
    );
  }
}




