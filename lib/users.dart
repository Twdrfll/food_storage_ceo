import 'dart:io';
import 'dart:math';
// import 'package:shared_preferences/shared_preferences.dart'; TOGLIERE COMMENTI QUANDO SI SVILUPPERà IN ANDROID
import 'database_connection.dart';
import 'fridge_event.dart' as fridge_event;

/* void main() async {
  User user = User();
  user.setEmail("prova2@gmail.com");
  user.setPassword("pippo");
  user.setFridgeID("1");
  await user.signup();
  await user.login();
  await user.changeUserFridge("2");
} */

class User {

  String id = "";
  String email = "";
  String password = "";
  String color = "";
  String fridgeID = "";
  String query_validate_login = "SELECT * FROM Utente WHERE email = \"?\" AND password = \"?\"";
  String query_validate_email = "SELECT * FROM Utente WHERE email = \"?\"";
  String query_get_color = "SELECT colore FROM Utente WHERE email = \"?\"";
  String query_execute_signup = "INSERT INTO Utente (email, password, colore) VALUES (\"?\", \"?\", \"#000000\")";
  String query_retrieve_user_id = "SELECT id FROM Utente WHERE email = \"?\"";
  String query_update_color = "UPDATE Utente SET colore = \"?\" WHERE email = \"?\"";
  String query_delete_user = "DELETE FROM Utente WHERE email = \"?\"";
  String query_switch_fridge = "UPDATE Utente SET idDispensa = ? WHERE email = \"?\"";

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

  /* TOGLIERE I COMMENTI QUANDO SI SVILUPPERà IN ANDROID
  void retrieveSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.email = prefs.getString("email") ?? "";
    this.password = prefs.getString("password") ?? "";
    this.color = prefs.getString("color") ?? "";
    this.fridgeID = prefs.getString("fridgeID") ?? "";
  }

  void saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", this.email);
    prefs.setString("password", this.password);
    prefs.setString("color", this.color);
    prefs.setString("fridgeID", this.fridgeID);
  }

  void removeLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
    prefs.remove("password");
    prefs.remove("color");
    prefs.remove("fridgeID");
  } */

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
      this.id = await this.getUserId();
      await this.fridgeEvent.communicate();
      return true;
    }
  }

  Future<bool> checkUserPresence() async {
    var data = [this.email];
    DatabaseConnection db = DatabaseConnection();
    String query = DatabaseConnection.querySetupper(data, query_validate_email);
    List results = await db.query(query);
    if (results.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> signup() async {
    List<dynamic> data = [this.email, this.password];
    DatabaseConnection db = DatabaseConnection();
    await db.connect();
    String query = DatabaseConnection.querySetupper(data, query_execute_signup);
    if (await this.checkUserPresence()) {
      print("User already exists, aborting signup...");
      this.fridgeEvent.stopCommunication();
      return false;
    } else {
      await db.query(query);
      this.id = await this.getUserId();
      String new_user_color = generateRandomColorHex();
      data = [new_user_color, this.email];
      query = DatabaseConnection.querySetupper(data, query_update_color);
      await db.query(query);
      this.setColor(new_user_color);
      print("User created!");
      return true;
    }
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

  Future<String> getUserId() async {
    var data = [this.email];
    DatabaseConnection db = DatabaseConnection();
    await db.connect();
    String query = DatabaseConnection.querySetupper(data, query_retrieve_user_id);
    List results = await db.query(query);
    return Future.value(results[0][0].toString());
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

  Future<bool> changeUserFridge(String newFridge) async {
    try {
      DatabaseConnection db = DatabaseConnection();
      await db.connect();
      String query = DatabaseConnection.querySetupper([newFridge, this.email], query_switch_fridge);
      await db.query(query);
      await db.close();
      this.setFridgeID(newFridge);
      this.fridgeEvent.setFridgeID(this.fridgeID);
      await this.fridgeEvent.communicate();
      return true;
    } catch (e) {
      print("Error while changing user fridge: the new fridge probably doesn't exist. Aborting...");
      return false;
    }
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