import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Controller extends GetxController{
   bool _isLoading = false;
   bool get isLoading => this._isLoading;
   InterstitialAd iads;
   bool _iadsReady = false;
   bool get iadsReady => this._iadsReady;
   void setIadsReady(bool val){
     this._iadsReady = val;
     this.update();
   }
   void showIntAds(){
     if(this.iadsReady == true){
       this.iads.show();
       this.setIadsReady(false);
     }
   }
   void setLoading(bool val){
     this._isLoading = val;
     this.update();
  }
}