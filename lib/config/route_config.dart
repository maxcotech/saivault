import 'package:get/get.dart';
import 'package:saivault/bindings/home_bindings.dart';
import 'package:saivault/services/storage_service.dart';
import 'package:saivault/views/add_password_view.dart';
import 'package:saivault/views/edit_password_view.dart';
import 'package:saivault/views/home_view.dart';
import 'package:saivault/views/login_view.dart';
import 'package:saivault/views/setup_view.dart';


final store = Get.find<StorageService>();

List<GetPage> pages(){
  return <GetPage>[
    GetPage(name:"/",page:() => HomeView(title:'Saivault'),binding:HomeBindings()),
    GetPage(name:"/setup",page:() => SetupView()),
    GetPage(name:"/login",page:() => LoginView()),
    GetPage(name:"/add_password",page:() => AddPasswordView()),
    GetPage(name:"/edit_password",page:() => EditPasswordView())
  ];
}
