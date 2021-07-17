import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crud/contact.dart';

class DatabaseHelper {
  static const _databaseName = 'ContactData.db';
  static const _databaseVersion = 1;
  Database _database;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Contact.tblContact}(
      ${Contact.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Contact.colName} TEXT NOT NULL,
      ${Contact.colMobile} TEXT NOT NULL,
      ${Contact.colAddress} TEXT NOT NULL,
      ${Contact.colBirthday} TEXT NOT NULL,
      ${Contact.colGender} TEXT NOT NULL,
      ${Contact.colImg} TEXT
    )
    ''');
  }

  Future<int> insertContact(Contact contact) async {
    Database db = await database;
    return await db.insert(Contact.tblContact.toUpperCase(), contact.toMap());
  }

  Future<int> updateContact(Contact contact) async {
    Database db = await database;
    return await db.update(Contact.tblContact.toUpperCase(), contact.toMap(),
        where: '${Contact.colId}=?', whereArgs: [contact.id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(Contact.tblContact,
        where: '${Contact.colId}=?', whereArgs: [id]);
  }

  Future<List<Contact>> fetchContacts() async {
    Database db = await database;
    List<Map> contacts = await db.query(Contact.tblContact);
    return contacts.length == 0
        ? []
        : contacts.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> fetchSearchContacts(Contact contact) async {
    Database db = await database;
    List<Map> contacts = await db.rawQuery(
        "SELECT * FROM ${Contact.tblContact} WHERE ${Contact.colName} LIKE '%${contact.search.toUpperCase()}%' OR ${Contact.colMobile} LIKE '%${contact.search.toUpperCase()}%' OR ${Contact.colAddress} LIKE '%${contact.search.toUpperCase()}%' OR ${Contact.colBirthday} LIKE '%${contact.search.toUpperCase()}%' OR ${Contact.colGender}='${contact.search.toUpperCase()}'");
    return contacts.length == 0
        ? []
        : contacts.map((e) => Contact.fromMap(e)).toList();
  }
}
