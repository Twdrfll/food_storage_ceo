import 'dart:math';
import 'database_connection.dart';
import 'fridge_event.dart' as fridge_event;
import 'users.dart' as users;

/* void main() async {
  users.User new_user = users.User();
  new_user.setEmail("prova@gmail.com");
  new_user.setPassword("pluto");
  await new_user.login();
  await new_user.signup();
  LocalFridge local_fridge = LocalFridge();
  await local_fridge.createFridgeAndDictionary();
  await local_fridge.setupFridge();
  await local_fridge.populateLocalFridge();
  print("Elementi nel dizionario: ");
  for (var element in local_fridge.localDictionary.dictionary_elements) {
    print(element.name + " " + element.barcode + " " + element.days_to_expiration + " " + element.id);
  }
  print("Elementi nel frigo: ");
  for (var element in local_fridge.fridge_elements) {
    print(element.name + " " + element.barcode + " " + element.days_to_expiration + " " + element.quantity.toString() + " " + element.expiration_date + " " + element.color);
  }
  // imposto il prodotto come aperto
  await local_fridge.setProductAsOpen(local_fridge.fridge_elements[0]);
  print("Elementi nel frigo: ");
  for (var element in local_fridge.fridge_elements) {
    print(element.name + " " + element.barcode + " " + element.days_to_expiration + " " + element.quantity.toString() + " " + element.expiration_date + " " + element.color);
  }
  await local_fridge.removeElement(local_fridge.fridge_elements[1]);
  print("Elementi nel frigo: ");
  for (var element in local_fridge.fridge_elements) {
    print(element.name + " " + element.barcode + " " + element.days_to_expiration + " " + element.quantity.toString() + " " + element.expiration_date + " " + element.color);
  }
} */

class LocalFridge {

  String query_retrieve_fridge_elements = """(SELECT Prodotto.id,
  Prodotto.nome,
  Prodotto.barcode,
  Prodotto.giorniValidità,
  ProdottoDispensa.quantità,
  ProdottoDispensa.dataScadenza,
  Utente.colore
  FROM ProdottoDispensa
  LEFT JOIN Utente ON Utente.id = ProdottoDispensa.idUtente
  LEFT JOIN Prodotto ON Prodotto.id = ProdottoDispensa.idProdotto
  WHERE Utente.idDispensa = ?)
  UNION
  (SELECT Prodotto.id,
  Prodotto.nome,
  Prodotto.barcode,
  Prodotto.giorniValidità,
  ProdottoDispensa.quantità,
  ProdottoDispensa.dataScadenza,
  Utente.colore
  FROM ProdottoDispensa
  RIGHT JOIN Utente ON Utente.id = ProdottoDispensa.idUtente
  RIGHT JOIN Prodotto ON Prodotto.id = ProdottoDispensa.idProdotto
  WHERE Utente.idDispensa = ?);""";
  String query_insert_element = "INSERT INTO ProdottoDispensa (idProdotto, idUtente, quantità, dataScadenza) VALUES (\"?\", ?, ?, \"?\");";
  String query_modify_element_date = "UPDATE ProdottoDispensa SET dataScadenza = \"?\" WHERE idProdotto = ? AND idUtente = ? AND quantità = ? AND dataScadenza = \"?\";";
  String query_modify_element_quantity = "UPDATE ProdottoDispensa SET quantità = ? WHERE idProdotto = ? AND idUtente = ? AND dataScadenza = \"?\";";
  String query_update_element_date = """UPDATE ProdottoDispensa AS pd
  JOIN Prodotto AS p ON pd.idProdotto = p.id
  SET pd.dataScadenza = DATE_ADD(CURDATE(), INTERVAL p.giorniValidità DAY)
  WHERE p.id = ?;""";
  String query_remove_element = "DELETE FROM ProdottoDispensa WHERE idProdotto = ? AND idUtente = ? AND quantità = ? AND dataScadenza = \"?\";";
  String query_create_fridge = "INSERT INTO Dispensa (id, idDizionario) VALUES (?, ?);";
  String query_check_fridge = "SELECT id FROM Dispensa WHERE id = ?;";
  String query_create_dictionary = "INSERT INTO Dizionario (id) VALUES (?);";
  String query_check_dictionary = "SELECT id FROM Dizionario WHERE id = ?;";
  String query_assign_fridgeID_to_user = "UPDATE Utente SET idDispensa = ? WHERE email = \"?\";";

