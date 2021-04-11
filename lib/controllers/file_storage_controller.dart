import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:saivault/controllers/file_manager_controller.dart';
import 'package:saivault/controllers/settings_controller.dart';
import 'package:saivault/helpers/mixins/connection_mixin.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/helpers/mixins/path_mixin.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:get/get.dart';
import 'package:saivault/services/storage_channel_service.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart' show Orientation;
import 'package:saivault/helpers/ad_manager.dart';
import 'dart:async';


class FileStorageController extends Controller with FileExtension, PathMixin, ConnectionMixin{
  List<String> _pathsToTrack;
  DBService dbService;
  AppService appService;
  FileManagerController mController;
  StorageChannelService channelService;
  SettingsController settings;
  List<String> get pathsToTrack => this._pathsToTrack;
  BannerAd bads;
  Completer<BannerAd> completer = new Completer<BannerAd>();


  @override
  Future<void> onInit() async {
    dbService = Get.find<DBService>();
    appService = Get.find<AppService>();
    this._pathsToTrack = new List<String>();
    mController = Get.find<FileManagerController>();
    settings = Get.find<SettingsController>();
    channelService = new StorageChannelService();
    this.bads = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad){completer.complete(ad as BannerAd);}),
      request: AdRequest(),
      size:AdSize.getSmartBanner(Orientation.landscape)
    );
    bads.load();
    super.onInit();
  }

  Future<List<StorageInfo>> getStoragePaths() async {
    return await PathProviderEx.getStorageInfo();
  }

  void toggleAppendPathsToTrack(String path) {
    this.togglePathsToTrack(path);
    this.update();
  }

  void togglePathsToTrack(String path) {
    if (_pathsToTrack.contains(path)) {
      _pathsToTrack.remove(path);
    } else {
      _pathsToTrack.add(path);
    }
  }

  void toggleAppendDirectoryContentToTrack(List<FileSystemEntity> entities) {
    if (entities == null || entities.length == 0) return null;
    for (FileSystemEntity entity in entities) {
      this.togglePathsToTrack(entity.path);
    }
    this.update();
  }

  bool pathIsSelected(String path) {
    if (_pathsToTrack.contains(path)) {
      return true;
    }
    return false;
  }

  Future<String> generateUniqueCryptPath(String path) async {
    String newPath;
    while (true) {
      newPath = await this.generateCryptPathFromOriginal(path, appService);
      if (await this.cryptPathExists(newPath) == false) {
        break;
      }
    }
    print('new path ' + newPath);
    return newPath;
  }

  Future<bool> cryptPathExists(String path) async {
    List<Map<String, dynamic>> results = await dbService.db
        .query('hidden_files', where: 'hidden_path = ?', whereArgs: [path]);
    if (results.length > 0) {
      return true;
    }
    return false;
  }

  Future<bool> originalPathExists(String path) async {
    List<Map<String, dynamic>> results = await dbService.db
        .query('hidden_files', where: 'original_path = ?', whereArgs: [path]);
    if (results.length > 0) {
      return true;
    }
    return false;
  }

  Future<void> onTrackSelected() async {
    if(await channelService.isStoragePermissionGranted()){
      try {
        this.setLoading(true);
        await this.trackSelected();
        if(await this.isConnectedToInternet() && appService.shouldAutoBackup()){
          await this.settings.backupDatabase();
          Get.rawSnackbar(message:'Backup data successfully updated.',duration:Duration(seconds:3));
        } 
        this.setLoading(false);
      } catch (e) {
        this.setLoading(false);
        getDialog(message: e.toString(), status: Status.error);
      }
    } else {
      await this.requestUriPermission();
    }
    
  }

  

  Future<bool> renameEntity(String path,String newFileName) async {
    try {
      File file = new File(path);
      String newPath = replaceEntityOnPath(path, newFileName);
      var result = await file.rename(newPath);
      if(result == null){ return false;}
      return true;
    }
    on FileSystemException catch(e){
      print(e.message);
      String entityPath = await removeRootFromPath(path);
      return channelService.renameDocument(entityPath, newFileName);
    }
  }

  Future<void> trackSelected() async {
    this.setLoading(true);
    if (this._pathsToTrack.length > 0) {
      Key key = appService.encryptionKey;
      Encrypter encrypter = new Encrypter(AES(key));
      IV iv = IV.fromLength(12); //changed from 16 to 12
      await Future.forEach(this._pathsToTrack, (String path) async {
        String newPath = path;
        if (this.fileNameContainsSpace(path)) {
          String newFileName = this.generateSpaceFreeFileName(path);
          var result = await this.renameEntity(path, newFileName);
          if(result) newPath = replaceEntityOnPath(path, newFileName);
        } 
        await this.encryptAndSaveTrackedPaths(encrypter, newPath, iv);
      });
    }
    await this.mController.loadTrackFiles();
    Get.until((route) => Get.currentRoute == '/');
    this.setLoading(false);
    this._pathsToTrack.clear();
  }

  Future<void> encryptAndSaveTrackedPaths(
      Encrypter encrypter, String newPath, IV iv) async {
    Encrypted encrypted = encrypter.encrypt(newPath, iv: iv);
    String encryptedText = encrypted.base64;
    if (await this.originalPathExists(encryptedText) == false) {
      String cryptPath = await this.generateUniqueCryptPath(newPath);
      HiddenFileModel model = new HiddenFileModel(
          hiddenPath: cryptPath,
          originalPath: encryptedText,
          initialVector: iv.base64,
          createdAt: DateTime.now().toIso8601String(),
          hidden: 0);
      int result = await dbService.db.insert('hidden_files', model.toMap());
      if (result == -1) throw new Exception('Failed to add new track files.');
    }
  }

  Future<void> browseDirectories(String arg) async {
    var request = await Permission.storage.request();
    if (request.isGranted) {
      Get.toNamed('/directory_browser', arguments: arg);
    }
  }
  @override
  void onClose() {
    bads?.dispose();
    super.onClose();
  }
}
