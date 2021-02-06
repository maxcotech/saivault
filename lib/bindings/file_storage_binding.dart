import 'package:get/get.dart';
import 'package:saivault/controllers/directory_browser_controller.dart';
import 'package:saivault/controllers/file_storage_controller.dart';

class FileStorageBinding extends Bindings{
  @override 
  void dependencies(){
    Get.create(()=>new DirectoryBrowserController());
    Get.put(new FileStorageController());
  
  }
}