  users.User user = users.User();
  String fridge_ID = "";
  LocalDictionary localDictionary = new LocalDictionary();
  List<LocalFridgeElement> fridge_elements = [];
  DatabaseConnection db = DatabaseConnection();

  static final LocalFridge _instance = LocalFridge._internal();

  LocalFridge._internal() {
    this.fridge_ID = this.user.fridgeID;
  }

  factory LocalFridge() {
    return _instance;
  }

  Future<void> setupFridge() async {
    await this.db.connect();
    await this.localDictionary.setupConnection();
    await this.localDictionary.populate_local_dictionary();
    await this.populateLocalFridge();
    this.localDictionary.registerFridgeEvent();
  }

  void registerFridgeEvent() {
    this.user.fridgeEvent.socket.on("fridgeEvent", (data) {
      this.populateLocalFridge();
    });
  }

  Future<void> createFridgeAndDictionary() async {
    String new_id = await this.generateRandomID();
    if (this.fridge_ID == "") {
      this.createDictionary(new_id);
      this.createFridge(new_id);
      this.user.fridgeEvent.setFridgeID(new_id.toString());
      var data = [new_id, this.user.email];
      String assign_fridgeID_to_user = DatabaseConnection.querySetupper(data, this.query_assign_fridgeID_to_user);
      try {
        await this.db.query(assign_fridgeID_to_user);
      } catch (e) {
        print("Error assigning fridgeID to user: " + e.toString());
      }
      this.fridge_ID = new_id.toString();
      this.localDictionary.fridge_ID = new_id.toString();
      await this.user.fridgeEvent.communicate();
    }
  }

  Future<void> createFridge(String new_id) async {
    var data = [new_id, new_id];
    String create_fridge = DatabaseConnection.querySetupper(data, this.query_create_fridge);
    try {
      await this.db.query(create_fridge);
      this.user.fridgeEvent.sendUpdate();
      this.user.fridgeID = new_id.toString();
    } catch (e) {
      print("Error creating fridge: " + e.toString());
    }
  }

  Future<void> createDictionary(String new_id) async {
    var data = [new_id];
    String create_dictionary = DatabaseConnection.querySetupper(data, this.query_create_dictionary);
    try {
      await this.db.query(create_dictionary);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error creating dictionary: " + e.toString());
    }
  }

  Future<String> generateRandomID() async {
    var random = new Random().nextInt(1000000).toString();
    var data = [random.toString()];
    String check_fridge = DatabaseConnection.querySetupper(data, this.query_check_fridge);
    String check_dictionary = DatabaseConnection.querySetupper(data, this.query_check_dictionary);
    var fridge_results = await this.db.query(check_fridge);
    var dictionary_results = await this.db.query(check_dictionary);
    while (fridge_results.length != 0 || dictionary_results.length != 0) {
      random = new Random().nextInt(1000000).toString();
      data = [random.toString()];
      check_fridge = DatabaseConnection.querySetupper(data, this.query_check_fridge);
      check_dictionary = DatabaseConnection.querySetupper(data, this.query_check_dictionary);
      fridge_results = await this.db.query(check_fridge);
      dictionary_results = await this.db.query(check_dictionary);
    }
    return random;
  }

  bool checkIfElementIsInFridge(LocalFridgeElement element) {
    for (var fridge_element in this.fridge_elements) {
      if (fridge_element.name == element.name && fridge_element.barcode == element.barcode && fridge_element.days_to_expiration == element.days_to_expiration && fridge_element.expiration_date == element.expiration_date) {
        return true;
      }
    }
    return false;
  }

  bool checkIfElementDataIsInDictionary(LocalFridgeElement element) {
    for (var dictionary_element in this.localDictionary.dictionary_elements) {
      if (dictionary_element.name == element.name && dictionary_element.barcode == element.barcode && dictionary_element.days_to_expiration == element.days_to_expiration) {
        return true;
      }
    }
    return false;
  }

  String returnIdOfExistingLocalDictionaryElement(LocalFridgeElement element) {
    for (var dictionary_element in this.localDictionary.dictionary_elements) {
      if (dictionary_element.name == element.name && dictionary_element.barcode == element.barcode && dictionary_element.days_to_expiration == element.days_to_expiration) {
        return dictionary_element.id;
      }
    }
    return "null";
  }

