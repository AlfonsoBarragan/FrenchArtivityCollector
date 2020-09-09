import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:data_crowslector/models/youngster.dart';
import 'package:data_crowslector/services/auth.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:data_crowslector/themes/style.dart';

import 'home.dart';

class SignUpDataCuestionaryPage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/signUpDataCuestionaryPage";

  // Flag used to determine wheter user has a questionnaire
  // in progress or not
  bool inProgress;

  SignUpDataCuestionaryPage({bool inProgress = false}) {
    this.inProgress = inProgress;
  }

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _SignUpDataCuestionaryPageState createState() =>
      _SignUpDataCuestionaryPageState();
}

class _SignUpDataCuestionaryPageState extends State<SignUpDataCuestionaryPage> {
  bool _isLoading = true;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime _birthDateController;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _inProgress = false;
  AuthService _authService;


  @override
  void initState() {
    _authService = AuthService();


    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery
        .of(context)
        .size
        .height * 0.02;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('eMOVI'),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              SafeArea(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery
                        .of(context)
                        .size
                        .width * 0.1,
                  ),
                  children: <Widget>[
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.8,
                              child: Text("Cuestionario de datos físicos"),
                            )
                          ]
                      ),
                    ),
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.1,
                      padding:
                      EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: Text("Altura"),
                            ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.6,
                              child: TextField(
                                controller: _heightController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Medida en cm',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            )
                          ]
                      ),
                    ),
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.1,
                      padding:
                      EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: Text("Peso"),
                            ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.6,
                              child: TextField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Medida en kg',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            )
                          ]
                      ),
                    ),
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.2,
                      padding:
                      EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02,
                            ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: Text("Fecha de nacimiento"),
                            ),
                            Container(
                                child:
                                SizedBox.fromSize(
                                  size: Size(56, 56), // button width and height
                                  child: ClipOval(
                                    child: Material(
                                      color: CustomTheme.secondaryColorDark, // button color
                                      child: InkWell(
                                        splashColor: CustomTheme.secondaryColorLight,
                                        // splash color
                                        onTap: () async {
                                          _birthDateController =
                                          await DatePicker.showSimpleDatePicker(
                                            context,
                                            initialDate: DateTime(1994),
                                            firstDate: DateTime(1960),
                                            lastDate: DateTime(2050),
                                            dateFormat: "dd-MMMM-yyyy",
                                            locale: DateTimePickerLocale.es,
                                            looping: true,
                                          );
                                        },
                                        // button pressed
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            Icon(MdiIcons.calendar), // text
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ),
                            SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02,

                            )
                          ]
                      ),
                    ),
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.2,
                      padding:
                      EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.8,
                              child: MaterialButton(
                                onPressed: () => submitYoungsterData(),
                                color: CustomTheme.secondaryColor,
                                textColor: Colors.black,
                                child: Text('Confirmar datos'),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

  void submitYoungsterData() {
    Youngster _youngster = Youngster(status: YoungsterStatus.pretest_completed,
        altura: double.parse(_heightController.text),
        peso: double.parse(_weightController.text),
        fechaNacimiento: Timestamp.fromDate(_birthDateController));

    _authService.user.youngster = _youngster;
    _authService.updateYoungsterData(_youngster);
    _authService.updateYoungsterStatus(YoungsterStatus.pretest_completed);


    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage()
        )
    );
  }
}
