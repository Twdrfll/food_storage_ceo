/* classe che sfrutta il pattern Singleton.
Definisce il dizionario, composto da oggetti DictionaryElement.
Quando viene inserito un barcode in fase di aggiunta di un prodotto alla
dispensa, viene cercato nel dizionario se è già presente un elemento con lo
stesso barcode da cui prendere il nome precedentemente inserito.
 */
class Dictionary {

  List<DictionaryElement> dictionary_list = [];
  static final Dictionary _dictionary_instance = Dictionary._internal();

  factory Dictionary() {
    return _dictionary_instance;
  }

  Dictionary._internal();

  // la funzione, dato un barcode, ritorna il nome associato nel dizionario.
  String getName(int bc) {
    for (var element in this.dictionary_list) {
      if (element.barcode.compareTo(bc) == 0) {
        return element.name;
      }
    }
    return "";
  }

  // la funzione, dato un nome, ritorna il barcode associato nel dizionario.
  int getBarcode(String nome) {
    for (var element in this.dictionary_list) {
      if (element.name.compareTo(nome) == 0) {
        return element.barcode;
      }
    }
    return 0;
  }

  // la funzione, dato un oggetto DictionaryElement, controlla se è presente nel dizionario.
  bool checkPresence(DictionaryElement nuovo) {
    for (var element in this.dictionary_list) {
      if ((element.name == nuovo.name) && (element.barcode == nuovo.barcode)) {
        return true;
      }
    }
    return false;
  }

  /* la funzione, dato un oggetto DictionaryElement, controlla se è presente nel
  dizionario un oggetto con ugual nome o barcode, e, se presente, aggiorna, in
  quest'ultimo, il nome o il barcode usando quelli dell'oggetto passato come
  parametro.
   */
  void checkAndUpdate(DictionaryElement nuovo) {
    for (var element in this.dictionary_list) {
      if (element.name.compareTo(nuovo.name) == 0) {
        if (element.barcode.compareTo(nuovo.barcode) != 0) {
          element.barcode = nuovo.barcode;
        }
      } else if (element.barcode.compareTo(nuovo.barcode) == 0) {
        if (element.name.compareTo(nuovo.name) != 0) {
          element.name = nuovo.name;
        }
      }
    }
  }

  /* la funzione, dato un oggetto DictionaryElement, lo aggiunge al dizionario
  se non è già presente.
   */
  void addElement(DictionaryElement nuovo) {
    this.checkAndUpdate(nuovo);
    if (this.checkPresence(nuovo) != true) {
      this.dictionary_list.add(nuovo);
    }
  }

}

/* classe che definisce gli oggetti DictionaryElement.
Ciascun oggetto qui definito è composto da un nome e un barcode, e viene creato
al momento in cui un nuovo prodotto viene aggiunto in dispensa, se questo ha un
barcode, con il fine di essere aggiunto al dizionario, se non presente o se
inserito in precedenza con nome o barcode differente.
 */
class DictionaryElement {

  String name = "";
  int barcode = 0;

  DictionaryElement(String nome, int bc) {
    this.name = nome;
    this.barcode = bc;
  }

}

// test
/* void main() {
  Dictionary dict = Dictionary();
  Dictionary dictBoo = Dictionary();
  DictionaryElement A = DictionaryElement("prova", 1);
  DictionaryElement B = DictionaryElement("provaa", 2);
  DictionaryElement C = DictionaryElement("provaaa", 3);
  dict.dictionary_list.addAll([A, B]);
  dict.dictionary_list.add(C);
  print(dict.checkPresence(A));
  DictionaryElement Boo = DictionaryElement("provaaa", 4);
  DictionaryElement Booo = DictionaryElement("provaa", 5);
  print(dict.checkPresence(Booo));
  dict.checkAndUpdate(Boo);
  print(dict.checkPresence(Boo));
  for (var element in dict.dictionary_list) {
    print(element.name + " " + element.barcode.toString());
  }
  for (var element in dictBoo.dictionary_list) {
    print(element.name + " " + element.barcode.toString());
  }
  dict.addElement(Booo);
  for (var element in dictBoo.dictionary_list) {
    print(element.name + " " + element.barcode.toString());
  }

} */