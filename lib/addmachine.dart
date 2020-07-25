import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/rendering.dart';
import 'package:mig/qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import './graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class AddMachineList extends StatefulWidget {
  @override
  _AddMachineListState createState() => _AddMachineListState();
}

class _AddMachineListState extends State<AddMachineList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop()),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
          title: Text('Machine Setup',
              style: TextStyle(
                color: Color(0xffFFFFFF),
                backgroundColor: Colors.lightBlue[600],
              ))),
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance.collection("companies").snapshots(),
          builder: (context, snapshot) {
            assert(snapshot != null);
            if (!snapshot.hasData) {
              return Text('PLease Wait');
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot machines = snapshot.data.documents[index];
                  return MachineItem(
                    name: machines['name'],
                    c_percent: machines['coolant-percent'],
                    last_updated: machines['last-updated'],
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 250,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Machine',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddMachinePage()));
                              },
                              onLongPress: () => {},
                              child: Container(
                                  height: 50,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(colors: [
                                        Colors.lightBlue,
                                        Colors.lightBlueAccent
                                      ])),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.settings_applications,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        ' Add Machine',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MachineItem extends StatelessWidget {
  final String name;
  final String last_updated;
  final String c_percent;

  MachineItem({this.name, this.last_updated, this.c_percent});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(last_updated),
      trailing: Text(c_percent),
    );
  }
}

class AddMachinePage extends StatefulWidget {
  AddMachinePage({Key key}) : super(key: key);

  @override
  _AddMachinePageState createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  var time = new DateTime.now();

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();

  String name;

  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actionsIconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.black,
            ),
            onPressed: _captureAndSharePng,
          )
        ],
      ),
      body: _contentWidget(),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.file(_dataString, '$_dataString.png', pngBytes, 'image/png');
    } catch (e) {
      print(e.toString());
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Add Machine Name',
                            labelStyle: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      color: Colors.blueAccent[700],
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          _dataString = _textController.text;
                          _inputErrorText = null;
                        });
                        _captureAndSharePng();
                        Firestore.instance
                            .collection("companies")
                            .document("$name")
                            .setData({
                          "name": "$name",
                          "coolant-percent": "0.0",
                          "last-updated": "$time"
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        10,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RepaintBoundary(
                      key: globalKey,
                      child: QrImage(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        data: _dataString,
                        size: 0.5 * bodyHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}