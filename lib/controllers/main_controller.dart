import 'package:flutter/widgets.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:get/get.dart';
import 'package:saivault/services/key_service.dart';

class MainController extends Controller with WidgetsBindingObserver{
  bool _isSetup = false;
  bool get isSetup => this._isSetup;
  KeyService store;
  @override 

  Future<void> onInit() async {
    WidgetsBinding.instance.addObserver(this);
    this.store = Get.find<KeyService>();
    this._isSetup = await this.store.contains('user_password');
    this.update();
    print('from main controller '+this._isSetup.toString());
    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state){
      case AppLifecycleState.paused:print('CHISOM: App has been sent to background by user.');break;
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