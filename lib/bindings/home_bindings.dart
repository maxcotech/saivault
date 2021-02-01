import 'package:get/get.dart';
import 'package:saivault/controllers/password_manager_controller.dart';

class HomeBindings extends Bindings{
  @override 
  void dependencies(){
    Get.put<PasswordManagerController>(new PasswordManagerController());
  }
}