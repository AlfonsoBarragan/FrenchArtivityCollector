

// flutter main libraries
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_crowslector/models/phyActivity.dart';
import 'package:data_crowslector/models/youngster.dart';
import 'package:data_crowslector/pages/login_page.dart';
import 'package:data_crowslector/pages/sign_up_data_cuestionary_page.dart';
import 'package:data_crowslector/widgets/progress.dart';
import 'package:data_crowslector/services/firestore.dart';
import 'package:data_crowslector/widgets/sleepChart.dart';
import 'package:data_crowslector/widgets/stepsChart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprintf/sprintf.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//utils packages
import 'package:google_sign_in/google_sign_in.dart';
import 'package:data_crowslector/widgets/heartRateChart.dart';
import 'package:data_crowslector/themes/style.dart';



// firebase
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//app
import 'package:data_crowslector/models/user.dart';
import 'package:data_crowslector/services/bluetooth.dart';
import 'package:data_crowslector/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
],);
final StorageReference storageRef = FirebaseStorage.instance.ref();
final PhyActivityService phyActivityService = PhyActivityService ();
final usersRef = Firestore.instance.collection("users");
final DateTime timestamp = DateTime.now();

User currentUser;
String email;
String pwd;

String steps = "";
String heartRate = "";
String sleep = "";


List<PhyActivity> phyActivityList = new List<PhyActivity>();

List<FlSpot> heartRateListDaily = new List<FlSpot>();
List<FlSpot> stepsListDaily = new List<FlSpot>();

List<FlSpot> heartRateListWeekly = new List<FlSpot>();
List<FlSpot> stepsListWeekly = new List<FlSpot>();

List<double> sleepTotalWeekly = new List<double>();
List<double> sleepLightWeekly = new List<double>();
List<double> sleepDeepWeekly = new List<double>();


enum WidgetMarker {heartRate, steps, sleep}

class MyHomePage extends StatefulWidget {

  /// Name use for navigate to this screen
  static const route = "/home";
  static const routeAuth = "/home-auth";
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

//  final String title;
  bool auth;
  MyHomePage({bool isAuth = false}) {
    this.auth = isAuth;
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();

}
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  bool validacion = false;
  bool _isAuth = false;
  bool _isLoading = true;
  bool sent = false;
  bool show;
  PermissionStatus _status;


  double _containerPaddingLeft = 20.0;
  double _animationValue;
  double _translateX = 0;
  double _translateY = 0;
  double _rotate = 0;
  double _scale = 1;
  Color _color = CustomTheme.secondaryColor;
  String buttonText = "Sincronizar datos";
  Icon buttonIcon = new Icon(MdiIcons.cellphoneArrowDown);


  Timer _timer;
  int _start = 60;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
            print("set animation value to 0");
            setState(() {
                show = false;
                sent = false;
                _color = CustomTheme.secondaryColor;
                buttonIcon = Icon(MdiIcons.cellphoneArrowDown);
                buttonText = "Sincronizar datos";
                _animationController.forward(from: 0.0);

                }
              );


          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  static DateTime fechaActual = DateTime.now();
  String date;

  PageController pageController;
  AnimationController _animationController;

