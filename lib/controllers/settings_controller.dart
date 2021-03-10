import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/services/app_service.dart';
import 'package:flutter/material.dart';

class SettingsController extends Controller{
  List<StorageInfo> storageList;
  AppService appService;
  @override
  Future<void> onInit() async {
    this.storageList = await PathProviderEx.getStorageInfo();
    this.appService = Get.find<AppService>();
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

  Future<void> onChooseNewStorageLocation() async {
    int val = await chooseNewStorageLocation();
    if(val != null){
      if(await appService.setStorageLocationIndex(val)){
        this.update();
        Get.rawSnackbar(message:'New Storage location successfully saved.',duration:Duration(seconds:4));
      }
    }
  }

  Future<int> chooseNewStorageLocation()async{
    int result = await Get.bottomSheet<int>(Container(
      padding:EdgeInsets.only(top:20,left:15,right:15,bottom:15),
      decoration: BoxDecoration(color:Colors.white,
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

}