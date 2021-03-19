import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:saivault/config/app_constants.dart';

class DBService extends GetxService{

   Database _db;
   Database get db => this._db;
   Future<DBService> init() async {
     String path = await getDatabasesPath();
     String dbPath = join(path,DATABASE_NAME);
     this._db = await this.initDatabase(dbPath);
     return this;
   }
   Future<Database> initDatabase(String path) async {
      Database db = await openDatabase(
        path,
        version:1,
        onCreate:this.createDatabase);
      return db;
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