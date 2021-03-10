import 'dart:typed_data';
import 'package:native_crypto/native_crypto.dart' as nc;
import 'package:saivault/config/app_constants.dart';
import 'package:saivault/helpers/mixins/path_mixin.dart';
import 'dart:io';
import 'dart:convert';
import 'package:saivault/widgets/confirm_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saivault/services/storage_channel_service.dart';

class FileEncryption with PathMixin {
  Future<String> encryptFile(Map<String, dynamic> payload) async {
    File sourceFile = new File(payload['source_path']);
    File desFile = new File(payload['des_path']);
    print('root of source file ' +
        await this.getStoragePathByEntity(sourceFile.path));
    if (await sourceFile.exists() == false) return null;
    if (await desFile.exists() == false) {
      if (await desFile.exists() == false) {
        bool res = await this.forceCreateFile(desFile,mimeType: 'multipart/encrypted');
        if (res != true) return null;
      }
    }
    nc.SecretKey key = nc.SecretKey.fromBytes(base64Url.decode(payload['key']),
        algorithm: nc.CipherAlgorithm.AES);
    nc.AESCipher aes = nc.AESCipher(key,
        nc.CipherParameters(nc.BlockCipherMode.CBC, nc.PlainTextPadding.PKCS5));
    DateTime beforeenc = DateTime.now();
    var result =
        await aes.encryptFile(payload['source_path'], payload['des_path']);
    Duration duration = DateTime.now().difference(beforeenc);
    print('Entity encryption completed in ' +
        duration.inMilliseconds.toString() +
        ' milliseconds');
    var request = await Permission.storage.request();
    if (request.isGranted) {
      try {
        await sourceFile.delete();
        print('deleted source file successfully');
      } on FileSystemException catch (e) {
        print(e.message);
        StorageChannelService channelService = StorageChannelService();
        if (await channelService.deleteDocument(sourceFile.path) != true) {
          print('could not delete file on platform');
          return null;
        }
      }
    }
    if (result != null) {
      return base64Url.encode(result);
    }
    return null;
  }

  Future<bool> forceDeleteResourceBySAF(String path) async {
    StorageChannelService channelService = StorageChannelService();
    if (await channelService.isStoragePermissionGranted()) {
      if (await channelService.deleteDocument(path) != true) {
        return false;
      }
      return true;
    } else {
      if (await confirmDialog(
          message:
              'Please choose the root directory of your external storage (e.g usdcard1) on the following screen to grant $APPNAME write permission')) {
        if (await channelService
            .requestStorageAccess(await this.getStoragePathByEntity(path))) {
          return true;
        }
        return false;
      }
      return false;
    }
  }

  Future<bool> forceCreateFile(File desPath,{String mimeType}) async {
    try {
      await desPath.create(recursive: true);
      return true;
    } catch (e) {
      print(e.toString());
      print('trying to create file via platform channel.');
      String entityPath = await removeRootFromPath(desPath.path);
      if(entityPath != null){
        print('force creating $entityPath on platform channel');
        bool result = await StorageChannelService().createDocument(entityPath,mimeType: mimeType);
        return result;
      }
      return false;
    }
  }
  
  Future<bool> decryptFile(Map<String, dynamic> payload) async {
    File sourceFile = new File(payload['source_path']);
    File desFile = new File(payload['des_path']);
    if (await sourceFile.exists() == false) return false;
    if (await desFile.exists() == false) {
      bool res = await this.forceCreateFile(desFile);
      if (res != true) return false;
    }
    nc.SecretKey key = nc.SecretKey.fromBytes(base64Url.decode(payload['key']),
        algorithm: nc.CipherAlgorithm.AES);
    nc.AESCipher aes = nc.AESCipher(key,
        nc.CipherParameters(nc.BlockCipherMode.CBC, nc.PlainTextPadding.PKCS5));
    DateTime beforedec = DateTime.now();
    if(payload['iv_string'] == null) return false;
    print('iv string is this now '+payload['iv_string']);
    Uint8List iv = base64Url.decode(payload['iv_string']);
    bool decryption =
        await aes.decryptFile(payload['source_path'], payload['des_path'], iv);
    Duration duration = DateTime.now().difference(beforedec);
    print('Entity decryption completed in ' +
        duration.inMilliseconds.toString() +
        ' milliseconds');
    if (decryption == true) {
      var request = await Permission.storage.request();
      if (request.isGranted) {
        try {
          await sourceFile.delete();
          print('deleted source file successfully');
        } on FileSystemException catch (e) {
          print(e.message);
          StorageChannelService channelService = StorageChannelService();
          if (await channelService.deleteDocument(sourceFile.path) != true) {
            print('could not delete file on platform');
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }
}
