// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gaslevel/gas_level_page.dart';
import 'package:gaslevel/widgets/device_item.dart';
import 'package:gaslevel/widgets/drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(FlutterBlueApp(
    sharedPrefInstance: prefs,
  ));
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key, required this.sharedPrefInstance})
      : super(key: key);
  final SharedPreferences sharedPrefInstance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.blueGrey,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen(
                sharedPrefInstance: sharedPrefInstance,
              );
            } else if (state == BluetoothState.off) {
              return BluetoothOffScreen(state: state);
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0C9869),
              ),
            );
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Lottie.asset('assets/bluetooth-connecting.json'),
            Text(
              'Your Bluetooth Adapter is Off.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF0C9869))),
              child: const Text('TURN ON'),
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.instance.turnOn()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key, required this.sharedPrefInstance})
      : super(key: key);
  final SharedPreferences sharedPrefInstance;

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  void initState() {
    FlutterBluePlus.instance.stopScan().then((value) {setState(() {});});
    checkBluetoothPermission();
    publicFlag = widget.sharedPrefInstance.getBool('flag');
    image = Image.asset(
      'assets/new-photo.jpg',
    );
    super.initState();
  }

  late Image image;
  bool? publicFlag;

  @override
  void didChangeDependencies() {
    precacheImage(image.image, context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    disconnect();
    timer.cancel();
    FlutterBluePlus.instance.stopScan();
    super.dispose();
  }

  disconnect() async {
    for (var element in validDevicesList) {
      await element.disconnect();
    }
  }

  late Timer timer;

  checkBluetoothPermission() {
    bool isGrant;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      isGrant = await Permission.bluetoothConnect.status.isGranted;
      if (isGrant) {
        t.cancel();
        setState(() {});
      }
    });
  }

  connectToDevice(BluetoothDevice bluetoothDevice) async {
    await bluetoothDevice.connect(autoConnect: true);
    setState(() {});
  }

  List<BluetoothDevice> validDevicesList = [];
  List<Widget> deviceItemList = [];

  @override
  Widget build(BuildContext context) {
    print('builddddd1111');

    return WillPopScope(
      onWillPop: () async {
        await disconnect();
        return true;
      },
      child: Scaffold(
          drawerScrimColor: Colors.transparent,
          drawer: const DrawerWidget(),
          backgroundColor: Colors.white.withOpacity(0.93),
          appBar: AppBar(
            centerTitle: true,
            title: SizedBox(
              width: 120,
              child: Center(
                child: Image.asset('assets/Gaslevel-logoborder.png'),
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.7),
            iconTheme: const IconThemeData(
              color: Color(0xFF0C9869),
            ),
          ),
          body: RefreshIndicator(
            color: const Color(0xFF0C9869),
            onRefresh: () async {
              validDevicesList.clear();
              deviceItemList.clear();
              print('flagggggggg $publicFlag');
              setState(() {});
            },
            child: ListView(
              children: [
                image,
                FutureBuilder<List<BluetoothDevice>>(
                  initialData: [],
                  future: FlutterBluePlus.instance.connectedDevices,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<BluetoothDevice>>
                          connectedDevicesSnapshot) {
                    validDevicesList.clear();
                    deviceItemList.clear();
                    print('test1 ${connectedDevicesSnapshot.data}');
                    print('test2 ${connectedDevicesSnapshot.connectionState}');
                    if (connectedDevicesSnapshot.hasData &&
                        connectedDevicesSnapshot.data!.isNotEmpty &&
                        connectedDevicesSnapshot.connectionState ==
                            ConnectionState.done) {
                      print('conected ${connectedDevicesSnapshot.data}');
                      for (int i = 0;
                          i < connectedDevicesSnapshot.data!.length;
                          i++) {
                        if (connectedDevicesSnapshot.data![i].name != '' &&
                            connectedDevicesSnapshot.data![i].name
                                .startsWith('GASLEVEL')) {
                          validDevicesList.add(connectedDevicesSnapshot.data![i]);
                          deviceItemList.add(DeviceItem(
                            update: (){
                              setState(() {});
                            },
                              bluetoothDevice: validDevicesList[i],
                              flag: publicFlag ?? false,
                              deviceName: validDevicesList[i].name,
                              isConnected: true,
                              openOnTap: ()async {
                               await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => GasLevelPage(
                                          device: validDevicesList[i])),
                                );
                              },
                              disconnectOnTap: () async {
                                await validDevicesList[i].disconnect();
                                var pref =
                                    await SharedPreferences.getInstance();
                                pref.setBool('flag', false);
                                publicFlag = false;
                                // Future.delayed(const Duration(seconds: 1), () {
                                print('jjjjjjjjjjjjj');
                                Future.delayed(Duration(seconds: 4),(){
                                  setState(() {});
                                });
                                // });
                              },
                              connectOnTap: () {},
                            ),);
                        }
                      }
                      print('dddd ${deviceItemList.length}');
                    }
                    if (connectedDevicesSnapshot.connectionState ==
                        ConnectionState.done) {
                      return FutureBuilder<dynamic>(
                        future: FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 2)),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          print('test second future builder ${snapshot.data}');
                          if (snapshot.hasData || snapshot.connectionState==ConnectionState.done) {
                            FlutterBluePlus.instance.stopScan();
                          }
                          return StreamBuilder<List<ScanResult>>(
                            initialData: [],
                            stream: FlutterBluePlus.instance.scanResults,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ScanResult>> scanResult) {
                              if(scanResult.hasData) {
                                if (scanResult.data!.isNotEmpty) {
                                  print(
                                      'scannnnn resultttt ${scanResult.data}');
                                  for (var element in scanResult.data!) {
                                    if (element.device.name != '' &&
                                        element.device.name
                                            .startsWith('GASLEVEL')) {
                                      if (validDevicesList.isNotEmpty) {
                                        List<BluetoothDevice> addToList = [];
                                        addToList.clear();
                                        for (var element1 in validDevicesList) {
                                          // if (element1.id != element.device.id && element1.name!=element.device.name&& !validDevicesList.contains(element.device)) {
                                          if (!validDevicesList
                                              .contains(element.device)) {
                                            // if(flag==true){
                                            // connectToDevice(element.device);
                                            // }
                                            addToList.add(element.device);
                                            deviceItemList.add(
                                              DeviceItem(
                                                update: (){
                                                  setState(() {});
                                                },
                                                bluetoothDevice: element.device,
                                                flag: publicFlag ?? false,
                                                deviceName: element.device.name,
                                                isConnected: false,
                                                openOnTap: () {},
                                                disconnectOnTap: () {},
                                                connectOnTap: () async {
                                                  print('conect1 on tap check');
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 3),
                                                          () async {
                                                        var pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                        var flag =
                                                        pref.getBool('flag');
                                                        if (flag == false) {
                                                          setState(() {});
                                                        }
                                                      });

                                                  await element.device.connect(
                                                    autoConnect: true,
                                                  );
                                                  var pref = await SharedPreferences.getInstance();
                                                  pref.setBool('flag', true);
                                                  publicFlag = true;
                                                  await Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        GasLevelPage(
                                                          device: element
                                                              .device,
                                                        ),
                                                  ),);
                                                  setState(() {});

                                                },
                                              ),
                                            );
                                          }
                                        }
                                        if (addToList.length > 0) {
                                          addToList.forEach((element) {
                                            validDevicesList.add(element);
                                          });
                                        }
                                      } else {
                                        if (publicFlag == true) {
                                          connectToDevice(element.device);
                                        }
                                        validDevicesList.add(element.device);
                                        deviceItemList.add(DeviceItem(
                                          update: (){
                                            setState(() {});
                                          },
                                          bluetoothDevice: element.device,
                                          flag: publicFlag ?? false,
                                          deviceName: element.device.name,
                                          // isConnected:flag==true?true: false,
                                          isConnected: false,
                                          openOnTap: () {},
                                          disconnectOnTap: () {},
                                          connectOnTap: () async {
                                            print('conect on tap check');
                                            Future.delayed(const Duration(seconds: 3),
                                                    () async {
                                                  var pref = await SharedPreferences
                                                      .getInstance();
                                                  var flag = pref.getBool(
                                                      'flag');
                                                  print('flaggss $flag');
                                                  if (flag == false ||
                                                      flag == null) {
                                                    setState(() {});
                                                  }
                                                });
                                            await element.device.connect(
                                              autoConnect: true,
                                            );
                                            var pref = await SharedPreferences
                                                .getInstance();
                                            pref.setBool('flag', true);
                                            publicFlag = true;
                                            //TOdo
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    GasLevelPage(
                                                      device: element.device,
                                                    ),
                                              ),
                                            );
                                            setState(() {});
                                          },
                                        ));
                                      }
                                    }
                                  }

                                }
                              }

                              return StreamBuilder<bool>(
                                  stream: FlutterBluePlus.instance.isScanning,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<bool> isScanning) {
                                    print('is cannninnng ${isScanning.data}');
                                    if (isScanning.data!=null) {
                                      if (isScanning.data!) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF0C9869),
                                            ));
                                      } else  {
                                        if (deviceItemList.length==0) {
                                          return SizedBox(
                                            height: (MediaQuery.of(context)
                                                .size
                                                .height /
                                                2) *
                                                1.5,
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: const [
                                                Spacer(),
                                                Expanded(
                                                  child: Text(
                                                    'No GASLEVEL device found!\n\nMake sure device is connected and Refresh screen',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return GridView(
                                            shrinkWrap: true,
                                            physics:
                                            const ClampingScrollPhysics(),
                                            gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1,
                                              childAspectRatio: 3,
                                            ),
                                            children: deviceItemList,
                                          );
                                        }
                                      }
                                    }
                                    return const CircularProgressIndicator(
                                      color: Color(0xFF0C9869),
                                    );
                                  });
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          )),
    );
  }
}

