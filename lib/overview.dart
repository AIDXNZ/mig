import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:mig/qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue[600],
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop()),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      backgroundColor: Colors.lightBlue[200],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.white])
        ),
        child: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              SafeArea(
                child: Text(
                  'Machine Overview',
                  style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: _buildBody(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
              )
      
    ;
  }
}

Widget _buildBody(BuildContext context) {
  var box = Hive.box('myBox');
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection(box.get('companyId')).snapshots(),
    builder: (context, snapshot) {
      assert(snapshot != null);
      if (!snapshot.hasData) {
        return LinearProgressIndicator();
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.white,
            child: DataTable(columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Last Updated')),
              DataColumn(label: Text('Coolant\nPercentage')),
              DataColumn(label: Text('Last Cleaned')),
            ], rows: _buildList(context, snapshot.data.documents)),
          ),
        );
      }
    },
  );
}

List _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return snapshot.map((data) => _buildListItem(context, data)).toList();
}

DataRow _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
  DocumentSnapshot machines = snapshot;

  return DataRow(
    cells: [
      DataCell(Text(machines['name'])),
      DataCell(Text(machines['last-updated'].substring(0, 10))),
      DataCell(Text(machines['coolant-percent'],
          style: TextStyle(
              color: double.parse(machines['coolant-percent']) < 6.0
                  ? Colors.red
                  : Colors.green))),
      DataCell(Text(machines['last-cleaned'].substring(0, 10) ?? "No Input")),
    ],
  );
}
