import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saivault/bindings/main_binding.dart';
import 'package:saivault/controllers/main_controller.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/services/storage_service.dart';
import 'package:saivault/config/route_config.dart';
import 'package:password_hash/password_hash.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

Future<void> main() async {
  /*String val = "hello world";
  PBKDF2 generator = new PBKDF2();
  var saltOne = Salt.generateAsBase64String(6);
  var hash = generator.generateBase64Key(val, saltOne,1000, 32);
  List<int> bytes = utf8.encode(hash);
  Digest digest = sha256.convert(bytes);

  PBKDF2 generator2 = new PBKDF2();
  var salt2 = Salt.generateAsBase64String(6);
  var hash2 = generator2.generateBase64Key("Hello Chisom", saltOne,1000, 32);
  List<int> bytes2 = utf8.encode(hash2);
  Digest digest2 = sha256.convert(bytes2);
  print(digest.toString());
  print(digest.toString() == digest2.toString());*/
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  /*StorageService store = Get.find<StorageService>();
  await store.store.delete(key: 'encryption_key');
  await store.store.delete(key: 'encryption_key_iv');
  await store.store.delete(key: 'password_salt');
  await store.store.delete(key: 'user_password');
  print('all done deleteing');*/
  runApp(MyApp());
}

Future<void> initServices() async {
  await Get.putAsync<DBService>(() async => await DBService().init());
  //Get.put<StorageService>(StorageService()).init();
  Get.lazyPut<MainController>(() => new MainController());
  Get.put<AppService>(AppService());
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
      initialRoute: control.isSetup? "/login" : "/setup",
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
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
    );
  }
}




