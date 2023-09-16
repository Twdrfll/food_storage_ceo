/* Classe che definisce gli oggetti fridgeEvent. Instaura una connessione con il
server node e, tramite il package socket.io-client, si mette in ascolto di eventi
che riguardano l'aggiornamento del database contenente i prodotti nella dispensa
condivisi con altri utenti. Sfrutta il pattern Singleton. */

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class FridgeEvent {
  String _fridgeID = ""; // ID del frigo, da definire altrove
  String _ipaddress = "";
  String _port = "";
  String _url = "";
  late IO.Socket socket;

  static final FridgeEvent _instance = FridgeEvent._internal();

  factory FridgeEvent() {
    return _instance;
  }

  FridgeEvent._internal() {
    this._ipaddress = "localhost";
    this._port = "3000";
    this._fridgeID = "";
    this._url = "http://" + this._ipaddress + ":" + this._port;
    this.socket = IO.io(this._url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  /* funzione che si occupa di instaurare la connessione con il server node e di
  mettersi in ascolto di eventi che riguardano l'aggiornamento del database
   */
  Future<void> communicate() async {
    /* this.socket = IO.io(this._url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }); */

    await socket.connect();

    socket.onConnect((_) {
      print("Connected");
      // invia l'id del frigo al server node
      socket.emit("fridgeID", this._fridgeID);
    });

    socket.onConnectError((error) {
      print("Connection Error: $error");
    });

    socket.onDisconnect((_) {
      print("Disconnected");
    });

    socket.on("fridgeEvent", (data) {
      print(data);
      /* qui va inserita la funzione che aggiorna i dati locali prendendoli dal
      database remoto */
    });

  }

  void setFridgeID(String ID) {
    this._fridgeID = ID;
  }

  // invia un messaggio di update al server node
  void sendUpdate() {
    print("sending update");
    this.socket.emit("fridgeUpdate", this._fridgeID);
  }

  // interrompe la comunicazione con il server node
  void stopCommunication() {
    if(this.socket.connected) {
      this.socket.disconnect();
    }
  }
}