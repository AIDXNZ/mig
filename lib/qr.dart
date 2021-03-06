import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mig/updatemachine.dart';
import 'extensions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'generateQr.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:math' as math;

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF1c6b92),
          title: Text('Scan Machine QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                )),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateMachinePageQr(qrText),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class UpdateMachinePage extends StatefulWidget {
  final String docRef;
  final String name;

  UpdateMachinePage(this.docRef, this.name);

  @override
  _UpdateMachinePageState createState() => _UpdateMachinePageState();
}

class _UpdateMachinePageState extends State<UpdateMachinePage> {
  var time = new DateTime.now();

  TextEditingController controller;

  String data;
  String notes;

  bool cleaned = false;

  final cminController = TextEditingController();
  final cmaxController = TextEditingController();
  final ctargetController = TextEditingController();
  final cuwarningController = TextEditingController();
  final clwarningController = TextEditingController();

  String cMin;
  String cMax;
  String cTarget;
  String cUwarning;
  String cLwarning;

  String name;

  Future<void> getName(String docRef) async {
    var box = Hive.box('myBox');
    var doc = await Firestore.instance
        .collection(box.get('companyId'))
        .document(docRef)
        .get();
    setState(() {
      name = doc['name'];
    });
  }

  Widget _handleWidget() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('myBox').listenable(),
      builder: (BuildContext context, box, Widget child) {
        var isAdmin = box.get('admin');
        if (isAdmin == false) {
          return Container();
        } else {
          return Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cTarget = value;
                      });
                    },
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 1)],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Target Coolant % (Optional)',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cMin = value;
                      });
                    },
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 1)],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Min Coolant % (Optional)',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cMax = value;
                      });
                    },
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 1)],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Max Coolant % (Optional)',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cLwarning = value;
                      });
                    },
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 1)],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Lower Warning % (Optional)',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cUwarning = value;
                      });
                    },
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 1)],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Upper Warning % (Optional)',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void getInputData() {
    setState(() {
      cMin = cminController.text;
      cMax = cmaxController.text;
      cTarget = ctargetController.text;
      cUwarning = cuwarningController.text;
      cLwarning = clwarningController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(
          'Add Refractometer Reading',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFF1c6b92),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                Colors.white,
                Colors.blue[50],
                Colors.lightBlue[100],
                Colors.lightBlue[200],
              ],
            ),

            color: Colors.white,

            borderRadius: BorderRadius.circular(00.0),

            // the box shawdow property allows for fine tuning as aposed to shadowColor
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '${widget.name}',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: Text(
                    "Enter Coolant Percentage",
                    style: TextStyle(
                        fontSize: 16,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        data = value;
                      });
                    },
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 1)],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Enter Coolant Percentage',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        notes = value;
                      });
                    },
                    controller: controller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Add any notes (Optional)',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
                Container(child: _handleWidget()),
                SwitchListTile(
                    title: Text(
                      "Was The Sump Cleaned?",
                      //style: whiteBoldText,
                    ),
                    value: cleaned,
                    onChanged: (val) {
                      setState(() {
                        cleaned = val;
                      });
                    }),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          var box = Hive.box('myBox');
                          if (data != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({
                              "coolant-percent": "$data",
                              "last-updated": "$time"
                            });
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .collection('history')
                                .document("$time")
                                .setData({"data": "$data", "time": "$time"});
                          }
                          if (notes != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .collection("notes")
                                .document("$time")
                                .setData({"note": "$notes", "time": "$time"});
                          }

                          if (cleaned != false) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"last-cleaned": "$time"});
                          }

                          if (cTarget != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"c-target": "$cTarget"});
                          }
                          if (cMin != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"c-min": "$cMin"});
                          }
                          if (cMax != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"c-max": "$cMax"});
                          }
                          if (cUwarning != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"c-uwarning": "$cUwarning"});
                          }
                          if (cLwarning != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"c-lwarning": "$cLwarning"});
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Colors.blueAccent[700],
                                  Colors.blue
                                ])),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Update',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GenerateButton extends StatelessWidget {
  const GenerateButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GenerateScreen()));
        },
        onLongPress: () => {},
        child: Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    colors: [Colors.lightBlue, Colors.lightBlueAccent])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_applications,
                  color: Colors.white,
                ),
                Text(
                  ' Generate QR Code',
                  style: TextStyle(color: Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}