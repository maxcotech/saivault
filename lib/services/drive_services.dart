import 'dart:io' as io;
import 'dart:typed_data';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:saivault/config/app_constants.dart';
import 'package:saivault/http/google_client.dart';
import 'package:saivault/services/app_service.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DriveServices{
  GoogleSignInAccount account;
  DriveApi driveApi;
  AppService appService;
  String driveFolder = "appDataFolder";

  Future<DriveServices> init() async {
    this.appService = Get.find<AppService>();
    await this.signInToDrive();
    if(this.account != null){
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      this.driveApi = DriveApi(authenticateClient);
    } else {
      Get.rawSnackbar(message:"Google Sign in failed.",duration: Duration(seconds:2));
    }
    
    return this;
  }

  Future<void> signInToDrive() async {
    if(this.account != null) return;
    final googleSignIn = GoogleSignIn.standard(scopes: [DriveApi.driveScope, DriveApi.driveAppdataScope]);
    if(appService.pref.containsKey('signed_in') == false || appService.pref.get('signed_in') == false){
      this.account = await googleSignIn.signIn();
      await appService.pref.setBool('signed_in',true);
    } else {
      this.account = await googleSignIn.signInSilently().whenComplete(() => null);
    }
    print("User account is this now $account");
    return;
  }

  Future<void> logoutFromDrive() async {
    final googleSignIn = GoogleSignIn.standard(scopes:[DriveApi.driveScope,DriveApi.driveAppdataScope]);
    await googleSignIn.signOut();
    appService.pref.setBool('signed_in',false);
  }

  Future<List<File>> getBackedUpFiles() async {
    if(this.driveApi == null) throw new Exception('Backup Service was not properly initiialized.');
    FileList fileList = await this.driveApi.files.list(spaces:this.driveFolder);
    for(var file in fileList.files){
      print("file name: ${file.name} , file original name: ${file.originalFilename} file id: ${file.id}");
    }
    return fileList.files;
  }

  Future<io.File> downloadDatabaseFile(String fileId) async {
    if(this.driveApi == null) throw new Exception('Backup Service was not properly initialized.');
    Media file = await driveApi.files.get(fileId,downloadOptions: DownloadOptions.FullMedia);
    String saveFilePath = join(await getDatabasesPath(),DATABASE_NAME);
    io.File saveFile = new io.File(saveFilePath);
    List<int> dataStore = <int>[];
    await for(var data in file.stream){
      dataStore.insertAll(dataStore.length,data);
    }
    return await saveFile.writeAsBytes(dataStore);
  }

  Future<String> getIdOfNamedFile(String fileName) async {
    var fileList = await this.driveApi.files.list(spaces:this.driveFolder);
    if(fileList == null || fileList.files.length == 0) return null;
    for(var file in fileList.files){
      if(file.name == fileName){
        print("getIdOfNamedFile: Found this ${file.id}");
        return file.id;
      }
    }
    return null;

  }

  Future uploadFileToDrive(io.File file) async {
    if(file == null || await file.exists() == false) throw new Exception('File to backup is invalid.');
    if(this.driveApi == null) throw new Exception('Backup service was not properly initialized.');
    String fileName = file.path.split('/').last;
    Media media = new Media(file.openRead(),await file.length());
    var driveFile = new File();
    driveFile.name = fileName;
    var fileId = await this.getIdOfNamedFile(fileName); var result;
    if(fileId == null){
      driveFile.parents = [this.driveFolder];
      result = await this.driveApi.files.create(driveFile,uploadMedia:media);
    } else {
      result = await this.driveApi.files.update(driveFile,fileId,uploadMedia:media);
    }
    return result;
  }
  

}