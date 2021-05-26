import 'package:flutter/material.dart';
import 'package:flutter_petrol_station/widgets/drawer_firstore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_petrol_station/services/cloud_services.dart';

class Pump_Records extends StatefulWidget {
  static String id = 'pump_records';

  //get passed data from previous page
  final String pumpName;
  final int pumpID;
  const Pump_Records({Key key, this.pumpID, this.pumpName}) : super(key: key);

  @override
  _PumpsState createState() =>
      //To Use received data without widget. ( Storing the passed value in a different variable before using it)
      _PumpsState(pumpID: this.pumpID, pumpName: this.pumpName);
}

class _PumpsState extends State<Pump_Records> {
  //To Use received data without widget. ( Storing the passed value in a different variable before using it)
  String pumpName;
  int pumpID;
  _PumpsState({this.pumpID, this.pumpName});

  User loggedInUser;
  static int container_id, pump_id;
  static String container_name, pump_name, station;
  Map<String, Object> received_data;
  int containerID;
  String containerName;
  int previousCounter, newCounter, lastRecordId;
  DateTime lastUpdate;
  int recordError = 0;
  Color colorR = Colors.blueAccent;

  final now = new DateTime.now();
  DateTime dateToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  FirebaseFirestore db = FirebaseFirestore.instance;
  CloudServices cloudServices =
      CloudServices(FirebaseFirestore.instance, FirebaseAuth.instance);

  @override
  void initState() {
    super.initState();
    loggedInUser = cloudServices.getCurrentUser();
    asyncMethod();
    print("inittt");
    print(station);
    // future that allows us to access context. function is called inside the future
    // otherwise it would be skipped and args would return null
    //getContainerInfo(widget.pumpID);
    //print(station);
  }

  void asyncMethod() async {
    // we do this to call a fct that need async wait when calling it;
    // when aiming to use the fct in initState
    if (loggedInUser != null) {
      station = await cloudServices.getUserStation(loggedInUser);
    }
    await getContainerId(widget.pumpID);
    print("asynccccc $containerID");
    if (containerID != null) {
      await getContainerName(containerID);
    }
    setState(() {});
    // hay l setState bhotta ekher shi bl fct yalle btrajj3 shi future krml yn3amal rebuild
    // krml yontor l data yalle 3m trj3 mn l firestore bs n3aytla ll method
  }

  void getContainerName(int container_id) async {
    String cont_name;
    print("In get name $container_id");

    await db
        .collection('Stations')
        .doc('Petrol Station 1')
        .collection('Container')
        .doc(container_id.toString())
        .get()
        .then((value) {
      print("dataaaaaaaaaaaaa");
      print(value.data());
      cont_name = value.data()['Container_Name'];
      print("container nameee: $cont_name");
      containerName = cont_name;
    });
    // .where('Container_Id', isEqualTo: container_id)
    // .get();
  }

  getContainerId(int pumpId) async {
    print("pump idddddddddd in fct: $pumpId");
    print("stationnnn: $station");
    print(station);
    int cont_id;

    DocumentReference documentReference = db
        .collection('Stations')
        .doc(station)
        .collection('Pump')
        .doc(pumpId.toString());
    await documentReference.get().then((value) {
      print("dataaaaaaaaaaaaa");
      print(value.data());
      cont_id = value.data()['Container_Id'];
      print("container idddddd: $cont_id");
      containerID = cont_id;
    });
  }

  void getPumpRecord() {
    db
        .collection('Stations')
        .doc(station)
        .collection('PumpRecord')
        .where('Pump_Id', isEqualTo: pumpID)
        .get()
        .then((value) {
      if (value.docs.length > 0) {}
    });
    var qs = db
        .collection('Stations')
        .doc(station)
        .collection('Pump_Record')
        .where('Pump_Id', isEqualTo: pumpID)
        .get()
        .then((val) => {
              if (val.docs.length > 0)
                {
                  previousCounter = val.docs[val.docs.length - 1].get("Record"),
                  print(previousCounter),
                  lastUpdate = DateTime.tryParse(
                      (val.docs[val.docs.length - 1].get("Record_Time"))
                          .toDate()
                          .toString()),
                  print(lastUpdate),
                  lastRecordId =
                      val.docs[val.docs.length - 1].get("Pump_Record_Id"),
                  print("last record iddddd$lastRecordId"),
                }
              else
                {
                  print("elseeeee"),
                }
            });
  }

  //     .snapshots();
  // qs.then((value) => previousCounter = value.docs.last.data()['Record']);

