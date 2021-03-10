import 'package:get/get.dart';
import 'package:saivault/controllers/file_manager_controller.dart';
import 'package:saivault/controllers/password_manager_controller.dart';
import 'package:saivault/controllers/settings_controller.dart';

class HomeBindings extends Bindings{
  @override 
  void dependencies(){
    Get.put<PasswordManagerController>(new PasswordManagerController());
    Get.put<FileManagerController>(new FileManagerController());
    Get.put<SettingsController>(new SettingsController());
  }
}