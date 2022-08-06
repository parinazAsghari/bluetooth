import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gaslevel/constants.dart';
import 'package:gaslevel/main.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class GasLevelPage extends StatefulWidget {
  const GasLevelPage({
    Key? key, required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  State<GasLevelPage> createState() => _GasLevelPageState();
}

class _GasLevelPageState extends State<GasLevelPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    bluetoothCharacteristic.setNotifyValue(false);
    super.dispose();
  }

  disconnect() async {
    await widget.device.disconnect();
  }

  late BluetoothCharacteristic bluetoothCharacteristic;
  Color gasLevelColor = Colors.transparent;
  double value = 0.0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      //backgroundColor: Colors.white.withOpacity(0.93),
      appBar: AppBar(
        elevation: 20,
        actions: [],
        centerTitle: true,
        title: Text(
          '${widget.device.name}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<List<BluetoothService>>(
        future: widget.device.discoverServices(),
        builder: (BuildContext context,
            AsyncSnapshot<List<BluetoothService>> discoveredServiceSnapshot) {
          print('errrorrr ${discoveredServiceSnapshot.error}');
          if (discoveredServiceSnapshot.hasData && discoveredServiceSnapshot.data!=null) {
            return StreamBuilder<List<BluetoothService>>(
                stream: widget.device.services,
                builder: (BuildContext context,
                    AsyncSnapshot<List<BluetoothService>> servicesSnap) {
                  if (servicesSnap.hasData && servicesSnap.data!.isNotEmpty) {
                    bluetoothCharacteristic = Platform.isAndroid?servicesSnap.data![2].characteristics[0] : servicesSnap.data![0].characteristics[0];
                    Platform.isAndroid? servicesSnap.data![2].characteristics[0].setNotifyValue(true):
                    servicesSnap.data![0].characteristics[0].setNotifyValue(true);
                    if (servicesSnap.data != null) {
                      return StreamBuilder<List<int>>(
                          stream:Platform.isAndroid?
                          servicesSnap.data![2].characteristics[0].value : servicesSnap.data![0].characteristics[0].value,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<int>> characteristicSnap) {
                            print('qqqqqqqqqq ${characteristicSnap.data}');
                            if (characteristicSnap.hasData &&
                                characteristicSnap.data!.isNotEmpty) {
                              if (characteristicSnap.data!.first - 48 == 1) {
                                gasLevelColor = Colors.red;
                                value = 0.11;
                              } else if (characteristicSnap.data!.first - 48 ==
                                  2) {
                                gasLevelColor = const Color(0xFF10C086);
                                value = 0.3;
                              } else if (characteristicSnap.data!.first - 48 ==
                                  3) {
                                gasLevelColor = const Color(0xFF0C9869);
                                value = 0.5;
                              }
                              return Column(children: [
                                Container(
                                  height: size.height * 0.2,
                                  child: Stack(
                                    children: [
                                      HeaderWithBatteryBar(size: size),
                                      Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                                            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                                            height: 54,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    offset: Offset(0, 10),
                                                    blurRadius: 50,
                                                    color: kPrimaryColor.withOpacity(0.23),
                                                  )
                                                ]),
                                            child: TextField(
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                hintText: "Battery",
                                                hintStyle:
                                                TextStyle(color: kPrimaryColor.withOpacity(1)),
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Stack(
                                    children:[
                                      Positioned(
                                        // width: 300,
                                        height: MediaQuery.of(context).size.height * 0.55,
                                        right: 25,
                                        left:  25,
                                        bottom: 20,
                                        child: Container(
                                          // width: 190,
                                          // width:(MediaQuery.of(context).size.width)-((MediaQuery.of(context).size.width-320)*2),
                                          // height: MediaQuery.of(context).size.height * 0.5,
                                          // height: 410,
                                          child: LiquidLinearProgressIndicator(
                                            value: value,
                                            // Defaults to 0.5.
                                            valueColor: AlwaysStoppedAnimation(gasLevelColor),
                                            // Defaults to the current Theme's accentColor.
                                            backgroundColor: Colors.transparent,
                                            // Defaults to the current Theme's backgroundColor.
                                            borderColor: Colors.transparent,
                                            borderWidth: 0.0,
                                            direction: Axis
                                                .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                                            // shapePath: null,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // color: Colors.yellowAccent,
                                        // width: 245,
                                        // width:MediaQuery.of(context).size.height*0.5,
                                        // height: 500,
                                        height: MediaQuery.of(context).size.height * 0.6,
                                        child: Image.asset(
                                          'assets/cylindr4.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ]

                                )
                              ]);

                            // return Center(child: Text('${characteristicSnap.data!.first-48}'));
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0C9869),
                              ),
                            );
                          });
                    }
                  }
                  return SizedBox();
                });
          }
          return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0C9869),
              ));
        },
      ),
    );
  }
}

class HeaderWithBatteryBar extends StatelessWidget {
  const HeaderWithBatteryBar({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          left: kDefaultPadding,
          right: kDefaultPadding,
          bottom: 10 + kDefaultPadding),
      height: size.height * 0.2 - 27,
      decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          )),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(
              "Gasfüllstand & Battery Anzeige",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Expanded(
                  child: Icon(
                    Icons.gas_meter_outlined,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),

                Expanded(
                  child: Icon(
                    Icons.battery_charging_full_sharp,
                    color: Colors.white,
                    size: 30.0,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
    );
  }
}
