/* Classe che definisce gli oggetti fridgeEvent. Instaura una connessione con il
server node e, tramite il package socket.io-client, si mette in ascolto di eventi
che riguardano l'aggiornamento del database contenente i prodotti nella dispensa
condivisi con altri utenti. Sfrutta il pattern Singleton. */

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fridge_state.dart';

class FridgeEvent {

  /* LocalFridge _localFridge = LocalFridge();
  LocalShoppingCart _localShoppingCart = LocalShoppingCart();
  LocalDictionary _localDictionary = LocalDictionary(); */

  String _fridgeID = "";
  String _ipaddress = "";
  String _port = "";
  String _url = "";
  bool connected = false;
  bool processing_update = false; // credo ci sia un bug per cui l'evento di aggiornamento viene gestito molteplici volte, gestisco l'esecuzione solo se questo flag è false
  late IO.Socket socket;
  bool _update = false;
  BuildContext? context;

  static final FridgeEvent _instance = FridgeEvent._internal();

  /* Future<void> updateLocalData() async {
    _localFridge.dispose();
    _localShoppingCart.dispose();
    _localDictionary.dispose();
    await _localFridge.populateLocalFridge();
    await _localShoppingCart.populateLocalShoppingCart();
    await _localDictionary.populate_local_dictionary();
  } */

  factory FridgeEvent() {
    return _instance;
  }

  FridgeEvent._internal() {
    // this._ipaddress = "10.0.2.2";
    this._ipaddress = "";
    this._port = "";
    // this._port = "3000";
    this._fridgeID = "";
    this._url = "http://" + this._ipaddress + ":" + this._port;
    this.socket = IO.io(this._url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  void setIP(String ip) {
    this._ipaddress = ip;
    this._url = "http://" + this._ipaddress + ":" + this._port;
    this.socket = IO.io(this._url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    print("url is " + this._url);
  }

  void setPort(String port) {
    this._port = port;
    this._url = "http://" + this._ipaddress + ":" + this._port;
    this.socket = IO.io(this._url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    print("url is " + this._url);
  }

  /* funzione che si occupa di instaurare la connessione con il server node e di
  mettersi in ascolto di eventi che riguardano l'aggiornamento del database
   */
  Future<void> communicate() async {
    /* this.socket = IO.io(this._url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }); */

    socket.connect();

    socket.onConnect((_) {
      print("Connected");
      connected = true;
      // invia l'id del frigo al server node
      socket.emit("fridgeID", this._fridgeID);
    });

    socket.onConnectError((error) {
      print("Connection Error: $error");
    });

    socket.onDisconnect((_) {
      print("Disconnected");
    });

    socket.on("fridgeEvent", (data) async {
      getUpdate(processing_update);
      if (!processing_update) {
        processing_update = true;
        print("fridgeEvent received");
        // await updateLocalData();
        await Provider.of<TriggerUpdateModel>(context!, listen: false).updateOnDatabase();
        processing_update = false;
      }
    });

  }

 bool getUpdate(bool processing_update) {
    print("getting update while processing_update is $processing_update");
    return true;
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