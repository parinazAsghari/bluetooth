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
  String? lastDeviceId;
  @override
  void initState() {
    FlutterBluePlus.instance.stopScan().then((value) {setState(() {});});
    checkBluetoothPermission();

    if(widget.sharedPrefInstance.getKeys().toList().isNotEmpty){
      List<String?> keyList= widget.sharedPrefInstance.getKeys().toList();
      if(keyList.isNotEmpty){
        for (var element in keyList) {
          if(widget.sharedPrefInstance.get(element!)==3){
            widget.sharedPrefInstance.setInt(element, 2);
          }
        }
      }

    }

    // publicFlag = widget.sharedPrefInstance.getBool('flag');
    // lastDeviceId = widget.sharedPrefInstance.getString('lastDeviceId');
    image = Image.asset(
      'assets/new-photo.jpg',
    );
    super.initState();
  }

  late Image image;
  // String? publicFlag;

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
      if(widget.sharedPrefInstance.getInt('${element.id}')==3){
        widget.sharedPrefInstance.setInt('${element.id}', 2);
        // print('handy disconnect ${widget.sharedPrefInstance.getInt('${element.id}')}');
      }
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

  Future<void> connectToDevice(BluetoothDevice bluetoothDevice) async {
    await bluetoothDevice.connect(autoConnect: true);
    // print('handy connect');
    // var instance =  await SharedPreferences.getInstance();
   // instance.setInt('${bluetoothDevice.id}', 3);
   // instance.setString('lastDeviceId', '${bluetoothDevice.id}');
    // setState(() {});
  }

  List<BluetoothDevice> validDevicesList = [];
  List<Widget> deviceItemList = [];

  @override
  Widget build(BuildContext context) {
    print('builddddd1111');
    lastDeviceId =widget.sharedPrefInstance.getString('lastDeviceId');
    print('last device is ${lastDeviceId}');

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
              // print('flagggggggg $publicFlag');
              setState(() {});
            },
            child: ListView(
              children: [
                image,
                FutureBuilder<List<BluetoothDevice>>(
                  initialData: [],
                  future: FlutterBluePlus.instance.connectedDevices,
                  builder: (context, AsyncSnapshot<List<BluetoothDevice>> connectedDevicesSnapshot) {
                    validDevicesList.clear();
                    deviceItemList.clear();
                    print('test1 ${connectedDevicesSnapshot.data}');
                    print('test2 ${connectedDevicesSnapshot.connectionState}');
                    if (connectedDevicesSnapshot.hasData && connectedDevicesSnapshot.data!.isNotEmpty && connectedDevicesSnapshot.connectionState == ConnectionState.done) {
                      print('conected ${connectedDevicesSnapshot.data}');
                      for (int i = 0; i < connectedDevicesSnapshot.data!.length; i++) {
                        if (connectedDevicesSnapshot.data![i].name != '' && connectedDevicesSnapshot.data![i].name.startsWith('GASLEVEL')) {
                         // List<String>? flag = widget.sharedPrefInstance.getStringList('${connectedDevicesSnapshot.data![i].id}');
                         // if(flag!=null){
                         //   publicFlag = flag.first;
                         // }
                          bool? stateThreeExist;
                          List<dynamic?> value=[];
                          value.clear();
                          if(widget.sharedPrefInstance.getKeys().toList().isNotEmpty){
                            List<String?> keyList= widget.sharedPrefInstance.getKeys().toList();
                            if(keyList.isNotEmpty){
                              for (var element in keyList) {
                                value.add(widget.sharedPrefInstance.get(element!));
                              }
                              value.forEach((element) {
                                if(element==3){
                                  stateThreeExist = true;
                                }
                              });
                            }

                          }
                          if(lastDeviceId != connectedDevicesSnapshot.data![i].id.toString() && stateThreeExist==true || lastDeviceId=='' && stateThreeExist!=true
                              || lastDeviceId!= connectedDevicesSnapshot.data![i].id.toString() && stateThreeExist!=true){
                            connectedDevicesSnapshot.data![i].disconnect();
                            validDevicesList.add(connectedDevicesSnapshot.data![i]);
                            deviceItemList.add(DeviceItem(
                              sharedPreferences: widget.sharedPrefInstance,
                              update: (){
                                setState(() {});
                              },
                              bluetoothDevice: validDevicesList[i],
                              // flag:flag?.first ,
                              deviceName: validDevicesList[i].name,
                              isConnected: false,
                              openOnTap: () {},
                              disconnectOnTap: ()  {},
                              connectOnTap: () async{
                                Future.delayed(
                                    const Duration(
                                        seconds: 3),
                                        () async {
                                      var pref = await SharedPreferences
                                          .getInstance();
                                      // var flag= pref.getStringList('${element.device.id}');
                                      var flag = pref
                                          .getInt('${validDevicesList[i].id}');
                                      if (flag != 3) {
                                        setState(() {});
                                      }
                                    });

                                await validDevicesList[i].connect(autoConnect: true,);
                                // var pref = await SharedPreferences.getInstance();
                                // pref.setStringList('${element.device.id}', ['true']);
                                widget.sharedPrefInstance.setInt('${validDevicesList[i].id}', 3);
                                widget.sharedPrefInstance.setString('lastDeviceId', '${validDevicesList[i].id}');
                                if(mounted){
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (context) =>
                                        GasLevelPage(
                                          device: validDevicesList[i],
                                        ),
                                  ),);
                                  setState(() {});
                                }

                              },
                            ),);
                          }else {
                            connectedDevicesSnapshot.data![i].connect();
                            widget.sharedPrefInstance.setInt('${connectedDevicesSnapshot.data![i].id}', 3);
                            widget.sharedPrefInstance.setString('lastDeviceId', '${connectedDevicesSnapshot.data![i].id}');
                            validDevicesList.add(connectedDevicesSnapshot.data![i]);
                            deviceItemList.add(DeviceItem(
                              sharedPreferences: widget.sharedPrefInstance,
                              update: () {
                                setState(() {});
                              },
                              bluetoothDevice: validDevicesList[i],
                              // flag:flag?.first ,
                              deviceName: validDevicesList[i].name,
                              isConnected: true,
                              openOnTap: () async {
                                if(mounted) {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GasLevelPage(
                                                device: validDevicesList[i])),
                                  );
                                }
                              },
                              disconnectOnTap: () async {
                                await validDevicesList[i].disconnect();
                                // var pref =
                                // await SharedPreferences.getInstance();
                                widget.sharedPrefInstance.setInt('${validDevicesList[i].id}', 2);
                                widget.sharedPrefInstance.setString('lastDeviceId', '');
                                // pref.setStringList('${validDevicesList[i].id}', ['false']);

                                Future.delayed(const Duration(seconds: 3), () {
                                  setState(() {});
                                });
                                // });
                              },
                              connectOnTap: () {},
                            ),);

                          }
                        }
                      }
                      print('dddd ${deviceItemList.length}');
                    }
                    if (connectedDevicesSnapshot.connectionState == ConnectionState.done) {
                      return FutureBuilder<dynamic>(
                        future: FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 2)),
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          print('test second future builder ${snapshot.data}');
                          if (snapshot.hasData || snapshot.connectionState==ConnectionState.done) {
                            FlutterBluePlus.instance.stopScan();
                          }
                          return StreamBuilder<List<ScanResult>>(
                            initialData: [],
                            stream: FlutterBluePlus.instance.scanResults,
                            builder: (BuildContext context, AsyncSnapshot<List<ScanResult>> scanResult) {
                              if(scanResult.hasData) {
                                if (scanResult.data!.isNotEmpty) {
                                  print('scannnnn resultttt ${scanResult.data}');
                                  for (var element in scanResult.data!) {
                                    if (element.device.name != '' && element.device.name.startsWith('GASLEVEL')) {
                                      if (validDevicesList.isNotEmpty) {
                                        List<BluetoothDevice> addToList = [];
                                        addToList.clear();
                                        for (var element1 in validDevicesList) {
                                          // if (element1.id != element.device.id && element1.name!=element.device.name&& !validDevicesList.contains(element.device)) {
                                          if (!validDevicesList.contains(element.device)) {
                                            // if (lastDeviceId== '${element.device.id}' ) {
                                            //   connectToDevice(element.device).then((value) {
                                            //     widget.sharedPrefInstance.setInt('${element.device.id}', 3);
                                            //     widget.sharedPrefInstance.setString('lastDeviceId', '${element.device.id}');
                                            //     setState(() {});
                                            //   });
                                            //
                                            // }else {

                                              addToList.add(element.device);
                                              deviceItemList.add(
                                                DeviceItem(
                                                  sharedPreferences: widget
                                                      .sharedPrefInstance,
                                                  update: () {
                                                    setState(() {});
                                                  },
                                                  bluetoothDevice: element
                                                      .device,
                                                  // flag: flag?.first,
                                                  deviceName: element.device
                                                      .name,
                                                  isConnected: false,
                                                  openOnTap: () {},
                                                  disconnectOnTap: () {},
                                                  connectOnTap: () async {
                                                    print(
                                                        'conect1 on tap check');
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 3),
                                                            () async {
                                                          var pref = await SharedPreferences
                                                              .getInstance();
                                                          // var flag= pref.getStringList('${element.device.id}');
                                                          var flag = pref
                                                              .getInt('${element
                                                              .device.id}');
                                                          if (flag != 3) {
                                                            setState(() {});
                                                          }
                                                        });

                                                    await element.device
                                                        .connect(
                                                      autoConnect: true,);
                                                    var pref = await SharedPreferences
                                                        .getInstance();
                                                    // pref.setStringList('${element.device.id}', ['true']);
                                                    pref.setInt(
                                                        '${element.device.id}',
                                                        3);
                                                    pref.setString(
                                                        'lastDeviceId',
                                                        '${element.device.id}');
                                                    if(mounted){
                                                      await Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                        builder: (context) =>
                                                            GasLevelPage(
                                                              device: element
                                                                  .device,
                                                            ),
                                                      ),);
                                                      setState(() {});
                                                    }
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
                                      }
                                      else {
                                        // if (lastDeviceId== '${element.device.id}' ) {
                                        // connectToDevice(element.device).then((value){
                                        //   widget.sharedPrefInstance.setInt('${element.device.id}', 3);
                                        //   widget.sharedPrefInstance.setString('lastDeviceId', '${element.device.id}');
                                        //   setState(() {});
                                        // }) ;
                                        //
                                        // }
                                        // else {

                                          validDevicesList.add(element.device);
                                          deviceItemList.add(DeviceItem(
                                            sharedPreferences: widget
                                                .sharedPrefInstance,
                                            update: () {
                                              setState(() {});
                                            },
                                            bluetoothDevice: element.device,
                                            // flag: flag?.first ,
                                            deviceName: element.device.name,
                                            // isConnected:flag==true?true: false,
                                            isConnected: false,
                                            openOnTap: () {},
                                            disconnectOnTap: () {},
                                            connectOnTap: () async {
                                              print('conect on tap check');
                                              Future.delayed(
                                                  const Duration(seconds: 3), () async {
                                                    // var pref = await SharedPreferences.getInstance();
                                                    // var flag= pref.getStringList('${element.device.id}');
                                                    var flag = widget.sharedPrefInstance.getInt('${element.device.id}');
                                                    print('flaggss $flag');
                                                    // if (flag!.first==null || flag.first == "false") {
                                                    if (flag != 3) {
                                                      setState(() {});
                                                    }
                                                  });

                                              await element.device.connect(autoConnect: true,);
                                              // var pref = await SharedPreferences.getInstance();
                                              widget.sharedPrefInstance.setInt('${element.device.id}', 3);
                                              widget.sharedPrefInstance.setString('lastDeviceId', '${element.device.id}');
                                              // pref.setStringList('${element.device.id}', ['true']);
                                              if(mounted){
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GasLevelPage(
                                                          device: element.device,
                                                        ),
                                                  ),
                                                );
                                                setState(() {});
                                              }

                                            },
                                          ));


                                        // }
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
                                      } else  if(isScanning.data==false){
                                        if (deviceItemList.isEmpty) {
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
                                          List<BluetoothDevice> bleDevice=[];
                                          bleDevice.clear();
                                          validDevicesList.forEach((valid) {
                                            if(lastDeviceId== '${valid.id}' && widget.sharedPrefInstance.getInt('${valid.id}')==2){
                                              bleDevice.add(valid);
                                            }
                                          });
                                          if(bleDevice.isNotEmpty) {
                                            return FutureBuilder<void>(
                                              future: bleDevice.first.connect(),
                                              builder: (BuildContext context, AsyncSnapshot<void> handConnectSnap) {
                                                if (handConnectSnap.connectionState == ConnectionState.done ) {
                                                  widget.sharedPrefInstance.setInt('${bleDevice.first.id}', 3);
                                                  widget.sharedPrefInstance.setString('lastDeviceId', '${bleDevice.first.id}');
                                                 int index= validDevicesList.indexOf(bleDevice.first);
                                                  validDevicesList.removeWhere((element) => element.id==bleDevice.first.id);
                                                  print('fuuuuuckkkkkkk1 ${validDevicesList.length}');
                                                  validDevicesList.add(bleDevice.first);
                                                  deviceItemList.removeAt(index);
                                                  deviceItemList.add(DeviceItem(
                                                    sharedPreferences: widget
                                                        .sharedPrefInstance,
                                                    update: () {
                                                      setState(() {});
                                                    },
                                                    bluetoothDevice: bleDevice.first,
                                                    // flag: flag?.first ,
                                                    deviceName: bleDevice.first.name,
                                                    // isConnected:flag==true?true: false,
                                                    isConnected: true,
                                                    openOnTap: () async{
                                                      if(mounted){
                                                        await Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) => GasLevelPage(
                                                                  device: bleDevice.first)),
                                                        );
                                                      }
                                                    },
                                                    disconnectOnTap: ()async {
                                                      await bleDevice.first.disconnect();
                                                      // var pref =
                                                      //     await SharedPreferences.getInstance();
                                                      widget.sharedPrefInstance.setInt('${bleDevice.first.id}', 2);
                                                      widget.sharedPrefInstance.setString('lastDeviceId','');
                                                      // pref.setStringList('${validDevicesList[i].id}', ['false']);
                                                      Future.delayed(Duration(seconds: 3),(){
                                                        setState(() {});
                                                      });
                                                    },
                                                    connectOnTap: () async {
                                                    },
                                                  ));
                                                  print('fuuuuuckkkkkkk2 ${deviceItemList.length}');
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
                                                return Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors
                                                          .yellowAccent,));
                                              },

                                            );
                                          }
                                          else{
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

