import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(FlutterBlueTooth());
}

class FlutterBlueTooth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return Scan_device();
            }
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text('Make sure that your device Bluetooth is on.', style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 25),),
                ),
              ),
            );
          }),
    );
  }
}

class Scan_device extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 100,
                    child: const Text('RSSI VALUE', style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    height: 40,
                    width: 170,
                    child: const Text('DEVICE NAME AND ID',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    height: 40,
                    width: 80,
                    child: const Text('DISTANCE',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  )
                ],
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: snapshot.data!.map(
                        (r) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: (){},
                            child: Text(r.rssi.toString())),
                        Column(
                          children: [
                            if(r.device.name == '')const Text('(Unknown Device)')
                            else Text(r.device.name),
                            Text(r.device.id.toString())
                          ],
                        ),
                        ElevatedButton(onPressed: (){},
                            // Actual calculation part for measuring diastance...
                            // Here, txPowelevel is taken as fixed value i.e, = -69
                            child: Text(pow(10, ((-69 - r.rssi)/(10 * 2))).abs().toStringAsFixed(3).toString())
                        )
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
            return FloatingActionButton(
                child: const Icon(Icons.refresh),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: const Duration(seconds: 4)));
        },
      ),
    );
  }
}