import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:app_settings/app_settings.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  var list = [];
  String searchTitle = "Search Devices";

  void _findDevices() async {
    setState(() {
      searchTitle = "Searching for devices";
    });
    try {
      var isOn = await flutterBlue.isOn;

      if (isOn == false) {
        Get.defaultDialog(
            title: "Info",
            content: Text("Open Bluetooth"),
            onConfirm: () {
              AppSettings.openBluetoothSettings();
              Get.back();
            },
            onCancel: () {},
            textConfirm: "Open",
            confirmTextColor: Colors.white);
        return;
      }

      print("Testing => " + isOn.toString());
      // Start scanning

      flutterBlue.startScan(timeout: Duration(seconds: 10));
      if (flutterBlue.isScanning == false) {
        searchTitle = "No Devices Found";
      }

// Listen to scan results

      var subscription = flutterBlue.scanResults.listen((results) {
        if (!list.isEmpty) {
          list.clear();
        }
        for (ScanResult r in results) {
          if (r.device.name == "" || r.device.name == null) return;
          list.add(r.device.name);
          print("Device Name => " + r.device.name.toString());
          //print('${r.device.name} found! rssi: ${r.rssi}');
        }
        setState(() {
          if (list.length == 0) {}
        });
      });
    } catch (e) {
      print(e);
    }

// Stop scanning
    flutterBlue.stopScan();
    setState(() {});
  }

  Future<bool> _checkDeviceBluetoothIsOn() async {
    return await flutterBlue.isOn;
  }

  void connectWithDevice(deviceName) async {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.name == deviceName) {
          r.device.connect();

          return;
        }
        // print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

// Stop scanning
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            list.length == 0
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(searchTitle),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      if (!list.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                connectWithDevice(list[index\])
                              },
                              splashColor: Colors.lightBlueAccent,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: Text(
                                  list[index],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              height: 1,
                              color: Colors.grey,
                            )
                          ],
                        );
                      } else
                        return Text("No Devices Found.");
                    }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findDevices,
        tooltip: 'Increment',
        child: const Icon(Icons.bluetooth),
      ),
    );
  }
}
