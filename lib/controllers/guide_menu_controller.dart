import 'package:saivault/controllers/controller.dart';
import 'package:saivault/helpers/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart' show Orientation;
import 'dart:async';

class GuideMenuController extends Controller{

  BannerAd bads;
  Completer<BannerAd> completer = new Completer<BannerAd>();

  @override
  void onInit() {
    this.bads = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad){completer.complete(ad as BannerAd);}),
      request: AdRequest(),
      size:AdSize.getSmartBanner(Orientation.landscape)
    );
    bads.load();
    AdManager.createIntAd(this);
    super.onInit();
  }
  @override
  void onClose() {
    bads?.dispose();
    iads?.dispose();
    super.onClose();
  }
}