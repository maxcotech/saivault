import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saivault/controllers/controller.dart';


class AdManager {


  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7311612363559547~4480706224";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_ADMOB_APP_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static void createIntAd(Controller control,{AdRequest request}){
    control.iads ??= InterstitialAd(
      adUnitId:AdManager.interstitialAdUnitId,
      request:request ?? AdRequest(),
      listener: AdListener(
        onAdLoaded: (Ad ad){print('iads loaded');control.setIadsReady(true);},
        onAdFailedToLoad: (Ad ad,LoadAdError er){ 
          ad.dispose();
          control.iads = null; 
          AdManager.createIntAd(control,request:request);
        }
      )
    )..load();
  }
  

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    throw new UnsupportedError("Unsupported platform");
  }
  

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7311612363559547/9256189057";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7311612363559547/6703189665";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "<YOUR_ANDROID_REWARDED_AD_UNIT_ID>";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_REWARDED_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}