  Future<void> addElement(LocalFridgeElement element) async {
    if (this.checkIfElementDataIsInDictionary(element)) {
      if (this.checkIfElementIsInFridge(element)) {
        for (var fridge_element in this.fridge_elements) {
          if (fridge_element.name == element.name && fridge_element.barcode == element.barcode && fridge_element.days_to_expiration == element.days_to_expiration && fridge_element.expiration_date == element.expiration_date) {
            await this.alter_element_quantity(fridge_element, fridge_element.quantity + element.quantity);
          }
        }
      } else {
        this.fridge_elements.add(element);
        String new_element_id = this.returnIdOfExistingLocalDictionaryElement(element);
        var data = [new_element_id, this.user.id, element.quantity.toString(), element.expiration_date];
        String insert_element = DatabaseConnection.querySetupper(data, this.query_insert_element);
        try {
          await this.db.query(insert_element);
          this.user.fridgeEvent.sendUpdate();
        } catch (e) {
          print("Error inserting element: " + e.toString());
        }
      }
    } else {
      LocalDictionaryElement new_element = LocalDictionaryElement(element.name, element.barcode, element.days_to_expiration);
      await this.localDictionary.addElement(new_element);
      this.addElement(element);
    }
  }

  Future<void> removeElement(LocalFridgeElement element) async {
    var data = [element.id, this.user.id, element.quantity.toString(), element.expiration_date];
    String remove_element = DatabaseConnection.querySetupper(data, this.query_remove_element);
    try {
      await this.db.query(remove_element);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error removing element: " + e.toString());
    }
    this.fridge_elements.remove(element);
  }

  Future<void> setProductAsOpen(LocalFridgeElement element) async {
    await this.alter_element_quantity(element, element.quantity - 1);
    LocalFridgeElement new_element = LocalFridgeElement(element.name, element.barcode, element.days_to_expiration, 1, DateTime.now().toString().substring(0, 10), element.color);
    await this.addElement(new_element);
  }

  Future<void> populateLocalFridge() async {
    this.fridge_elements = [];
    var data = [this.fridge_ID, this.fridge_ID];
    String retrieve_elements = DatabaseConnection.querySetupper(data, this.query_retrieve_fridge_elements);
    var results = await this.db.query(retrieve_elements);
    for (var element in results) {
      LocalFridgeElement new_element_to_add = LocalFridgeElement.id(element[0].toString(),
          element[1].toString(),
          element[2].toString(),
          element[3].toString(),
          element[4],
          element[5].toString().substring(0, 10),
          element[6].toString());
      this.fridge_elements.add(new_element_to_add);
    }
  }

  void reorder_elements_alphabetically_a_to_z() {
    this.fridge_elements.sort((a, b) => a.name.compareTo(b.name));
  }

  void reorder_elements_alphabetically_z_to_a() {
    this.fridge_elements.sort((a, b) => b.name.compareTo(a.name));
  }

  Future<void> alter_element_date(LocalFridgeElement element, String new_date) async {
    var data = [new_date, element.id];
    String modify_element_date = DatabaseConnection.querySetupper(data, this.query_modify_element_date);
    try {
      await this.db.query(modify_element_date);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error modifying element date: " + e.toString());
    }
    element.alterExpirationDate(new_date);
  }

  Future<void> alter_element_quantity(LocalFridgeElement element, int new_quantity) async {
    var data = [new_quantity.toString(), element.id, this.user.id, element.expiration_date];
    String modify_element_quantity = DatabaseConnection.querySetupper(data, this.query_modify_element_quantity);
    try {
      await this.db.query(modify_element_quantity);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error modifying element quantity: " + e.toString());
    }
    element.alterQuantity(new_quantity);
  }

}

class LocalDictionary {

