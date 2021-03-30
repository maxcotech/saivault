import 'package:get/get.dart';
import 'package:saivault/controllers/home_controller.dart';
import 'package:saivault/controllers/setup_controller.dart';

class MainBinding extends Bindings{
    @override 
    void dependencies(){
      Get.lazyPut<HomeController>(() => new HomeController());
      Get.lazyPut<SetupController>(() => new SetupController());
    }
}