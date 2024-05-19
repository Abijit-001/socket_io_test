import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;
  String sendMessageText = '';
  String receivedMessageText = '';

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  @override
  void dispose() {
    disconnectFromServer();
    super.dispose();
  }

  void connectToServer() {
    socket = IO.io(
      'ws://159.89.5.97:4000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setAuth({
            "token": "#&BdUxCenhTY3@#"
          })
          .build(),
    );

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.onConnectError((data) {
      print('Connection error: $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.on('NewOrder', (data) {
      // setState(() {
      //   receivedMessageText = data;
      // });
      print('Received message: ${data["data"]["contact_id"]}');
    });

    socket.connect();
  }

  void sendMessage(String message) {
    print('Sending message: $message');
    socket.emit('onPing', message);
  }

  void disconnectFromServer() {
    print('Disconnecting from server');
    socket.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Socket.IO Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Received message: $receivedMessageText'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      sendMessageText = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your message',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => sendMessage(sendMessageText),
                child: Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