  String query_retrieve_dictionary_elements = """(SELECT Prodotto.id,
  Prodotto.nome,
  Prodotto.barcode,
  Prodotto.giorniValidità
  FROM Prodotto
  LEFT JOIN Dispensa ON Dispensa.idDizionario = Prodotto.idDizionario
  LEFT JOIN Dizionario ON Dizionario.id = Prodotto.idDizionario
  WHERE Dispensa.id = ?)
  UNION
  (SELECT Prodotto.id,
  Prodotto.nome,
  Prodotto.barcode,
  Prodotto.giorniValidità
  FROM Prodotto
  RIGHT JOIN Dispensa ON Dispensa.idDizionario = Prodotto.idDizionario
  RIGHT JOIN Dizionario ON Dizionario.id = Prodotto.idDizionario
  WHERE Dispensa.id = ?);""";
  String query_insert_element = "INSERT INTO Prodotto (nome, barcode, giorniValidità, idDizionario) VALUES (\"?\", ?, ?, ?);";
  String query_remove_element = "DELETE FROM Prodotto WHERE nome = \"?\" AND barcode = ? AND giorniValidità = ? AND idDizionario = ?;";
  String query_get_dictionary_id = "SELECT idDizionario FROM Dispensa WHERE id = ?;";
  String query_modify_element_name = "UPDATE Prodotto SET nome = \"?\" WHERE nome = \"?\" AND barcode = ? AND giorniValidità = ? AND idDizionario = ?;";
  String query_modify_element_barcode = "UPDATE Prodotto SET barcode = ? WHERE nome = \"?\" AND barcode = ? AND giorniValidità = ? AND idDizionario = ?;";
  String query_alter_expiration_days = "UPDATE Prodotto SET giorniValidità = ? WHERE nome = \"?\" AND barcode = ? AND giorniValidità = ? AND idDizionario = ?;";
  String query_retrieve_product_id = "SELECT id FROM Prodotto WHERE nome = \"?\" AND barcode = ? AND giorniValidità = ? AND idDizionario = ?;";

  users.User user = users.User();
  String fridge_ID = "";
  String dictionary_ID = "";
  List<LocalDictionaryElement> dictionary_elements = [];
  DatabaseConnection db = DatabaseConnection();

  static final LocalDictionary _instance = LocalDictionary._internal();

  LocalDictionary._internal() {
    this.fridge_ID = this.user.fridgeID;
  }

  factory LocalDictionary() {
    return _instance;
  }

  Future<void> setupConnection() async {
    await this.db.connect();
    var data = [this.fridge_ID];
    String get_dictionary_id = DatabaseConnection.querySetupper(data, this.query_get_dictionary_id);
    var raw_dictionary_ID = await this.db.query(get_dictionary_id);
    this.dictionary_ID = raw_dictionary_ID[0][0].toString();
  }

  Future<void> addElement(LocalDictionaryElement new_element) async {
    var data = [new_element.name, new_element.barcode, new_element.days_to_expiration, this.dictionary_ID];
    String insert_element = DatabaseConnection.querySetupper(data, this.query_insert_element);
    try {
      await this.db.query(insert_element);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error inserting element: " + e.toString());
    }
    this.dictionary_elements.add(new_element);
  }

  Future<void> removeElement(LocalDictionaryElement element) async {
    var data = [element.name, element.barcode, element.days_to_expiration, this.dictionary_ID];
    String remove_element = DatabaseConnection.querySetupper(data, this.query_remove_element);
    try {
      await this.db.query(remove_element);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error removing element: " + e.toString());
    }
    this.dictionary_elements.remove(element);
  }

  void reorder_elements_alphabetically_a_to_z() {
    this.dictionary_elements.sort((a, b) => a.name.compareTo(b.name));
  }

  void reorder_elements_alphabetically_z_to_a() {
    this.dictionary_elements.sort((a, b) => b.name.compareTo(a.name));
  }

  List<LocalDictionaryElement> search_element_by_string_name(String actual_char) {
    List<LocalDictionaryElement> results = [];
    for (var element in this.dictionary_elements) {
      if (element.name.startsWith(actual_char)) {
        results.add(element);
      }
    }
    return results;
  }

  List<LocalDictionaryElement> search_element_by_barcode(String actual_barcode) {
    List<LocalDictionaryElement> results = [];
    for (var element in this.dictionary_elements) {
      if (element.barcode.startsWith(actual_barcode)) {
        results.add(element);
      }
    }
    return results;
  }

  Future<void> alter_element_name(LocalDictionaryElement element, String new_name) async {
    var data = [new_name, element.name, element.barcode, element.days_to_expiration, this.dictionary_ID];
    String modify_element_name = DatabaseConnection.querySetupper(data, this.query_modify_element_name);
    try {
      await this.db.query(modify_element_name);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error modifying element name: " + e.toString());
    }
    element.alterName(new_name);
  }

