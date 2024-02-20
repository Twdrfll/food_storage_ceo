import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../database_connection.dart';
import '../fridge_event.dart';

class InitialSetup extends StatefulWidget {
  @override
  _InitialSetupState createState() => _InitialSetupState();
}

class _InitialSetupState extends State<InitialSetup> {

  DatabaseConnection db = DatabaseConnection();
  FridgeEvent fe = FridgeEvent();

  String serverip = '';
  String serverport = '';

  late IO.Socket testsocket;

  List<bool> checks = [];

  bool nodeServerStatus = false;
  bool isLoaded = false;

  TextEditingController mysqlIpController = TextEditingController();
  TextEditingController nodeIpController = TextEditingController();
  TextEditingController mysqlPortController = TextEditingController();
  TextEditingController nodePortController = TextEditingController();

  @override
  initState() {
    super.initState();
    db.connect().then((value) {
      print(checks);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Test dei valori di default...',),
        duration: Duration(seconds: 1),
      ));
      if (value) {
        checks.add(value);
        print(checks);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Database raggiunto!',),
          duration: Duration(seconds: 1),
        ));
        print('Connected to the database');
      } else {
        print(checks);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Qualcosa non va con il database MySQL'),
          duration: Duration(seconds: 1),
        ));
        print('Error while trying to connect to the database');
      }
      if (checks.length == 1) {
        print(checks);
        serverTest('10.0.2.2', '3000').then((value) {
          checks.add(value);
          if (value) {
            print(checks);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Server raggiunto!',),
              duration: Duration(seconds: 1),
            ));
            print('Connected to the server');
          } else {
            print(checks);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Qualcosa non va con il server Node.js'),
              duration: Duration(seconds: 1),
            ));
            print('Error while trying to connect to the server');
          }
          if (checks.length == 2) {
            if (checks[0] && checks[1]) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        });
      }
      // se i valori di check sono entrambi true, allora possiamo andare avanti con l'app
    });
  }

  Future<bool> serverTest(String servIP, String servPort) async {

    serverip = servIP; // da mettere default 10.0.2.2
    serverport = servPort; // idem ma 3000

    Completer<bool> completer = Completer<bool>();

    testsocket = IO.io('http://' + serverip + ':' + serverport, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    testsocket.connect();

    testsocket.onConnect((_) {
      fe.setIP(serverip);
      fe.setPort(serverport);
      Future.delayed(Duration(seconds: 3), () {
        if(!completer.isCompleted) {
          testsocket.disconnect();
          completer.complete(true);
        }
      });
    });

    testsocket.onConnectError((data) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }

  Icon getIcon() {
    if (isLoaded) {
      return Icon(Icons.lock_clock);
    } else {
      return Icon(Icons.arrow_forward);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Center(child: Text('Setup progetto The Fridge')),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Questo setup serve a impostare IP e porta del database MySQL e del server Node.js.'
                    '\nSe ci troviamo fermi qui è perché i valori di default non sono utilizzabili in questo ambiente.'
                    '\n\nQuesta schermata è presente solo in questo stato, non fa parte dell\'app prototipata.'
                    '\n\nDefault IP MySQL e Node: 10.0.2.2; default port Node: 3000; default port MySQL: 8889.'
                    '\n\nAttenzione! MySQL user: root - Password: root - DB name: ProvaTheFridge',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: mysqlIpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'IP del Database MySQL',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: nodeIpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'IP del server Node.js',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: mysqlPortController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Porta Database MySQL',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: nodePortController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Porta Server Node.js',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checks.clear();
          if (mysqlIpController.text.isEmpty || nodeIpController.text.isEmpty || mysqlPortController.text.isEmpty || nodePortController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Inserire tutti i valori'),
            ));
            return;
          }
          db.setHostname(mysqlIpController.text);
          db.setPort(int.parse(mysqlPortController.text));
          db.connect().then((value) {
            checks.add(value);
            if (value) {
              print('Connected to the database');
              setState(() {
                isLoaded = true;
              });
            } else {
              print('Error while trying to connect to the database');
              // mostro un toast con l'errore
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Qualcosa non va con il database MySQL'),
              ));
            }
          });
          serverTest(nodeIpController.text, nodePortController.text).then((value) {
            checks.add(value);
            if (value) {
              print('Connected to the server');
              setState(() {
                isLoaded = true;
              });
            } else {
              print('Error while trying to connect to the server');
              // mostro un toast con l'errore
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Qualcosa non va con il server Node.js'),
              ));
            }
            if (checks.length == 2) {
              if (checks[0] && checks[1]) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            }
          });
        },
        child: getIcon(),
      ),
    );
  }
}