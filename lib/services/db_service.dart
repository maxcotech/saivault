import 'dart:convert';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:saivault/config/app_constants.dart';
import 'package:saivault/services/drive_services.dart';

class DBService extends GetxService {
  Database _db;
  List<String> _selectedForBackup = <String>[
    'password_store',
    'key_store',
    'nested_entities',
    'hidden_files'
  ];
  void setSelectedForBackup(List<String> newval) {
    this._selectedForBackup = newval;
  }

  Database get db => this._db;
  void setDb(Database dbase) {
    this._db = dbase;
  }

  Future<DBService> init() async {
    String dbPath = await this.getDatabasePath();
    this._db = await this.initDatabase(dbPath);
    return this;
  }

  Future<String> getDatabasePath() async {
    String path = await getDatabasesPath();
    return join(path, DATABASE_NAME);
  }

  Future<Database> initDatabase(String path) async {
    Database db =
        await openDatabase(path, version: 1, onCreate: this.createDatabase);
    return db;
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      _generateMapFromSelectedData() async {
    if (this._selectedForBackup != null || this._selectedForBackup.length > 0) {
      Map<String, List<Map<String, dynamic>>> mainMap =
          new Map<String, List<Map<String, dynamic>>>();
      for (String selected in this._selectedForBackup) {
        List<Map<String, dynamic>> result = await this._db.query(selected);
        mainMap[selected] = result;
      }
      return mainMap;
    }
    return null;
  }

  Future<String> _generateBackupJson() async {
    var selectedDataMap = await this._generateMapFromSelectedData();
    if (selectedDataMap != null) {
      return jsonEncode(selectedDataMap);
    } else {
      return null;
    }
  }

  Future createBackupOnDrive() async {
    String json = await this._generateBackupJson();
    if (json != null) {
      DriveServices dService = await DriveServices().init();
      await dService.uploadJsonToDrive(json, DATABASE_NAME + ".json");
    }
  }

  Future restoreDatabaseFromDrive({String fileIdentity}) async {
    DriveServices dService = await DriveServices().init();
    String fileId = fileIdentity == null
        ? await dService.getIdOfNamedFile(DATABASE_NAME + ".json")
        : fileIdentity;
    if (fileId != null) {
      String dataString = await dService.downloadJsonById(fileId);
      if (dataString != null) {
        var mapData = jsonDecode(dataString);
        for (String selected in this._selectedForBackup) {
          var selectedList = mapData[selected].cast<Map<String,dynamic>>();
          if (selectedList != null && selectedList.length > 0) {
            await this.insertAll(selected, selectedList);
          }
        }
      }
    } else {
      throw new Exception('Sorry, Could not find any backup data file to restore.');
    }
  }

  Future<List<dynamic>> insertAll(
      String tableName, List<Map<String, dynamic>> payload) async {
    Batch batch = this.db.batch();
    for (var mapItem in payload) {
      batch.insert(tableName, mapItem);
    }
    return await batch.commit();
  }

  Future<void> createDatabase(Database db, int version) async {
    await db.execute("""CREATE TABLE password_store(
        id INTEGER PRIMARY KEY,
        password_label TEXT UNIQUE,
        password_value TEXT,
        initial_vector TEXT,
        created_at TIMESTAMP 
     )""");
    await db.execute("""CREATE TABLE hidden_files(
        id INTEGER PRIMARY KEY,
        original_path TEXT UNIQUE,
        hidden_path TEXT UNIQUE,
        initial_vector TEXT,
        hidden BOOLEAN,
        file_iv TEXT DEFAULT NULL,
        created_at TIMESTAMP
     )""");
    await db.execute("""CREATE TABLE key_store(
        id INTEGER PRIMARY KEY,
        key_label TEXT UNIQUE,
        key_value TEXT,
        created_at TIMESTAMP
     )
     """);
    await db.execute("""CREATE TABLE nested_entities(
        id INTEGER PRIMARY KEY,
        original_path TEXT,
        hidden_path TEXT UNIQUE,
        initial_vector TEXT,
        file_iv TEXT DEFAULT NULL
     )""");
  }
}