  Future<void> alter_element_barcode(LocalDictionaryElement element, String new_barcode) async {
    var data = [new_barcode, element.name, element.barcode, element.days_to_expiration, this.dictionary_ID];
    String modify_element_barcode = DatabaseConnection.querySetupper(data, this.query_modify_element_barcode);
    try {
      await this.db.query(modify_element_barcode);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error modifying element barcode: " + e.toString());
    }
    element.alterBarcode(new_barcode);
  }

  Future<void> alter_element_expiration_days(LocalDictionaryElement element, String new_expiration_days) async {
    var data = [new_expiration_days, element.name, element.barcode, element.days_to_expiration, this.dictionary_ID];
    String alter_expiration_days = DatabaseConnection.querySetupper(data, this.query_alter_expiration_days);
    try {
      await this.db.query(alter_expiration_days);
      this.user.fridgeEvent.sendUpdate();
    } catch (e) {
      print("Error modifying element expiration days: " + e.toString());
    }
    element.alterDaysToExpiration(new_expiration_days);
  }

  Future<void> populate_local_dictionary() async {
    this.dictionary_elements = [];
    var data = [this.fridge_ID, this.fridge_ID];
    String retrieve_elements = DatabaseConnection.querySetupper(data, this.query_retrieve_dictionary_elements);
    var results = await this.db.query(retrieve_elements);
    for (var element in results) {
      LocalDictionaryElement new_element_to_add = LocalDictionaryElement.id(element[0].toString(),
          element[1].toString(),
          element[2].toString(),
          element[3].toString());
      this.dictionary_elements.add(new_element_to_add);
    }
  }

  void registerFridgeEvent() {
    this.user.fridgeEvent.socket.on("fridgeEvent", (data) {
      this.populate_local_dictionary();
    });
  }

  Future<String> retrieveLocalDictionaryElementId(LocalDictionaryElement element) async {
    var data = [element.name, element.barcode, element.days_to_expiration, this.dictionary_ID];
    String retrieve_product_id = DatabaseConnection.querySetupper(data, this.query_retrieve_product_id);
    var results = await this.db.query(retrieve_product_id);
    return results[0][0].toString();
  }

}

class LocalDictionaryElement {

  String id = "";
  String name = "";
  String barcode = "";
  String days_to_expiration = "";

  LocalDictionaryElement(String new_name, String new_barcode, String new_days_to_expiration) {
    this.name = new_name;
    this.barcode = new_barcode;
    this.days_to_expiration = new_days_to_expiration;
  }

  LocalDictionaryElement.id(String new_id, String new_name, String new_barcode, String new_days_to_expiration) {
    this.id =  new_id;
    this.name = new_name;
    this.barcode = new_barcode;
    this.days_to_expiration = new_days_to_expiration;
  }

  void alterName(String new_name) {
    this.name = new_name;
  }

  void alterBarcode(String new_barcode) {
    this.barcode = new_barcode;
  }

  void alterDaysToExpiration(String new_days_to_expiration) {
    this.days_to_expiration = new_days_to_expiration;
  }

}

class LocalFridgeElement extends LocalDictionaryElement {

  int quantity = 0;
  String expiration_date = "";
  String color = "";

  LocalFridgeElement(String new_name, String new_barcode, String new_days_to_expiration, int new_quantity, String new_expiration_date, String new_color) : super(new_name, new_barcode, new_days_to_expiration) {
    this.quantity = new_quantity;
    this.expiration_date = new_expiration_date;
    this.color = new_color;
  }

  LocalFridgeElement.id(String new_id, String new_name, String new_barcode, String new_days_to_expiration, int new_quantity, String new_expiration_date, String new_color) : super.id(new_id, new_name, new_barcode, new_days_to_expiration) {
    this.quantity = new_quantity;
    this.expiration_date = new_expiration_date;
    this.color = new_color;
  }

  void alterQuantity(int new_quantity) {
    this.quantity = new_quantity;
  }

  void alterExpirationDate(String new_expiration_date) {
    this.expiration_date = new_expiration_date;
  }

  void alterColor(String new_color) {
    this.color = new_color;
  }

}
