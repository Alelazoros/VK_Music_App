import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'User.dart';
import 'Song.dart';


class DBProvider {
  static const dbName = 'vk_music.db';
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE User ("
          "id INTEGER PRIMARY KEY,"
          "userId INTEGER,"
          "firstName TEXT,"
          "username TEXT,"
          "lastName TEXT,"
          "image TEXT,"
          "email TEXT,"
          "joined TEXT,"
          "lastLogin TEXT,"
          "token TEXT,"
          "vkAuth BOOLEAN,"
          "isStaff BOOLEAN"
          ")");
      await db.execute("CREATE TABLE Song ("
          "songId INTEGER PRIMARY KEY,"
          "duration INTEGER,"
          "userId INTEGER,"
          "artist TEXT,"
          "name TEXT,"
          "postedAt TEXT,"
          "download TEXT,"
          "localUrl TEXT"
          ")");
      await db.execute("CREATE TABLE LocalSong ("
          "songId INTEGER PRIMARY KEY,"
          "duration INTEGER,"
          "userId INTEGER,"
          "artist TEXT,"
          "name TEXT,"
          "postedAt TEXT,"
          "localUrl TEXT"
          ")");
    });
  }

  newUser(User user) async {
    final db = await database;
    var res = await db.insert("User", user.toJson());
    return res;
  }

  getUser(int id) async {
    final db = await database;
    var res = await db.query("User", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? User.fromJson(res.first) : null;
  }

  updateUser(User user) async {
    final db = await database;
    var res = await db
        .update("User", user.toJson(), where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  deleteUser(int id) async {
    final db = await database;
    db.delete("User", where: "id = ?", whereArgs: [id]);
  }

  newSong(Song song) async {
    final db = await database;
    var res = await db.insert("Song", song.toJson());
    return res;
  }

  updateSong(Song song) async {
    final db = await database;
    var res = await db.update("Song", song.toJson(),
        where: "songId = ?", whereArgs: [song.songId]);
    return res;
  }

  deleteAllSongs() async {
    final db = await database;
    db.rawDelete("Delete * from Song");
  }

  deleteSong(int id) async {
    final db = await database;
    db.delete("Song", where: "songId = ?", whereArgs: [id]);
  }

  getSong(int id) async {
    final db = await database;
    var res = await db.query("Song", where: "songId = ?", whereArgs: [id]);
    return res.isNotEmpty ? Song.fromJson(res.first) : null;
  }
}
