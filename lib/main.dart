import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xunil_blue_connect/xunil_blue_connect.dart';
import 'package:xunil_blue_connect/utils/status.dart';
import 'device.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Basic bluetooth management'),
          ),
          body: const Center(
            child: MainBody(),
          ),
        ),
      ),
    );
  }
}

class MainBody extends StatefulWidget {
  const MainBody({Key? key}) : super(key: key);

  @override
  State<MainBody> createState() => _BodyState();
}

class _BodyState extends State<MainBody> {
  bool _isBluetoothAvailable = false;
  bool _isLocationAvailable = false;
  bool _isLocationOn = false;
  List<BluetoothDevice>? devices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.storage
    ];
    if (await Permission.storage.isDenied ||
        await Permission.bluetooth.isDenied ||
        await Permission.bluetoothScan.isDenied ||
        await Permission.bluetoothConnect.isDenied ||
        await Permission.bluetoothAdvertise.isDenied ||
        await Permission.location.isDenied) {
      final statuses = await permissions.request();

      setState(() {
        _isBluetoothAvailable = statuses[Permission.bluetooth]!.isGranted &&
            statuses[Permission.bluetoothScan]!.isGranted &&
            statuses[Permission.bluetoothConnect]!.isGranted &&
            statuses[Permission.bluetoothAdvertise]!.isGranted;

        _isLocationAvailable = statuses[Permission.location]!.isGranted;
      });
    }
    var isBlue = await blueConnect.isBluetoothAvailable();
    setState(() {
      _isBluetoothAvailable = isBlue;
    });
    if(!_isBluetoothAvailable){
      Fluttertoast.showToast(msg: "Please Turn on you Bluetooth");
    }
  }

  XunilBlueConnect blueConnect = XunilBlueConnect();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bluetooth', style: TextStyle(
                      fontSize: 18,
                    ),),
                    ElevatedButton(
                        onPressed: () async{
                          var isBlue = await blueConnect.isBluetoothAvailable();
                                  setState(() {
                                    _isBluetoothAvailable = isBlue;
                                  });
                                  if(!_isBluetoothAvailable){
                                    Fluttertoast.showToast(msg: "Please Turn on you Bluetooth");
                                  }
                        },
                        child: Text("${_isBluetoothAvailable ? 'ON' : 'OFF'}"))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Location' ,style: TextStyle(
                  fontSize: 18,
                ),),
                    ElevatedButton(
                        onPressed: () async{

                                  var isLocation = await blueConnect.checkSettingLocation();
                                  await blueConnect.bluetoothSetEnable();
                                  setState(() {
                                    _isLocationOn = isLocation;
                                  });
                                  if(!_isLocationOn) {
                                    Fluttertoast.showToast(msg: "Please Turn on the location");
                                  }
                        },
                        child: Text("${_isLocationAvailable ? 'ON' : 'OFF'}"))
                  ],
                ),
              ),
              // Text(
              //     'Location permission is ${_isLocationAvailable ? 'ON' : 'OFF'}'),
              // Text('Location setting is ${_isLocationOn ? 'ON' : 'OFF'}'),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     ElevatedButton(
          //       style: ButtonStyle(
          //         backgroundColor: MaterialStateProperty.all(
          //             _isBluetoothAvailable ? Colors.lightGreen : Colors.blue),
          //       ),
          //       onPressed: () async {
          //         //call the function but as async
          //         //but if function return null means the device doesn't support bluetooth
          //         var isBlue = await blueConnect.isBluetoothAvailable();
          //         setState(() {
          //           _isBluetoothAvailable = isBlue;
          //         });
          //       },
          //       child: const Text('Check Bluetooth'),
          //     ),
          //     ElevatedButton(
          //       style: ButtonStyle(
          //           backgroundColor: MaterialStateProperty.all(
          //               _isLocationOn ? Colors.lightGreen : Colors.blue)),
          //       onPressed: () async {
          //         //call the function but as async
          //         //but if function return null means the device's location is off
          //         var isLocation = await blueConnect.checkSettingLocation();
          //
          //         setState(() {
          //           _isLocationOn = isLocation;
          //         });
          //       },
          //       child: const Text('Check Location'),
          //     )
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await blueConnect.startDiscovery();
                    setState(() {
                      isLoading = true;
                    });
                    Timer(const Duration(seconds: 13), () async {
                      await blueConnect.stopDiscovery();
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                  child: const Text('Search For devices', style: TextStyle(
                    fontSize: 18,
                  ),),
                ),
                isLoading
                    ? Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.blue),
                        child:
                            const CircularProgressIndicator(color: Colors.white,))
                    : InkWell(
                  onTap: () async {
                    await blueConnect.startDiscovery();
                    setState(() {
                      isLoading = true;
                    });
                    Timer(const Duration(seconds: 13), () async {
                      await blueConnect.stopDiscovery();
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.search,color: Colors.white,),
                        )),
                )
              ],
            ),
          ),
          // if (isLoading)
          //   const LinearProgressIndicator(color: Colors.orangeAccent),
          StreamBuilder(
            stream: blueConnect.listenStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var STATUS = jsonDecode(snapshot.data as String);

                //for status pairing
                switch (STATUS['STATUS_PAIRING']) {
                  case PairedStatus.PAIRED:
                    print(PairedStatus.PAIRED);

                    break;
                  case PairedStatus.PAIRING:
                    print(PairedStatus.PAIRING);
                    break;
                  case PairedStatus.PAIRED_NONE:
                    print(PairedStatus.PAIRED_NONE);
                    break;
                  case PairedStatus.UNKNOWN_PAIRED:
                    print(PairedStatus.UNKNOWN_PAIRED);
                    break;
                }

                //for status connecting
                switch (STATUS['STATUS_CONNECTING']) {
                  case ConnectingStatus.STATE_CONNECTED:
                    print(STATUS['MAC_ADDRESS']);
                    print(ConnectingStatus.STATE_CONNECTED);
                    break;
                  case ConnectingStatus.STATE_DISCONNECTED:
                    print(STATUS['MAC_ADDRESS']);
                    print(ConnectingStatus.STATE_DISCONNECTED);
                    break;
                }

                //for status discovery
                switch (STATUS['STATUS_DISCOVERY']) {
                  case DiscoveryStatus.STARTED:
                    print(DiscoveryStatus.STARTED);
                    break;
                  case DiscoveryStatus.FINISHED:
                    print(DiscoveryStatus.FINISHED);
                    break;
                }
              }
              return const SizedBox();
            },
          ),
          StreamBuilder(
            stream: blueConnect.listenDeviceResults,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var device = BluetoothDevice.fromJson(
                    jsonDecode(snapshot.data as String));

                bool isEmpty = devices!
                    .where(
                      (localAddress) => localAddress.address == device.address,
                    )
                    .isEmpty;

                if (isEmpty) {
                  devices?.add(device);
                }
                return devices!.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: devices!.length,
                          padding: const EdgeInsets.all(10.0),
                          itemBuilder: (context, index) {
                            final device = devices![index];
                            if (device.name == null ||
                                device.name!.isEmpty ||
                                device.name == "null") {
                              // Don't show devices with null or empty names
                              return const SizedBox();
                            }

                            return Card(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration : BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue
                                          ),
                                          child: Icon(Icons.bluetooth,color: Colors.white,),
                                        ),
                                        SizedBox(width: 10,),
                                        Text("${devices![index].name!}")
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {

                                        if(devices![index].isPaired! == "PAIRED")
                                          {
                                            print("connect");
                                            await blueConnect.connect(
                                              macAddress: devices![index].address!,
                                            );

                                          }
                                        else
                                          {
                                            print("pair");
                                            await blueConnect.pair(
                                              macAddress: devices![index].address!,
                                            );
                                          }


                                      },
                                      child: Text(
                                        devices![index].isPaired! == "PAIRED"
                                            ? "Connect"
                                            : "  Pair  ",
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            );
                            return ListTile(
                              onTap: () async {
                                await blueConnect.connect(
                                  macAddress: devices![index].address!,
                                );
                              },
                              title: Text(
                                  "${devices![index].name!} (${devices![index].aliasName!})"),
                              subtitle: Text(devices![index].address!),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 30.0,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          devices![index].isPaired! == "PAIRED"
                                              ? Colors.lightGreen
                                              : Colors.blue,
                                        ),
                                      ),
                                      onPressed: () async {
                                        await blueConnect.pair(
                                          macAddress: devices![index].address!,
                                        );
                                      },
                                      child: Text(
                                        devices![index].isPaired! == "PAIRED"
                                            ? "Connect"
                                            : "  Pair  ",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  if (devices![index].isPaired! == "PAIRED")
                                    SizedBox(
                                      width: 30.0,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.redAccent[400]),
                                        ),
                                        onPressed: () async {
                                          await blueConnect.disconnect();
                                        },
                                        child: const Text("Disconnect"),
                                      ),
                                    ),
                                  if (devices![index].isPaired! == "PAIRED")
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                  if (devices![index].isPaired! == "PAIRED")
                                    SizedBox(
                                      width: 30.0,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blueGrey),
                                        ),
                                        onPressed: () async {
                                          await blueConnect.write(
                                            data:
                                                "World is something, like something, yeah i know",
                                            autoConnect: true,
                                          );
                                        },
                                        child: const Text("Write"),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox();
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
