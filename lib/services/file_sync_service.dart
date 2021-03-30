import 'dart:io';
import 'package:get/get.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';

class FileSyncService {
  List<HiddenFileModel> _models;
  List<HiddenFileModel> get models => this._models;
  AppService appService;
  DBService dbService;

  FileSyncService(List<HiddenFileModel> models) {
    this._models = models;
    this.appService = Get.find<AppService>();
    this.dbService = Get.find<DBService>();
  }

  Future<int> updateEntityStatus(int status, int id) async {
    var result = await dbService.db.update(
        'hidden_files', <String, dynamic>{'hidden': status},
        where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<bool> isFileEmpty(File file) async {
    int res = await file.length();
    if (res == 0) {
      return true;
    }
    return false;
  }

  Future<bool> isFolderEmpty(Directory dir) async {
    int len = await dir.list().length;
    if (len == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> checkForEmptyDir(Directory hiddenDir, Directory originalDir,
      HiddenFileModel dmodel) async {
    if (await this.isFolderEmpty(hiddenDir) == true &&
        await this.isFolderEmpty(originalDir) == false) {
      await this.updateEntityStatus(0, dmodel.id);
    } else if (await this.isFolderEmpty(hiddenDir) == false &&
        await this.isFolderEmpty(originalDir) == true) {
      await this.updateEntityStatus(1, dmodel.id);
    }
  }

  Future<void> checkForEmptyFile(
      File hiddenFile, File originalFile, HiddenFileModel fmodel) async {
    if (await this.isFileEmpty(hiddenFile) == true &&
        await this.isFileEmpty(originalFile) == false) {
      await this.updateEntityStatus(0, fmodel.id);
    } else if (await this.isFileEmpty(hiddenFile) == false &&
        await this.isFileEmpty(originalFile) == true) {
      await this.updateEntityStatus(1, fmodel.id);
    }
  }

  Future<void> syncFile(HiddenFileModel fmodel) async {
    var hiddenFile = new File(fmodel.hiddenPath);
    var originalFile = new File(fmodel.originalPath);
    var hiddenFileExists = await hiddenFile.exists();
    var originalFileExists = await originalFile.exists();

    if (originalFileExists == false && hiddenFileExists == false) {
      await dbService.db
          .delete('hidden_files', where: "id = ?", whereArgs: [fmodel.id]);
    } else if (hiddenFileExists && originalFileExists) {
      await this.checkForEmptyFile(hiddenFile, originalFile, fmodel);
    } else {
      if (fmodel.hidden == 1) {
        if (hiddenFileExists == false && originalFileExists == true) {
          await this.updateEntityStatus(0, fmodel.id);
        }
      } else {
        if (hiddenFileExists == true && originalFileExists == false) {
          await this.updateEntityStatus(1, fmodel.id);
        }
      }
    }
  }

  Future<void> syncDirectory(HiddenFileModel dmodel) async {
    var hiddenDir = new Directory(dmodel.hiddenPath);
    var originalDir = new Directory(dmodel.originalPath);
    var hiddenDirExists = await hiddenDir.exists();
    var originalDirExists = await originalDir.exists();

    if (originalDirExists == false && hiddenDirExists == false) {
      await dbService.db
          .delete('hidden_files', where: "id = ?", whereArgs: [dmodel.id]);
    } else if (originalDirExists && hiddenDirExists) {
      await this.checkForEmptyDir(hiddenDir, originalDir, dmodel);
    } else {
      if (dmodel.hidden == 1) {
        if (hiddenDirExists == false && originalDirExists == true) {
          await this.updateEntityStatus(0, dmodel.id);
        }
      } else {
        if (hiddenDirExists == true && originalDirExists == false) {
          await this.updateEntityStatus(1, dmodel.id);
        }
      }
    }
  }
  String getProbableActivePath(HiddenFileModel model){
    if(model == null) return null;
    if(model.hidden == 1) {
      return model.hiddenPath;
    } else {
      return model.originalPath;
    }
  }

  Future<void> syncTrackedEntities() async {
    if (_models == null || _models.length == 0) return;
    for (var model in _models) {
      switch (await FileSystemEntity.type(this.getProbableActivePath(model))) {
        case FileSystemEntityType.file:
          await this.syncFile(model);
          break;
        case FileSystemEntityType.directory:
          await this.syncDirectory(model);
          break;
        case FileSystemEntityType.notFound:
          await dbService.db.delete('hidden_files', where: "id = ?", whereArgs: [model.id]);
          break;
        default:
          await this.syncFile(model);
      }
    }
  }
}
