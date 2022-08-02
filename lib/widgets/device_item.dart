import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class DeviceItem extends StatefulWidget {
  const DeviceItem({Key? key,required this.deviceName,required this.isConnected, required this.connectOnTap, required this.disconnectOnTap, required this.openOnTap, required this.flag, required this.bluetoothDevice, required this.update}) : super(key: key);
  final String deviceName;
  final BluetoothDevice bluetoothDevice;
  final bool isConnected;
  final bool flag;
  final Function() connectOnTap;
  final Function() openOnTap;
  final Function() disconnectOnTap;
  final Function() update;

  @override
  State<DeviceItem> createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {
    Timer? timer ;
  @override
  void dispose() {
    if(timer!=null){
      timer!.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    print('builddddd222');


    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
           gradient: const LinearGradient(
             begin: Alignment.topCenter,
             end: Alignment.bottomCenter,
             colors: [
               Color(0xFF053D2B),
               Color(0xFF0C9869),
               Color(0xFF6DE8B9),
             ],
           ),
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: const Color(0xFF0C9869)),
          color: const Color(0xFF0C9869)
        ),
        child: Row(
          children: [
            const SizedBox(width: 10,),
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/g_logo.png',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              flex: 3,
              child: Padding(
              padding: const EdgeInsets.only(left: 3,right:3),
              child: Text(widget.deviceName,style:  TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
            ),
            const Spacer(flex: 1,),
            widget.isConnected?
            Expanded(
              flex: 5,
              child: StreamBuilder<BluetoothDeviceState>(
                stream: widget.bluetoothDevice.state,
                builder: (BuildContext context, AsyncSnapshot<BluetoothDeviceState> deviceState) {
                  print('kkkkkkkkkkkk1111 ${deviceState.data}');
                  if( deviceState.connectionState ==ConnectionState.active && deviceState.data == BluetoothDeviceState.connected ){
                    if(timer!=null){
                      timer!.cancel();
                    }
                    FlutterBluePlus.instance.connectedDevices.then((value) {
                      print('rrrrrrrrrrrrrrrr1 ${value.length}');
                    });
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        Container(
                          // height: 30,
                          child: InkWell(
                            onTap: (){
                              return widget.openOnTap();
                            },
                            child: Center(child: const Text('open',style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: ()async{
                            return await widget.disconnectOnTap();
                          },
                          child: Center(child: const Text('disconnect',style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold),)),
                        ),
                        Spacer(),
                        // SizedBox(height: 2,),
                      ],
                    );
                  }
                  else if(deviceState.connectionState ==ConnectionState.active && deviceState.data == BluetoothDeviceState.disconnected){
                    if(Platform.isIOS) {
                      timer = Timer.periodic(
                          const Duration(seconds: 8), (Timer t) async {
                            // widget.update();
                      await  widget.bluetoothDevice.connect();
                        // setState(() {});
                      });
                    }
                    return const Padding(
                      padding: EdgeInsets.only(right: 2.0),
                      child: Text('device disconnected,wait...',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 10),),
                    );
                  }
                  else {
                    return const CircularProgressIndicator(
                      color: Color(0xFF0C9869),);
                  }

                },

              )
            ):
            Expanded(
              flex: 2,
              child:
              StreamBuilder(
                stream: widget.bluetoothDevice.state,
                builder: (BuildContext context, AsyncSnapshot<dynamic> state) {
                  if(timer!=null){
                    timer!.cancel();
                  }
                  if( state.connectionState ==ConnectionState.active && state.data == BluetoothDeviceState.connected ){
                    return  Text('connecting',style: TextStyle(fontSize: 15,color:widget.flag ? Colors.white.withOpacity(0.5) : Colors.white),);
                  }
                 return TextButton(
                    // onPressed: widget.flag ? null : ()async{
                    onPressed: widget.flag ? null : ()async{
                      return widget.connectOnTap();

                    },
                    child:  Text('connect',style: TextStyle(fontSize: 15,color:widget.flag ? Colors.white.withOpacity(0.5) : Colors.white),),
                  );
                },

              )
            )
          ],
        ),
      ),
    );
  }
}
