import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/controllers/main_controller.dart';
import 'package:saivault/helpers/mixins/connection_mixin.dart';
import 'package:saivault/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:saivault/helpers/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/services/drive_services.dart';
import 'package:saivault/widgets/dialog.dart';
import 'dart:async';


class SettingsController extends Controller with ConnectionMixin{
  List<StorageInfo> storageList;
  AppService appService;
  MainController mainControl;
  DBService dbService;
  BannerAd bads;
  Completer<BannerAd> completer = new Completer<BannerAd>();
  bool isBackingUp = false;
  void setIsBackingUp(bool val){
    this.isBackingUp = val;
    this.update();
  }


  @override
  Future<void> onInit() async {
    this.storageList = await PathProviderEx.getStorageInfo();
    mainControl = Get.find<MainController>();
    this.appService = Get.find<AppService>();
    this.dbService = Get.find<DBService>();
    this.bads = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad){completer.complete(ad as BannerAd);}),
      request: AdRequest(),
      size:AdSize.getSmartBanner(Orientation.landscape)
    );
    bads.load();
    super.onInit();
  }
  String getCurrentStoragePathString(){
    int currentIndex = appService.getStorageLocationIndex();
    if(storageList != null){
      if(storageList.length > currentIndex){
        return storageList[currentIndex].rootDir;
      } else if(storageList.length > 0){
        return storageList[0].rootDir;
      }
    }
    return "";
  }

  Future<void> setShowPathOnBrowser(bool value) async {
    await appService.setShouldShowPathOnBrowser(value);
    this.update();
  }

  Future<void> setShowPathOnManager(bool value) async {
    await appService.setShouldShowPathOnManager(value);
    this.update();
  }
  Future<void> setShouldAutoBackup(bool value) async {
    await appService.setShouldAutoBackup(value);
    this.update();
  }

  void onDownloadFile() async {
     DriveServices dServices = await DriveServices().init();
     await dServices.getBackedUpFiles();
  }

  Future backupDatabase({bool checkSettings=true}) async {
    if(checkSettings == true){
      if(appService.shouldAutoBackup() == false){
        return;
      }
    }
    await dbService.createBackupOnDrive();
    return;
  }

  Future onBackupDatabase() async {
    this.setIsBackingUp(true);
    if(await this.isConnectedToInternet() == false){
      getDialog(
        status:Status.error,
        message:'Sorry, it seems like you are not connected to the internet, please check your network connection and try again.');
      this.setIsBackingUp(false);
      return;
    }
    try{
      await this.backupDatabase(checkSettings: false);
      this.setIsBackingUp(false);
      Get.rawSnackbar(message:'Database backup completed.',duration:Duration(seconds:2));
    }
    on PlatformException catch(e,stacktrace){
      this.setIsBackingUp(false);
      print(e.message+" "+stacktrace.toString());
      getDialog(message:"Sorry, an error occurred, please check your network configuration and try again.",status:Status.error);
    }
    catch(e,stacktrace){
      this.setIsBackingUp(false);
      print(stacktrace.toString());
      print(e.toString());
      getDialog(message:e.toString(),status:Status.error);
    }
  }

  Future<void> onChooseNewStorageLocation() async {
    int val = await chooseNewStorageLocation();
    if(val != null){
      if(await appService.setStorageLocationIndex(val)){
        this.update();
        Get.rawSnackbar(message:'New Storage location successfully saved.',duration:Duration(seconds:4));
      }
    }
  }

  Future<void> setThemeMode(bool value) async {
    await appService.setThemeMode(value);
    this.update();
  }

  Future<int> chooseNewStorageLocation()async{
    int result = await Get.bottomSheet<int>(Container(
      padding:EdgeInsets.only(top:20,left:15,right:15,bottom:15),
      decoration: BoxDecoration(
      color:Get.theme.scaffoldBackgroundColor,
      borderRadius:BorderRadius.only(topRight:Radius.circular(10),topLeft:Radius.circular(10))),
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text('Pick a Storage Location',style:TextStyle(fontSize:15)),
          SizedBox(height:20),
          Column(
            mainAxisSize:MainAxisSize.min,
            children:storageList.map((item) => ListTile(
                  onTap: ()=>Get.back(result:storageList.indexOf(item)),
                  leading:Icon(LineIcons.arrow_circle_o_right ),title:Text(item.rootDir))).toList())
        ]
      )
    ));
    print(result);
    return result;
  }

  @override
  void onClose() {
    bads?.dispose();
    super.onClose();
  }

}