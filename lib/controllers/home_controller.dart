import 'package:saivault/controllers/controller.dart';
import 'package:saivault/services/app_service.dart';
import 'package:get/get.dart';

class HomeController extends Controller{
  int _currentIndex = 0;
  AppService _appService;
  int get currentIndex => this._currentIndex;
 
  void onInit(){
    this._appService = Get.find<AppService>();
    if(_appService.encryptionKey == null){
      Get.offNamed('/login');
    }
    super.onInit();
  }
  void setCurrentIndex(int index){
    this._currentIndex = index;
    this.update();
  }
}