  @override
  Widget build(BuildContext context) {
    // final Map<String, Object> received_data =
    //     ModalRoute.of(context).settings.arguments;
    // pump_id = received_data["pump_id"];
    // pump_name = received_data["pump_name"];

    //if (mounted) {
    //getContainerInfo(pump_id);
    //}

    getPumpRecord();
    print("previous $previousCounter");

    print("builddd $containerID");
    print("builddd $containerName");
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF083369),
        actions: [
          Row(
            children: [
              Icon(
                Icons.exit_to_app,
                size: 24,
                color: Colors.white,
              ),
              Text('LOGOUT',
                  style: TextStyle(color: Colors.white, fontSize: 21.0)),
              SizedBox(width: 20)
            ],
          )
        ],
      ),
      drawer: getDrawer_firstore(),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              containerName != null ? 'Pump ($containerName)' : 'Pump',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Card(
            elevation: 12,
            child: ExpansionTile(
              title: Text("Pump Info",
                  style: TextStyle(fontSize: 29, color: Colors.indigo[300])),
              trailing: Icon(Icons.arrow_drop_down,
                  size: 20, color: Colors.indigo[300]),
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Divider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Pump Name',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black45)),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(widget.pumpName != null ? '$pumpName' : 'Pump',
                          style: TextStyle(
                              fontSize: 22, color: Colors.indigo[300])),
                      SizedBox(
                        height: 18,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Container Name',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black45)),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                          containerName != null
                              ? 'Container $containerName'
                              : 'Container',
                          style: TextStyle(
                              fontSize: 22, color: Colors.indigo[300])),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Card(
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Text("New Counter",
                      style: TextStyle(fontSize: 21, color: Colors.black45)),
                  SizedBox(height: 10),
                  TextFormField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black54, width: 2.0),
                          ),
                          labelText: previousCounter != null
                              ? previousCounter.toString()
                              : '',
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.black45),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 2.0))),
                      onChanged: (value) {
                        setState(() {
                          newCounter = int.parse(value);
                        });
                      }),
                  SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Previous Counter',
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF083369))),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                              previousCounter != null
                                  ? previousCounter.toString()
                                  : '',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF083369))),
                        ),
                      ),
                      Text(
                        recordError == 1
                            ? 'Enter value positive value less than $previousCounter'
                            : '',
                        style: TextStyle(color: colorR),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Last Update',
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF083369))),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                          lastUpdate != null ? lastUpdate.toString() : '',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF083369))),
                    ),
                  ),
                  Divider(
                    color: Colors.black45,
                    thickness: 3,
                  ),
                  ButtonTheme(
                    height: 50.0,
                    minWidth: 130,
                    child: RaisedButton(
                      color: Colors.indigo[800],
                      elevation: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.library_add_check_outlined,
                              size: 22, color: Colors.white),
                          SizedBox(
                            width: 14,
                          ),
                          Text('Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25)),
                        ],
                      ),
                      onPressed: () {
                        DateTime d = DateTime.now();
                        Timestamp myTimeStamp = Timestamp.fromDate(d);
                        if (newCounter < 0 || newCounter < previousCounter) {
                          setState(() {
                            recordError = 1;
                            colorR = Colors.red;
                          });
                        } else {
                          if (newCounter != null) {
                            setState(() {
                              recordError = 0;
                              colorR = Colors.blueAccent;
                            });
                            int docId = lastRecordId + 1;
                            db
                                .collection("Stations")
                                .doc(station)
                                .collection("Pump_Record")
                                .doc(docId.toString())
                                .set({
                              'Container_Id': containerID,
                              'Pump_Id': pumpID,
                              'Pump_Record_Id': docId,
                              'Record': newCounter,
                              'Record_Time': myTimeStamp,
                              'X_Id': myTimeStamp
                            });
                            setState(() {
                              //previousCounter = newCounter;
                              //lastUpdate = DateTime.tryParse(
                              //(myTimeStamp).toDate().toString());
                            });
                          } else {
                            setState(() {
                              recordError = 1;
                              colorR = Colors.red;
                            });
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Card(
            elevation: 12,
            child: ExpansionTile(
              title: Text("Previous Record",
                  style: TextStyle(fontSize: 29, color: Colors.indigo[300])),
              trailing: Icon(Icons.arrow_drop_down,
                  size: 20, color: Colors.indigo[300]),
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      TextFormField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 2.0),
                              ),
                              labelText: "Search Here",
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.black45),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueAccent, width: 2.0))),
                          onChanged: (String s) {}),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 35,
                          columns: [
                            DataColumn(
                                label: Text(
                              "Date",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            )),
                            DataColumn(
                              label: Text(
                                "Counter",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Delete",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                          rows: const <DataRow>[
                            DataRow(
                              cells: <DataCell>[
                                DataCell(Text('2021-03-03 21:43:01')),
                                DataCell(Text('1000.00')),
                                DataCell(Icon(Icons.delete,
                                    color: Colors.red, size: 20)),
                              ],
                            ),
                            DataRow(
                              cells: <DataCell>[
                                DataCell(Text('2021-03-03 21:43:01')),
                                DataCell(Text('1000.00')),
                                DataCell(Text('')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(
                        color: Colors.black,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// }
