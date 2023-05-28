import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/models/device_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Test2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();

}
class _MyHomePageState extends State<MyHomePage> {
  final _fsc = FlutterSerialCommunication();
  TextEditingController textController = TextEditingController();
  bool isConnected = false;
  List<DeviceInfo> connectedDevices = [];
  DeviceInfo device = DeviceInfo();
  int baudRate = 115200;
  @override
  void initState() {
    super.initState();
    _fsc
        .getSerialMessageListener()
        .receiveBroadcastStream()
        .listen((event) {
      debugPrint("Received From Native:  $event");
    });

    _fsc
        .getDeviceConnectionListener()
        .receiveBroadcastStream()
        .listen((event) {
      setState(() {
        isConnected = event;
      });
    });
  }

  _getdevices() async{
   List<DeviceInfo> newConnectedDevices = await _fsc.getAvailableDevices();
   setState(() {
     connectedDevices = newConnectedDevices;
   });
 }
 _connect(DeviceInfo dev) async{
   bool isConnectionSuccess = await _fsc.connect(dev, 115200);
   debugPrint("Is Connection Success:  $isConnectionSuccess");
 }
 _disconnect() async{
   await _fsc.disconnect();
}
  void showToast(event) {
    Fluttertoast.showToast(
        msg: '$event',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.yellow
    );
  }
  Uint8List convertStringToUint8List(String str) {
    str = "hello";
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);
    return unit8List;
  }
_send() async {
  bool isMessageSent = await _fsc.write(Uint8List.fromList([11,18]));
  EventChannel eventChannel = _fsc.getSerialMessageListener();
  eventChannel.receiveBroadcastStream().listen((event) {
    showToast(event);
  });
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Serial Communication'),
        ),
        body: Center(
          child: Column(
            children: [
              Text("Is Connected: $isConnected"),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: _getdevices,
                child: const Text("Get All Connected Devices"),
              ),
              const SizedBox(height: 16.0),
              ...connectedDevices.asMap().entries.map((entry) {
                return Row(
                  children: [
                    Flexible(child: Text(entry.value.productName)),
                    const SizedBox(width: 16.0),
                    FilledButton(
                      onPressed: () {
                        _connect(entry.value);
                      },
                      child: const Text("Connect"),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: isConnected ? _disconnect : null,
                child: const Text("Disconnect"),
              ),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: isConnected ? _send: null,
                child: const Text("Send"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}