  AuthService _authService;
  WidgetMarker selectedWidgetMarker = WidgetMarker.steps;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  static const methodChannel_phyActivities =
  const MethodChannel('es.uclm.esi.mami.phyActivities');

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    _authService = AuthService();
    if (!widget.auth) {
      _checkAuth();
    } else {
      _isAuth = true;
      _isLoading = false;

    }
    _askPermission();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1300));
    show = true;
    _animationController.addListener(() {
      setState(() {
        show = false;
        _animationValue = _animationController.value;
        if (_animationValue >= 0.2 && _animationValue < 0.4) {
          _containerPaddingLeft = 100.0;
          _color = Colors.green;
        } else if (_animationValue >= 0.4 && _animationValue <= 0.5) {
          _translateX = 80.0;
          _rotate = -20.0;
          _scale = 0.1;
        } else if (_animationValue >= 0.5 && _animationValue <= 0.8) {
          _translateY = -20.0;
        } else if (_animationValue >= 0.81) {
          _containerPaddingLeft = 20.0;
          sent = true;
          buttonIcon = Icon(Icons.check_circle);
          buttonText = "Sincronizado";
        }
      });
    });

  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await _authService.init();

    setState(() {
      _isAuth = _authService.isAuth;
      _isLoading = false;

    });

    if (_isAuth) {
      print(_authService.user.toString());
      setState(() {
        _isLoading = true;

      });
      statsCalculation();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _authService.user.id);
    }
  }
  @override
  _MyHomePageState(){
    print("I am launching the service...");

    if (fechaActual.month < 10){
      date = sprintf('%s_0%s', [fechaActual.year, fechaActual.month]);
    }

    if (fechaActual.day < 10){
      date = sprintf('%s_0%s', [date, fechaActual.day]);
    }
    print(date);

  }
  Widget _buildAuthScreen() {
    User user = _authService.user;
    print(user.toString());

    if (user.id == null) {
      return LoginPage();
    } else {
      return _buildHomePage();
    }
  }

  DateTime initDay(){
    DateTime init = DateTime.now();
    init = init.subtract(new Duration(hours: init.hour, minutes: init.minute, seconds:init.second));

    return init;
  }

  DateTime initWeek(){
    DateTime init = DateTime.now();
    init = init.subtract(new Duration(hours: init.hour + 24 * init.weekday, minutes: init.minute, seconds:init.second));

    return init;
  }

  void statsCalculation(){

    if (steps == "" || (fechaActual.difference(DateTime.now()).inMinutes > 30)){
      phyActivityService.getResumeParameters(initDay(), DateTime.now()).then((value) => setState((){

        double stepsAux = value[0];
        steps = stepsAux.toStringAsFixed(0);

      }));
    }

    if (heartRate == "" || (fechaActual.difference(DateTime.now()).inMinutes > 30)){
      phyActivityService.getResumeParameters(initDay(), DateTime.now()).then((value) => setState((){
        double heartAux = value[1];
        heartRate = heartAux.toStringAsFixed(2);
      }));
    }

    if (sleep == "" || (fechaActual.difference(DateTime.now()).inMinutes > 30)){
      phyActivityService.getResumeParameters(initDay(), DateTime.now()).then((value) => setState((){
        double sleepAux = value[2];
        sleep = sleepAux.toStringAsFixed(0);
      }));
    }

    if (heartRateListDaily.isEmpty || stepsListDaily.isEmpty){
      phyActivityService.getDailyStats(initDay(), DateTime.now()).then((value) => setState((){
        for (Stats stats in value){
          if(!heartRateListDaily.contains(FlSpot(stats.time, stats.heartRate.toDouble())))
            heartRateListDaily.add(FlSpot(stats.time, stats.heartRate.toDouble()));
          if(!stepsListDaily.contains(FlSpot(stats.time, stats.steps.toDouble())))
            stepsListDaily.add(FlSpot(stats.time, stats.steps.toDouble()));
        }
      }));
    }

    if (heartRateListWeekly.isEmpty || stepsListWeekly.isEmpty){
      phyActivityService.getWeeklyStats(initWeek(), DateTime.now()).then((value) => setState((){

        for (WeeklyStats stats in value){
          if(!heartRateListWeekly.contains(FlSpot(stats.time, double.parse((stats.heartRate).toStringAsFixed(2)))))
            heartRateListWeekly.add(FlSpot(stats.time, double.parse((stats.heartRate).toStringAsFixed(2))));
          if(!stepsListWeekly.contains(FlSpot(stats.time, stats.steps.toDouble())))
            stepsListWeekly.add(FlSpot(stats.time, stats.steps));

          if(sleepTotalWeekly.length < value.length){
            sleepTotalWeekly.add(double.parse(((stats.sleepTotal/60)).toStringAsFixed(1)));

          }

          if(sleepLightWeekly.length < value.length){
            sleepLightWeekly.add(double.parse(((stats.sleepLight/60)).toStringAsFixed(1)));
          }

          if(sleepDeepWeekly.length < value.length){
            sleepDeepWeekly.add(double.parse(((stats.sleepDeep/60)).toStringAsFixed(1)));
          }
        }

        int aux = 7 - sleepTotalWeekly.length;

        for (int i = 0; i < aux; i++){
          sleepTotalWeekly.add(0);
          sleepLightWeekly.add(0);
          sleepDeepWeekly.add(0);
        }
        setState(() {
          _isLoading = false;
        });

      }));

    }
  }

  Widget _buildHomePage(){

    Youngster youngster = _authService.user.youngster;
    YoungsterStatus youngsterStatus = youngster.status;

    if (youngsterStatus == YoungsterStatus.pretest_pending)
      return SignUpDataCuestionaryPage();

    statsCalculation();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColorLight,
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text('eMOVI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                backgroundColor: Theme.of(context).primaryColor,
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(MdiIcons.accountSupervisor)),
                    Tab(icon: Icon(MdiIcons.chartAreaspline)),
                    Tab(icon: Icon(MdiIcons.cog)),
                  ],
                )
            ),
            body: TabBarView(
              children: <Widget>[
                Scaffold(
                  body: Center(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Estadísticas diarias",
                                style: TextStyle(height: 7, fontSize: 21)
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Icon(Icons.directions_run, color: CustomTheme.secondaryColor, size: 60),
                                Text(steps.toString(),
                                    style: TextStyle(fontSize: 21))
                              ],
                            ),
                            Column(
                              children: [
                                Icon(MdiIcons.heartPulse, color: CustomTheme.secondaryColor, size: 60),
                                Text(heartRate.toString(),
                                    style: TextStyle(fontSize: 21)),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(Icons.local_hotel, color: CustomTheme.secondaryColor, size: 60),
                                Text(sleep.toString(),
                                    style: TextStyle(fontSize: 21)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                                children: <Widget>[
                                  SizedBox.fromSize(
                                    size: Size(56, 56), // button width and height
                                    child: ClipOval(
                                      child: Material(
                                        color: CustomTheme.secondaryColorDark, // button color
                                        child: InkWell(
                                          splashColor: CustomTheme.secondaryColorLight,
                                          // splash color
                                          onTap: () {Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => BluetoothConnectionInterface()),
                                          );},
                                          // button pressed
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Icon(MdiIcons.bluetoothSettings), // text
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            Column(
                                children: <Widget>[
                                  SizedBox.fromSize(
                                    size: Size(56, 56), // button width and height
                                    child: ClipOval(
                                      child: Material(
                                        color: CustomTheme.secondaryColorDark, // button color
                                        child: InkWell(
                                          splashColor: CustomTheme.secondaryColorLight,
                                          // splash color
                                          onTap: () {startServiceInPlatform("old");},
                                          // button pressed
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Icon(MdiIcons.boomGateUp), // text
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(top: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.1),
                                child: GestureDetector(
                                  onTap: () {
                                    statsCalculation();
                                    _animationController.forward();
                                    startTimer();

                                    },
                                  child: AnimatedContainer(
                                      decoration: BoxDecoration(
                                        color: _color,
                                        borderRadius: BorderRadius.circular(100.0),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: _containerPaddingLeft,
                                          right: 20.0,
                                          top: 10.0,
                                          bottom: 10.0),
                                      duration: Duration(milliseconds: 600),
                                      curve: Curves.easeOutCubic,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          (!sent)
                                              ? AnimatedContainer(
                                            duration: Duration(milliseconds: 400),
                                            child: buttonIcon,
                                            curve: Curves.fastOutSlowIn,
                                            transform: Matrix4.translationValues(
                                                _translateX, _translateY, 0)
                                              ..rotateZ(_rotate)
                                              ..scale(_scale),
                                          )
                                              : Container(),
                                          AnimatedSize(
                                            vsync: this,
                                            duration: Duration(milliseconds: 600),
                                            child: show ? SizedBox(width: 10.0) : Container(),
                                          ),
                                          AnimatedSize(
                                            vsync: this,
                                            duration: Duration(milliseconds: 200),
                                            child: show ? Text(buttonText) : Container(),
                                          ),
                                          AnimatedSize(
                                            vsync: this,
                                            duration: Duration(milliseconds: 200),
                                            child: sent ? buttonIcon : Container(),
                                          ),
                                          AnimatedSize(
                                            vsync: this,
                                            alignment: Alignment.topLeft,
                                            duration: Duration(milliseconds: 600),
                                            child: sent ? SizedBox(width: 10.0) : Container(),
                                          ),
                                          AnimatedSize(
                                            vsync: this,
                                            duration: Duration(milliseconds: 200),
                                            child: sent ? Text(buttonText) : Container(),
                                      ),
                                    ],
                                  )
                                ),
                              )
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Center(key: ValueKey('2'), child: Scaffold(
                  body: Center(
                    child: Column(
                        children: <Widget>[
                          Container(
                            child: getCustomContainer(),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: MediaQuery
                                .of(context)
                                .size
                                .height * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox.fromSize(
                                  size: Size(56, 56), // button width and height
                                  child: ClipOval(
                                    child: Material(
                                      color: CustomTheme.secondaryColorDark, // button color
                                      child: InkWell(
                                        splashColor: CustomTheme.secondaryColorLight,
                                        // splash color
                                        onTap: () {
                                          setState(() {
                                            selectedWidgetMarker = WidgetMarker.steps;
                                          });
                                        },
                                        // button pressed
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            Icon(Icons.directions_run), // text
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox.fromSize(
                                  size: Size(56, 56), // button width and height
                                  child: ClipOval(
                                    child: Material(
                                      color: CustomTheme.secondaryColorDark, // button color
                                      child: InkWell(
                                        splashColor: CustomTheme.secondaryColorLight,
                                        // splash color
                                        onTap: () {
                                          setState(() {
                                            selectedWidgetMarker = WidgetMarker.heartRate;
                                          });
                                        },
                                        // button pressed
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            Icon(MdiIcons.heartPulse), // text
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox.fromSize(
                                  size: Size(56, 56), // button width and height
                                  child: ClipOval(
                                    child: Material(
                                      color: CustomTheme.secondaryColorDark, // button color
                                      child: InkWell(
                                        splashColor: CustomTheme.secondaryColorLight,
                                        // splash color
                                        onTap: () {
                                          setState(() {
                                            selectedWidgetMarker = WidgetMarker.sleep;
                                          });
                                        },
                                        // button pressed
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            Icon(Icons.local_hotel), // text
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ),
                        ]
                    ),

                  ),

                )),
                Center(key: ValueKey('3'), child: Text("Directions car"))
              ],
            )
        ),
      ),
    );
  }
  @override

  // PERMISSION THINGS

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

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses){
    final status = statuses[PermissionGroup.locationWhenInUse];
    _updateStatus(status);

  }

  // CUSTOM WIDGETS AND THINGYS LIKE THAT
  Widget getHeartRateChart() {
    return Container(
        padding: EdgeInsets.only(top: MediaQuery
            .of(context)
            .size
            .height * 0.02),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .size
                    .height * 0.01),
                // don't forget about height
                child:
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Lecturas de ritmo cardíaco por minuto",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
//                                    Chart(
//                                      data: heartRateList,
//                                    )
                      HeartRateChart(
                        dataToPlotDaily: heartRateListDaily,
                        dataToPlotWeekly: heartRateListWeekly,
                      ),
                    ]
                )
            )
          ],
        )
    );
  }

  Widget getStepsChart() {
    return Container(
        padding: EdgeInsets.only(top: MediaQuery
            .of(context)
            .size
            .height * 0.02),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .size
                    .height * 0.01),
                // don't forget about height
                child:
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Número de pasos por minuto",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                      StepsChart(
                        dataToPlotDaily: stepsListDaily,
                        dataToPlotWeekly: stepsListWeekly,
                      ),
                    ]
                )
            )
          ],
        )
    );
  }

  Widget getSleepChart() {
    return Container(
        padding: EdgeInsets.only(top: MediaQuery
            .of(context)
            .size
            .height * 0.02),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .size
                    .height * 0.01),
                // don't forget about height
                child:
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Monitorización de sueño",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                      SleepChart(
                        dataToPlotTotal: sleepTotalWeekly,
                        dataToPlotLight: sleepLightWeekly,
                        dataToPlotDeep: sleepDeepWeekly,
                      ),
                    ]
                )
            )
          ],
        )
    );
  }

  Widget getCustomContainer() {
    switch (selectedWidgetMarker) {
      case WidgetMarker.heartRate:
        return getHeartRateChart();
      case WidgetMarker.steps:
        return getStepsChart();
      case WidgetMarker.sleep:
        return getSleepChart();
    }

    return getStepsChart();
  }

  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return _isLoading
        ? Scaffold(key: _scaffoldKey, body: circularProgress(context))
        : (_isAuth ? _buildAuthScreen() : LoginPage());

