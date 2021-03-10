import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saivault/bindings/main_binding.dart';
import 'package:saivault/controllers/main_controller.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/config/route_config.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  runApp(MyApp());
}

Future<void> initServices() async {
  await Get.putAsync<DBService>(() async => await DBService().init());
  Get.lazyPut<MainController>(() => new MainController());
  await Get.putAsync<AppService>(() async => await AppService().init());
  Get.put<KeyService>(KeyService());
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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch:Colors.blue,
      
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ).copyWith(appBarTheme:AppBarTheme(
        elevation: 1,
        iconTheme: IconThemeData(color:Colors.blueGrey),
        color:Colors.white,textTheme:TextTheme(headline6:TextStyle(
          color:Colors.black87,fontSize:19,fontWeight:FontWeight.bold))))
      
    );
  }
}




