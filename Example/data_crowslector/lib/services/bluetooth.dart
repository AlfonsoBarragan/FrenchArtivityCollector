
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:data_crowslector/widgets/header.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothConnectionInterface extends StatefulWidget{
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _BluetoothConnectionInterfaceState createState() => _BluetoothConnectionInterfaceState();
}

class _BluetoothConnectionInterfaceState extends State<BluetoothConnectionInterface>{
  PermissionStatus _status;
  PageController pageController;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: header(
        context,
        titleText: "Dispositivos Bluetooth Detectados",
        removeBackButton: true,
      ),
    ),
    body: _buildListViewOfDevices(),
  );

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _askPermission();

  }
  // Bluetooth Management (Asking for permission, scan, etc...) //
  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses){
    final status = statuses[PermissionGroup.locationWhenInUse];
    _updateStatus(status);

    // Meter lo del bluetooth
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.//Make sure user's device gps is on.
        widget.flutterBlue.connectedDevices
            .asStream()
            .listen((List<BluetoothDevice> devices) {
          for (BluetoothDevice device in devices) {
            _addDeviceTolist(device);
          }
        });
        widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
          for (ScanResult result in results) {
            _addDeviceTolist(result.device);
          }
        });
        widget.flutterBlue.startScan();
      }
    });

    //startServiceInPlatform();

  }

  void _askPermission(){
    PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
  }

  void _updateStatus(PermissionStatus status){
    if(status != _status){
      setState(() {
        _status = status;
      });
    }
  }
  // Interface Management (showing detected devices, etc...) //
  void  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }
  ListView _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  widget.flutterBlue.stopScan();
                  startServiceInPlatform(device.id.toString());
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  // Service Management (pass the device's direction to mibandlib in android)
  void startServiceInPlatform(String macAddress) async {
    var methodChannel = MethodChannel("es.uclm.esi.mami.macAddress");
    String data = await methodChannel.invokeMethod(macAddress);
    debugPrint(data);
  }
}