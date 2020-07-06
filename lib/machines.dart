import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import './graph.dart';

const greenPercent = Color(0xFF14FF00);

class MachineList extends StatefulWidget {
  @override
  _MachineListState createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
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
        body: _myListView(context));
  }
}

Widget _myListView(BuildContext context) {
  return SafeArea(
    child: ListView(
      children: <Widget>[
        MachineItem(
          name: "Mori 1",
          last_updated: "June 6, 2020",
          c_percent: 7.5,
        ),
        MachineItem(
          name: "Mori 2",
          last_updated: "June 3, 2020",
          c_percent: 8.2,
        ),
        MachineItem(
          name: "Citizen 2",
          last_updated: "June 6, 2020",
          c_percent: 7.1,
        ),
        MachineItem(
          name: "Willy ",
          last_updated: "June 12, 2020",
          c_percent: 8.6,
        ),
        MachineItem(
          name: "Haas 4",
          last_updated: "June 6, 2020",
          c_percent: 7.5,
        ),
        MachineItem(
          name: "Citizen 1",
          last_updated: "June 6, 2020",
          c_percent: 7.5,
        ),
        MachineItem(
          name: "Willy 3",
          last_updated: "June 6, 2020",
          c_percent: 7.5,
        ),
        MachineItem(
          name: "Haas 2",
          last_updated: "June 6, 2020",
          c_percent: 7.5,
        ),
      ],
    ),
  );
}

class MachineItem extends StatelessWidget {
  final String name;
  final String last_updated;
  final double c_percent;

  MachineItem({this.name, this.last_updated, this.c_percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          elevation: 10.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ExpandablePanel(
              header: Text(
                name,
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
              ),
              collapsed: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(last_updated),
                  Card(
                    color: greenPercent,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "$c_percent",
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    )),
                  )
                ],
              ),
              expanded: LineChartSample2(),
            ),
          ),
        ),
      ),
    );
  }
}
