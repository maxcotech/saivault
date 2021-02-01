import 'package:get/get.dart';

class Controller extends GetxController{
   bool _isLoading = false;
   bool get isLoading => this._isLoading;
   void setLoading(bool val){
     this._isLoading = val;
     this.update();
  }
}