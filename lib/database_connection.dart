import 'package:dart_mysql/dart_mysql.dart' as dart_mysql;
import 'dart:async';

class DatabaseConnection {

  // String hostname = '10.0.2.2';
  String hostname = '10.0.2.2';
  int port = 8889;
  // int port = 8889;
  String user = 'root';
  String password = 'root';
  String database = 'ProvaTheFridge';
  bool connected = false;
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
    // this.connection = dart_mysql.MySqlConnection.connect(this.settings);
    connect().then((value) {
      if (value) {
        connected = true;
        print('Connected to the database');
      } else {
        connected = false;
        print('Error while trying to connect to the database');
      }
    });
  }

  factory DatabaseConnection() {
    return _instance;
  }

  void setHostname(String hostname) {
    this.hostname = hostname;
  }

  void setPort(int port) {
    this.port = port;
  }

  Future<bool> connect() async {
    // this.connection = await dart_mysql.MySqlConnection.connect(this.settings);
    try {
      this.settings = dart_mysql.ConnectionSettings(
        host: this.hostname,
        port: this.port,
        user: this.user,
        password: this.password,
        db: this.database,
      );
      print('connecting to: ' + this.hostname);
      print('at port: ' + this.port.toString());
      this.connection = await dart_mysql.MySqlConnection.connect(this.settings);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List> query(String sql) async {
    var final_result = await this.connection.query(sql);
    List final_result_list = [];
    for (var row in final_result) {
      final_result_list.add(row);
    }
    return final_result_list;
  }

  Future<void> close() async {
    await this.connection.close();
  }

  static String querySetupper(var data, String query) {
    String query_updated = query;
    for (var element in data) {
      query_updated = query_updated.replaceFirst(RegExp('\\?'), element);
    }
    return query_updated;
  }

}