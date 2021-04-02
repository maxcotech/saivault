import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:get/get.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/key_service.dart';


class MainController extends Controller with WidgetsBindingObserver{
  bool _isSetup = false;
  bool get isSetup => this._isSetup;
  KeyService store;
  AppService appService;
  @override 

  Future<void> onInit() async {
    WidgetsBinding.instance.addObserver(this);
    this.appService = Get.find<AppService>();
    this.store = Get.find<KeyService>();
    this._isSetup = await this.store.contains('user_password');
    this.update();
    print('from main controller '+this._isSetup.toString());
    super.onInit();
  }
  Future<void> setThemeMode(bool value) async {
    await appService.setThemeMode(value);
    this.update();
  }
  ThemeMode getThemeMode(){
    bool isDarkTheme = appService.isDarkThemeMode();
    if(isDarkTheme) return ThemeMode.dark;
    return ThemeMode.light;
  }

  void onAppPaused(){
    print('CHISOM: App has been sent to background by user.');
  }
  void onAppResumed() {
    print('on app resume');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    switch(state){
      case AppLifecycleState.paused:this.onAppPaused();break;
      case AppLifecycleState.resumed:this.onAppResumed();break;
      default:print('die hard dude');
    }
    super.didChangeAppLifecycleState(state);
  }



  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}