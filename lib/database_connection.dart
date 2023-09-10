import 'package:dart_mysql/dart_mysql.dart' as dart_mysql;
import 'dart:async';

Future main() async {
  DatabaseConnection db = DatabaseConnection();
   await db.connect();
  var results = await db.connection.query('select * from ProvaTheFridge.Utente');
  if (results.isEmpty) {
    print('No results');
  } else {
    for (var row in results) {
      print(row);
    }
  }
  db.close();
}

class DatabaseConnection {

  String hostname = 'localhost';
  int port = 8889;
  String user = 'root';
  String password = 'root';
  String database = 'ProvaTheFridge';
  var settings;
  var connection;

  static final DatabaseConnection _instance = DatabaseConnection._internal();

  DatabaseConnection._internal() {
    this.settings = dart_mysql.ConnectionSettings(
      host: this.hostname,
      port: this.port,
      user: this.user,
      password: this.password,
      db: this.database,
    );
    this.connection = dart_mysql.MySqlConnection.connect(this.settings);
  }


  factory DatabaseConnection() {
    return _instance;
  }

  Future<void> connect() async {
    this.connection = await dart_mysql.MySqlConnection.connect(this.settings);
  }

  Future<List> query(String sql) async {
    return await this.connection.query(sql);
  }

  Future<void> close() async {
    await this.connection.close();
  }

}