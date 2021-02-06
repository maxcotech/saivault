import 'package:saivault/controllers/controller.dart';
import 'package:get/get.dart';
import 'package:saivault/services/key_service.dart';

class MainController extends Controller{
  bool _isSetup = false;
  bool get isSetup => this._isSetup;
  KeyService store;
  @override 

  Future<void> onInit() async {
    this.store = Get.find<KeyService>();
    this._isSetup = await this.store.contains('user_password');
    this.update();
    print('from main controller '+this._isSetup.toString());
    super.onInit();
  }
}