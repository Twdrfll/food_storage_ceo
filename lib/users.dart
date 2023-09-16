import 'dart:io';
import 'dart:math';

import 'database_connection.dart';
import 'fridge_event.dart' as fridge_event;

/* void main() async {
  User user = User();
  user.setEmail("prova3@gmail.com");
  user.setPassword("cappero");
  await user.login();
} */

class User {

  String email = "";
  String password = "";
  String color = "";
  String fridgeID = "";
  String query_validate_login = "SELECT * FROM Utente WHERE email = \"?\" AND password = \"?\"";
  String query_get_color = "SELECT colore FROM Utente WHERE email = \"?\"";
  String query_execute_signup = "INSERT INTO Utente (email, password, idDispensa, colore) VALUES (\"?\", \"?\", ?, \"#000000\")";
  String query_update_color = "UPDATE Utente SET colore = \"?\" WHERE email = \"?\"";
  String query_delete_user = "DELETE FROM Utente WHERE email = \"?\"";

  fridge_event.FridgeEvent fridgeEvent = fridge_event.FridgeEvent();

  static final User _instance = User._internal();

  User._internal();

  factory User() {
    return _instance;
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setPassword(String password) {
    this.password = password;
  }

  void setColor(String color) {
    this.color = color;
  }

  void setFridgeID(String fridgeID) {
    this.fridgeID = fridgeID;
  }

  Future<bool> login() async {
    var data = [this.email, this.password];
    DatabaseConnection db = DatabaseConnection();
    await db.connect();
    String query = DatabaseConnection.querySetupper(data, query_validate_login);
    List results = await db.query(query);
    await db.close();
    if (results.isEmpty) {
      print("No corresponding user found");
      return false;
    } else {
      print("User found!");
      this.setColor(await this.getColor());
      this.setFridgeID(results[0][1].toString());
      this.fridgeEvent.setFridgeID(this.fridgeID);
      await this.fridgeEvent.communicate();
      return true;
    }
  }

  Future<bool> checkUserPresence() async {
    var data = [this.email, this.password];
    DatabaseConnection db = DatabaseConnection();
    String query = DatabaseConnection.querySetupper(data, query_validate_login);
    List results = await db.query(query);
    if (results.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> signup() async {
    List<dynamic> data = [this.email, this.password, this.fridgeID];
    DatabaseConnection db = DatabaseConnection();
    await db.connect();
    String query = DatabaseConnection.querySetupper(data, query_execute_signup);
    if (await this.checkUserPresence()) {
      print("User already exists, aborting signup...");
      this.fridgeEvent.stopCommunication();
      return false;
    } else {
      await db.query(query);
      String new_user_color = generateRandomColorHex();
      data = [new_user_color, this.email];
      query = DatabaseConnection.querySetupper(data, query_update_color);
      await db.query(query);
      this.setColor(new_user_color);
      /*
      creare nuova dispensa
      collegare dispensa all'utente
      avvertire il server node
       */
      this.fridgeEvent.setFridgeID(this.fridgeID);
      await this.fridgeEvent.communicate();
      await db.close();
      print("User created!");
      return true;
    }
  }

  Future<void> setFridge(String fridgeID) async {
    this.fridgeID = fridgeID;
  }

  Future<bool> deleteUser() async {
    var data = [this.email];
    DatabaseConnection db = DatabaseConnection();
    await db.connect();
    String query = DatabaseConnection.querySetupper(data, query_delete_user);
    if (await this.login()) {
      try {
        await db.connect();
        await db.query(query);
        print("User deleted!");
        this.fridgeEvent.stopCommunication();
      } catch (e) {
        print("Error while deleting user, probably because it still as products into its fridge: ");
        print(e);
      }
      await db.close();
      return true;
    } else {
      print("User not found, aborting delete...");
      return false;
    }
  }

  Future<String> getColor() async {
    DatabaseConnection db = DatabaseConnection();
    await db.connect();
    String query = DatabaseConnection.querySetupper([this.email], query_get_color);
    List results = await db.query(query);
    await db.close();
    this.setColor(results[0][0].toString());
    return Future.value(this.color);
  }

  static String generateRandomColorHex() {
    final Random random = Random();
    final int red = random.nextInt(256);
    final int green = random.nextInt(256);
    final int blue = random.nextInt(256);
    final String hexColor = '#${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
    return hexColor;
  }

}