//    if (_isAuth) {
//      return new Scaffold(
//        appBar: AppBar(
//          title: Text('eMOVI'),
//          backgroundColor: Colors.indigoAccent,
//        ),
//        body: Center(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              MaterialButton(
//                onPressed: () => _handleSignIn(),
//                color: Colors.greenAccent,
//                textColor: Colors.black,
//                child: Text('Login with Google'),
//              ),
//              MaterialButton(
//                onPressed: () => null,
//                color: Colors.red,
//                textColor: Colors.black,
//                child: Text('Log out'),
//              ),
//              MaterialButton(
//                onPressed: () =>
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => BluetoothConnectionInterface()),
//                    ),
//                color: Colors.deepPurpleAccent,
//                textColor: Colors.black,
//                child: Text('Begin service'),
//              )
//            ],
//          ),
//        ),
//      );
//    } else{
//      return new Scaffold(
//        appBar: AppBar(
//          title: Text('eMOVI'),
//          backgroundColor: Colors.indigoAccent,
//        ),
//        body: Center(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              MaterialButton(
//                onPressed: () =>
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => LoginPage()
//                      ),),
//                color: Colors.deepPurpleAccent,
//                textColor: Colors.black,
//              )
//            ],
//          ),
//        ),
//      );
//    }
  }
  void startServiceInPlatform(String macAddress) async {
    var methodChannel = MethodChannel("es.uclm.esi.mami.macAddress");
    String data = await methodChannel.invokeMethod(macAddress);
    debugPrint(data);
  }

}