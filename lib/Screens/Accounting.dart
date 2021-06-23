import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_petrol_station/Widgets/Drawer.dart';
import 'package:intl/intl.dart';

class Accounting extends StatefulWidget {
  @override
  _AccountingState createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {
  String dropdownValue;
  int pumpid;
  int lastrecord;
  int totalbill = 0, totalprofit = 0;
  int sumrecords;
  DateTime dt;
  int price = 0, profit = 0;
  var formatter = NumberFormat('#,##,000');
  int button_type = -1;
  bool isloading = false;
  DateTime last_record_date;
  int previous_record_id;
  int contid; // for get the container id for specific pump
  String contname; //get container
  int calculationprofit, calculationprice;
  Fuel F;
  int previous_record;
  int idob;
  String nameob;
  var fuel_types;
  int pumpidtdy;
  TextEditingController t1 = new TextEditingController();
  TextEditingController t2 = new TextEditingController();
  int cont_id;
    String cont_name;

  DateTime lastpricedate, lastprofitdate;
  DateTime datetimetoday = DateTime.now();
  DateFormat ff;
  DateTime todayy;
  int container_id_tdy;
  int totalbilltdy = 0, totalprofittoday = 0;
  int lastpricetdy, lastprofittdy;
  int previous_price,previous_profit;
  DateTime previous_price_date;
  int sum_littres=0;

  DateTime T1,T2;
  List<DateTime> AllDateTime;
  void getlastreacord() async {
    setState(() {
      isloading = true;
    });
    await FirebaseFirestore.instance
        .collection("Stations")
        .doc("Petrol Station 1")
        .collection("Pump")
        .get()
        .then((val) async => {
              if (val.docs.length > 0)
                {
                  print("Fet 1"),
                  for (int i = 0; i < val.docs.length; i++)
                    {
                      pumpid = val.docs[i].get("Pump_Id"),

                      contid = val.docs[i].get("Container_Id"),
                      print('pumpidddddddddddddddddddd ${pumpid}'),
                      print('contiddddddddddddddddddd ${contid}'),
                      await FirebaseFirestore.instance
                          .collection('Stations')
                          .doc("Petrol Station 1")
                          .collection('Container')
                          .where('Container_Id', isEqualTo: contid)
                          .get()
                          .then((val) async => {
                                contname = val.docs[0].get("Container_Name"),
                                print("Nameee in theeeennnnn ${contname}")
                              }),
                      // getContainerName(contid),
                      print('NAmeeeeeeeeeeeeeeeeeeeee ${contname}'),
                      await FirebaseFirestore.instance
                          .collection('Stations')
                          .doc("Petrol Station 1")
                          .collection('Pump_Record')
                          .where('Pump_Id', isEqualTo: pumpid)
                          .orderBy('Pump_Record_Id', descending: true)
                          .get()
                          .then((val) async => {
                                if (val.docs.length > 0)
                                  {
                                    print("FETTTTTTTTTTTTTTTTTTTTTTT2"),
                                    lastrecord = val.docs[0].get("Record"),
                                    print(
                                        "Lasttttttttttttttttt record ${lastrecord}"),
                                    dt = DateTime.tryParse(
                                        (val.docs[0].get("Record_Time"))
                                            .toDate()
                                            .toString()),
                                    await FirebaseFirestore.instance
                                        .collection('Stations')
                                        .doc("Petrol Station 1")
                                        .collection('Price-Profit')
                                        .where('Fuel_Type_Id',
                                            isEqualTo: contname)
                                        .where('Date',
                                            isLessThan:
                                                val.docs[0].get("Record_Time"))
                                        .get()
                                        .then((val) => {
                                              if (val.docs.length > 0)
                                                {
                                                  setState(() {
                                                    price = val.docs[
                                                            val.docs.length - 1]
                                                        .get("Official_Price");
                                                    calculationprice =
                                                        lastrecord * price;
                                                  }),
                                                  print(
                                                      "get it price : ${price}")
                                                }
                                            }),
                                    await FirebaseFirestore.instance
                                        .collection('Stations')
                                        .doc("Petrol Station 1")
                                        .collection('Price-Profit')
                                        .where('Fuel_Type_Id',
                                            isEqualTo: contname)
                                        .where('Date',
                                            isLessThan:
                                                val.docs[0].get("Record_Time"))
                                        .get()
                                        .then((val) => {
                                              if (val.docs.length > 0)
                                                {
                                                  setState(() {
                                                    profit = val.docs[
                                                            val.docs.length - 1]
                                                        .get("Official_Profit");
                                                    calculationprofit =
                                                        lastrecord * profit;
                                                  }),
                                                  print(
                                                      "get it profit : ${profit}")
                                                }
                                            }),
                                    print(
                                        "calculationpriceeeeeeeeeeeeeeeeeeeeee : ${calculationprice}"),
                                    print(
                                        "calculationprofittttttttttttttttttt : ${calculationprofit}"),
                                  }
                                else
                                  {
                                    print("elseeeee"),
                                  }
                              }),
                      totalbill = totalbill + calculationprice,
                      totalprofit = totalprofit + calculationprofit,
                    }
                }
            });

    setState(() {
      isloading = false;
      button_type = 3;
      totalbill;
      totalprofit;
    });

    print("Total bill is ${totalbill}");
    print("Total profit is ${totalprofit}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asyncmeth();
    // print('IN BUILD ${fuel_types[1].name.toString()}');
  }

  void asyncmeth() async {
    await getarrayoffueltypes();
    setState(() {
      dropdownValue = fuel_types[0].name.toString();
    });
  }

  void getarrayoffueltypes() async {
    fuel_types = new List<Fuel>();
    fuel_types.add(new Fuel(0, "All Fuel Type"));
    await FirebaseFirestore.instance
        .collection("Stations")
        .doc("Petrol Station 1")
        .collection("Fuel_Type")
        .get()
        .then((val) => {
              for (int i = 0; i < val.docs.length; i++)
                {
                  idob = val.docs[i].get("Fuel_Type_Id"),
                  nameob = val.docs[i].get("Fuel_Type_Name").toString(),
                  F = new Fuel(idob, nameob),
                  print("OBJECTTT ${F.name}"),
                  fuel_types.add(F),
                },
            });

    print(fuel_types);
  }

  void gettoday() async {
    sum_littres=0;
    totalbilltdy = 0;
    totalprofittoday = 0;
    
    if (dropdownValue == "All Fuel Type") {
      await FirebaseFirestore.instance
          .collection('Stations')
          .doc("Petrol Station 1")
          .collection('Container')
          .get()
          .then((val) async => {
                if (val.docs.length > 0)
                  {
                    for (int k = 0; k < val.docs.length; k++)
                      { sum_littres=0,
                        cont_id = val.docs[k].get("Container_Id"),
                        cont_name = val.docs[k].get("Container_Name"),
                        await FirebaseFirestore.instance
                            .collection('Stations')
                            .doc("Petrol Station 1")
                            .collection('Price-Profit')
                            .where('Fuel_Type_Id', isEqualTo: cont_name)
                            .orderBy('Date', descending: true)
                            .get()
                            .then((val) async => {
                                  if (val.docs.length > 0)
                                    {
                                      if(val.docs.length>1){
                                                  previous_price_date = DateTime.tryParse(
                                          (val.docs[1].get("Date"))
                                              .toDate()
                                              .toString()),
                                            previous_price=   val.docs[1].get("Official_Price"),
                                            previous_profit =   val.docs[1].get("Official_Profit"),

                                      },
                                      lastpricetdy =
                                          val.docs[0].get("Official_Price"),
                                      lastprofittdy =
                                          val.docs[0].get("Official_Profit"),
                                      lastpricedate = DateTime.tryParse(
                                          (val.docs[0].get("Date"))
                                              .toDate()
                                              .toString()),
                                      print(
                                          'Dateeeeeeeeeeeeee ${lastpricedate}'),
                                      print('priceeeeeee ${lastpricetdy}'),
                                      print('profittttt ${lastprofittdy}'),

                                      await FirebaseFirestore.instance
                                              .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Pump')
                                              .where('Container_Id',
                                                  isEqualTo: cont_id)
                                              .get()
                                              .then((val3) async => {
                                                  if(val3.docs.length>0){

                                                    for(int l=0;l<val3.docs.length;l++){
                                                      pumpidtdy = val3.docs[l].get("Pump_Id"),
                                                              await FirebaseFirestore.instance.collection("Stations").doc("Petrol Station 1").collection("Pump_Record").where("Pump_Id", isEqualTo: pumpidtdy).where("Container_Id", isEqualTo: contid).orderBy("Pump_Record_Id").get().then((val1) async => {
                                             if (val1.docs.length > 0)
                                                {
                                                  last_record_date = DateTime.tryParse(
                                          (val1.docs[val1.docs.length-1].get("Record_Time"))
                                              .toDate()
                                              .toString()),
                                                  
                                                 
                                                  print("Last reacorddd dateeee.....${last_record_date}"),

                                    if (lastpricedate.day ==
                                              datetimetoday.day &&
                                          lastpricedate.month ==
                                              datetimetoday.month &&
                                          lastpricedate.year ==
                                              datetimetoday.year && lastpricedate.compareTo(last_record_date)<0 )
                                        {
                                          print("if todayyyyyyyyyyy"),
                                          await FirebaseFirestore.instance
                                              .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Pump')
                                              .where('Container_Id',
                                                  isEqualTo: cont_id)
                                              .get()
                                              .then((val) async => {
                                                    if (val.docs.length > 0)
                                                      {
                                                        for (int i = 0;
                                                            i < val.docs.length;
                                                            i++)
                                                          {
                                                            pumpidtdy = val
                                                                .docs[i]
                                                                .get("Pump_Id"),
                                                            //get pump record
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Stations')
                                                                .doc(
                                                                    "Petrol Station 1")
                                                                .collection(
                                                                    'Pump_Record')
                                                                .where(
                                                                    "Pump_Id",
                                                                    isEqualTo:
                                                                        pumpidtdy)
                                                                .where(
                                                                    "Record_Time",
                                                                    isGreaterThanOrEqualTo:
                                                                        lastpricedate)
                                                                .get()
                                                                .then(
                                                                    (val) async =>
                                                                        {
                                                                          if (val.docs.length >
                                                                              0)
                                                                            {
                                                                              for (int j = 0; j < val.docs.length; j++)
                                                                                {
                                                                                  if (val.docs[j].get("Pump_Record_Id") == 1)
                                                                                    {
                                                                                      totalbilltdy = totalbilltdy + (val.docs[j].get("Record") * lastpricetdy),
                                                                                      totalprofittoday = totalprofittoday + (val.docs[j].get("Record") * lastprofittdy),
                                                                                       sum_littres = sum_littres+ val.docs[j].get("Record"),
                                                                                 
                                                                                      print("Torla billll a ${totalbilltdy}"),
                                                                                      print("Torla profittt a ${totalprofittoday}"),
                                                                                    }
                                                                                  else
                                                                                    {
                                                                                      await FirebaseFirestore.instance.collection("Stations").doc("Petrol Station 1").collection("Pump_Record").where("Pump_Id", isEqualTo: pumpidtdy).where("Container_Id", isEqualTo: cont_id).orderBy("Pump_Record_Id").get().then((val1) => {
                                                                                            if (val1.docs.length > 0)
                                                                                              {
                                                                                                if (val1.docs.length > 1)
                                                                                                  {
                                                                                                     
                                                                                                    previous_record_id = val1.docs[val1.docs.length - 2].get("Pump_Record_Id"),
                                                                                                    print("previous idddd ${previous_record_id}"),
                                                                                                    previous_record = val1.docs[val1.docs.length - 2].get("Record"),
                                                                                                    print("previous record ${previous_record}"),
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record") - previous_record) * lastpricetdy),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record") - previous_record) * lastprofittdy),
                                                                                                    
                                                                                                    sum_littres = sum_littres+ ( val.docs[j].get("Record") - previous_record) ,
                                                                                 
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                                else
                                                                                                  {
                                                                                                     sum_littres = sum_littres+ val.docs[j].get("Record"),
                                                                                 
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record")) * lastpricetdy),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record")) * lastprofittdy),
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                              }
                                                                                          }),
                                                                                    }
                                                                                },
                                                                                print("sum_littres IS ${sum_littres}")
                                                                            }
                                                                        }),
                                                          }
                                                      }
                                                  })
                                        }
                                      else
                                        {
                                          print(
                                              "Esleeeeeeeeeeeeeeeeeeeeeeeeeeeeee"),
                                              
                                          /* int previous_price,previous_profit;
  DateTime previous_price_data;*/
                                              if(previous_price!=null && previous_profit!=null && previous_price_date!=null ){

                                            await FirebaseFirestore.instance
                                              .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Pump')
                                              .where('Container_Id',
                                                  isEqualTo: cont_id)
                                              .get()
                                              .then((val) async => {
                                                    if (val.docs.length > 0)
                                                      {
                                                        print(
                                                            "iff length >0 pump container id"),
                                                        for (int i = 0;
                                                            i < val.docs.length;
                                                            i++)
                                                          {
                                                            pumpidtdy = val
                                                                .docs[i]
                                                                .get("Pump_Id"),
                                                                print("previous_price_date ${previous_price_date}"),
                                                                print("previous_price_price ${previous_price}"),
                                                                print("previous_price_profit ${previous_profit}"),
                                                                print("pumpidtdy ${pumpidtdy}"),
                                                                print("todayy ${todayy}"),
                                                            //get pump record
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Stations')
                                                                .doc(
                                                                    "Petrol Station 1")
                                                                .collection(
                                                                    'Pump_Record')
                                                                .where(
                                                                    "Pump_Id",
                                                                    isEqualTo:
                                                                        pumpidtdy)
                                                                .where(
                                                                    "Record_Time",
                                                                    isGreaterThanOrEqualTo:
                                                                        previous_price_date)
                                                                .where(
                                                                    "Record_Time",
                                                                    isGreaterThanOrEqualTo:
                                                                        todayy)
                                                                .get()
                                                                .then(
                                                                    (val) async =>
                                                                        {
                                                                          if (val.docs.length >
                                                                              0)
                                                                            {
                                                                              print('if length > 0  record > today'),
                                                                              //sum_littres=0,
                                                                              for (int j = 0; j < val.docs.length; j++)
                                                                                {
                                                                                 
                                                                                  if (val.docs[j].get("Pump_Record_Id") == 1)
                                                                                    {
                                                                                        sum_littres = sum_littres+ val.docs[j].get("Record"),
                                                                                 
                                                                                      totalbilltdy = totalbilltdy + (val.docs[j].get("Record") * previous_price),
                                                                                      totalprofittoday = totalprofittoday + (val.docs[j].get("Record") * previous_profit),
                                                                                      print("Torla billll a ${totalbilltdy}"),
                                                                                      print("Torla profittt a ${totalprofittoday}"),
                                                                                    }
                                                                                  else
                                                                                    {
                                                                                      await FirebaseFirestore.instance.collection("Stations").doc("Petrol Station 1").collection("Pump_Record").where("Pump_Id", isEqualTo: pumpidtdy).where("Container_Id", isEqualTo: contid).orderBy("Pump_Record_Id").get().then((val1) => {
                                                                                            if (val1.docs.length > 0)
                                                                                              {
                                                                                                if (val1.docs.length > 1)
                                                                                                  {
                                                                                                    previous_record_id = val1.docs[val1.docs.length - 2].get("Pump_Record_Id"),
                                                                                                    print("previous idddd ${previous_record_id}"),
                                                                                                    previous_record = val1.docs[val1.docs.length - 2].get("Record"),
                                                                                                    print("previous record ${previous_record}"),
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record") - previous_record) * previous_price),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record") - previous_record) * previous_profit),
                                                                                                    sum_littres = sum_littres+ (val.docs[j].get("Record") - previous_record),
                                                                                 
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                                else
                                                                                                  {
                                                                                                      sum_littres = sum_littres+ val.docs[j].get("Record"),
                                                                                 
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record")) * previous_price),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record")) * previous_profit),
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                              }
                                                                                          }),
                                                                                    }
                                                                                },
                                                                                
                                                                            }
                                                                        }),
                                                                       

                                                          },
                                                         
                                                      }
                                                  }),

                                              }
                                          
                                        },

                                                  }}),
                                                    }
                                                    
                                                 
                                                  },
                                              }),
                                      

                                      
                                    }
                                }),
                    print("sum littre ${sum_littres} for container ${cont_name}"),

                      }
                  }
              });
      print('TOTAL BILL TODAYYY ${totalbilltdy}');
      print('TOTAL profit TODAYYY ${totalprofittoday}');
      print('TOTAL litree TODAYYY ${sum_littres}');
      
    } 
    
    
    else {
      sum_littres=0;
      totalbilltdy = 0;
      totalprofittoday = 0;

      /// specfic fuel
      //get date of the last price
      await FirebaseFirestore.instance
          .collection('Stations')
          .doc("Petrol Station 1")
          .collection('Price-Profit')
          .where('Fuel_Type_Id', isEqualTo: dropdownValue)
          .orderBy('Date', descending: true)
          .get()
          .then((val) async => {
                if (val.docs.length > 0)
                  {
                    if(val.docs.length>1){
                              previous_price_date = DateTime.tryParse(
                                          (val.docs[1].get("Date"))
                                              .toDate()
                                              .toString()),
                                            previous_price=   val.docs[1].get("Official_Price"),
                                            previous_profit =   val.docs[1].get("Official_Profit"),

                                      },
                                      lastpricetdy =
                                          val.docs[0].get("Official_Price"),
                                      lastprofittdy =
                                          val.docs[0].get("Official_Profit"),
                                      lastpricedate = DateTime.tryParse(
                                          (val.docs[0].get("Date"))
                                              .toDate()
                                              .toString()),
                                      print(
                                          'Dateeeeeeeeeeeeee ${lastpricedate}'),
                                      print('priceeeeeee ${lastpricetdy}'),
                                      print('profittttt ${lastprofittdy}'),
                                       // get container id for this fuel name 


                                       await FirebaseFirestore.instance
                                       .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Container')
                                              .where('Container_Name',
                                                  isEqualTo: dropdownValue)
                                              .get()
                                              .then((val) async => {
                                                  if(val.docs.length>0){
                                                      
                                                     cont_id = val.docs[0].get("Container_Id"),

 await FirebaseFirestore.instance
                                              .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Pump')
                                              .where('Container_Id',
                                                  isEqualTo: cont_id)
                                              .get()
                                              .then((val3) async => {
                                                  if(val3.docs.length>0){

                                                    for(int l=0;l<val3.docs.length;l++){
                                                      pumpidtdy = val3.docs[l].get("Pump_Id"),
                                                              await FirebaseFirestore.instance.collection("Stations").doc("Petrol Station 1").collection("Pump_Record").where("Pump_Id", isEqualTo: pumpidtdy).where("Container_Id", isEqualTo: contid).orderBy("Pump_Record_Id").get().then((val1) async => {
                                             if (val1.docs.length > 0)
                                                {
                                                  last_record_date = DateTime.tryParse(
                                          (val1.docs[val1.docs.length-1].get("Record_Time"))
                                              .toDate()
                                              .toString()),
                                                  
                                                 
                                                  print("Last reacorddd dateeee.....${last_record_date}"),

                                    if (lastpricedate.day ==
                                              datetimetoday.day &&
                                          lastpricedate.month ==
                                              datetimetoday.month &&
                                          lastpricedate.year ==
                                              datetimetoday.year && lastpricedate.compareTo(last_record_date)<0 )
                                        {
                                          print("if todayyyyyyyyyyy"),
                                          await FirebaseFirestore.instance
                                              .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Pump')
                                              .where('Container_Id',
                                                  isEqualTo: cont_id)
                                              .get()
                                              .then((val) async => {
                                                    if (val.docs.length > 0)
                                                      {
                                                        for (int i = 0;
                                                            i < val.docs.length;
                                                            i++)
                                                          {
                                                            pumpidtdy = val
                                                                .docs[i]
                                                                .get("Pump_Id"),
                                                            //get pump record
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Stations')
                                                                .doc(
                                                                    "Petrol Station 1")
                                                                .collection(
                                                                    'Pump_Record')
                                                                .where(
                                                                    "Pump_Id",
                                                                    isEqualTo:
                                                                        pumpidtdy)
                                                                .where(
                                                                    "Record_Time",
                                                                    isGreaterThanOrEqualTo:
                                                                        lastpricedate)
                                                                .get()
                                                                .then(
                                                                    (val) async =>
                                                                        {
                                                                          if (val.docs.length >
                                                                              0)
                                                                            {
                                                                              for (int j = 0; j < val.docs.length; j++)
                                                                                {
                                                                                   sum_littres = sum_littres+ val.docs[j].get("Record"),
                                                                                 
                                                                                  if (val.docs[j].get("Pump_Record_Id") == 1)
                                                                                    {
                                                                                      totalbilltdy = totalbilltdy + (val.docs[j].get("Record") * lastpricetdy),
                                                                                      totalprofittoday = totalprofittoday + (val.docs[j].get("Record") * lastprofittdy),
                                                                                      print("Torla billll a ${totalbilltdy}"),
                                                                                      print("Torla profittt a ${totalprofittoday}"),
                                                                                    }
                                                                                  else
                                                                                    {
                                                                                      await FirebaseFirestore.instance.collection("Stations").doc("Petrol Station 1").collection("Pump_Record").where("Pump_Id", isEqualTo: pumpidtdy).where("Container_Id", isEqualTo: cont_id).orderBy("Pump_Record_Id").get().then((val1) => {
                                                                                            if (val1.docs.length > 0)
                                                                                              {
                                                                                                if (val1.docs.length > 1)
                                                                                                  {
                                                                                                    previous_record_id = val1.docs[val1.docs.length - 2].get("Pump_Record_Id"),
                                                                                                    print("previous idddd ${previous_record_id}"),
                                                                                                    previous_record = val1.docs[val1.docs.length - 2].get("Record"),
                                                                                                    print("previous record ${previous_record}"),
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record") - previous_record) * lastpricetdy),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record") - previous_record) * lastprofittdy),
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                                else
                                                                                                  {
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record")) * lastpricetdy),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record")) * lastprofittdy),
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                              }
                                                                                          }),
                                                                                    }
                                                                                },
                                                                               
                                                                            }
                                                                        }),
                                                          }
                                                      }
                                                  })
                                        }
                                      else
                                        {
                                          print(
                                              "Esleeeeeeeeeeeeeeeeeeeeeeeeeeeeee"),
                                              
                                          /* int previous_price,previous_profit;
  DateTime previous_price_data;*/
                                              if(previous_price!=null && previous_profit!=null && previous_price_date!=null ){

                                            await FirebaseFirestore.instance
                                              .collection('Stations')
                                              .doc("Petrol Station 1")
                                              .collection('Pump')
                                              .where('Container_Id',
                                                  isEqualTo: cont_id)
                                              .get()
                                              .then((val) async => {
                                                    if (val.docs.length > 0)
                                                      {
                                                        print(
                                                            "iff length >0 pump container id"),
                                                        for (int i = 0;
                                                            i < val.docs.length;
                                                            i++)
                                                          {
                                                            pumpidtdy = val
                                                                .docs[i]
                                                                .get("Pump_Id"),
                                                            //get pump record
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Stations')
                                                                .doc(
                                                                    "Petrol Station 1")
                                                                .collection(
                                                                    'Pump_Record')
                                                                .where(
                                                                    "Pump_Id",
                                                                    isEqualTo:
                                                                        pumpidtdy)
                                                                .where(
                                                                    "Record_Time",
                                                                    isGreaterThanOrEqualTo:
                                                                        previous_price_date)
                                                                .where(
                                                                    "Record_Time",
                                                                    isGreaterThanOrEqualTo:
                                                                        todayy)
                                                                .get()
                                                                .then(
                                                                    (val) async =>
                                                                        {
                                                                          if (val.docs.length >
                                                                              0)
                                                                            {
                                                                              print('if length > 0  record > today'),
                                                                              for (int j = 0; j < val.docs.length; j++)
                                                                                {
                                                                                   sum_littres = sum_littres+ val.docs[j].get("Record"),
                                                                                 
                                                                                  if (val.docs[j].get("Pump_Record_Id") == 1)
                                                                                    {
                                                                                      totalbilltdy = totalbilltdy + (val.docs[j].get("Record") * previous_price),
                                                                                      totalprofittoday = totalprofittoday + (val.docs[j].get("Record") * previous_profit),
                                                                                      print("Torla billll a ${totalbilltdy}"),
                                                                                      print("Torla profittt a ${totalprofittoday}"),
                                                                                    }
                                                                                  else
                                                                                    {
                                                                                      await FirebaseFirestore.instance.collection("Stations").doc("Petrol Station 1").collection("Pump_Record").where("Pump_Id", isEqualTo: pumpidtdy).where("Container_Id", isEqualTo: contid).orderBy("Pump_Record_Id").get().then((val1) => {
                                                                                            if (val1.docs.length > 0)
                                                                                              {
                                                                                                if (val1.docs.length > 1)
                                                                                                  {
                                                                                                    previous_record_id = val1.docs[val1.docs.length - 2].get("Pump_Record_Id"),
                                                                                                    print("previous idddd ${previous_record_id}"),
                                                                                                    previous_record = val1.docs[val1.docs.length - 2].get("Record"),
                                                                                                    print("previous record ${previous_record}"),
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record") - previous_record) * previous_price),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record") - previous_record) * previous_profit),
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                                else
                                                                                                  {
                                                                                                    totalbilltdy = totalbilltdy + ((val.docs[j].get("Record")) * previous_price),
                                                                                                    totalprofittoday = totalprofittoday + ((val.docs[j].get("Record")) * previous_profit),
                                                                                                    print("Torla billll a ${totalbilltdy}"),
                                                                                                    print("Torla profittt a ${totalprofittoday}"),
                                                                                                  }
                                                                                              }
                                                                                          }),
                                                                                    },
                                                                                           print("sum_littres is  ${sum_littres}"),

                                                                                }
                                                                                
                                                                            }
                                                                        }),
                                                          }
                                                      }
                                                  }),

                                              }
                                          
                                        },

                                                  }}),
                                                    }
                                                    
                                                 
                                                  },
                                              }),

                                                     
                                                  }}),

                                     
                                      

                  }
              });
    }
  }

    List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(
       DateTime(
          startDate.year, 
          startDate.month, 
          // In Dart you can set more than. 30 days, DateTime will do the trick
          startDate.day + i)
      );
    }
    return days;
}

  void submitbtn() async{
    T1 = ff.parse(t1.text);
    T2 = ff.parse(t2.text);
    
    print("T1111 ${T1}");
    print("T1111 ${T1}");
    
    AllDateTime = getDaysInBeteween(T1,T2);
    //print(AllDateTime);  
      if(dropdownValue == "All Fuel Type"){
          for(int i = 0 ;i<AllDateTime.length;i++){

              await FirebaseFirestore.instance
          .collection('Stations')
          .doc("Petrol Station 1")
          .collection('Container')
          .get()
          .then((val) async => {
                if (val.docs.length > 0)
                  {
                    for (int k = 0; k < val.docs.length; k++)
                      {
                        cont_id = val.docs[k].get("Container_Id"),
                        cont_name = val.docs[k].get("Container_Name"),
                        if(i==AllDateTime.length-1){
                           await FirebaseFirestore.instance
                          .collection('Stations')
                          .doc("Petrol Station 1")
                          .collection('Price-Pofit')
                          .where('Fuel_Type_Id' ,isEqualTo : cont_name)
                          .where('Date' , isGreaterThanOrEqualTo: AllDateTime[i])
                          
                          .get()
                          .then((value) => {
                                  if(value.docs.length>0){
                                     lastpricetdy =
                                          val.docs[0].get("Official_Price"),
                                      lastprofittdy =
                                          val.docs[0].get("Official_Profit"),
                                      lastpricedate = DateTime.tryParse(
                                          (val.docs[0].get("Date"))
                                              .toDate()
                                              .toString()),
                                              print("Prices is ${lastpricetdy}"),
                                              
                                  }
                          }),
                        }else{
                           await FirebaseFirestore.instance
                          .collection('Stations')
                          .doc("Petrol Station 1")
                          .collection('Price-Pofit')
                          .where('Fuel_Type_Id' ,isEqualTo : cont_name)
                          .where('Date' , isGreaterThanOrEqualTo: AllDateTime[i])
                          .where('Date' , isLessThanOrEqualTo: AllDateTime[i+1] )

                          .get()
                          .then((value) => {
                                  if(value.docs.length>0){
                                     lastpricetdy =
                                          val.docs[0].get("Official_Price"),
                                      lastprofittdy =
                                          val.docs[0].get("Official_Profit"),
                                      lastpricedate = DateTime.tryParse(
                                          (val.docs[0].get("Date"))
                                              .toDate()
                                              .toString()),

                                              print("Prices is ${lastpricetdy}"),

                                  }
                          }),
                        }
                      }
                 }
                 });
          }
            
          }
      





      else{

      }
  }

  @override
  Widget build(BuildContext context) {
    // getarrayoffueltypes();
    ff = DateFormat('yyyy/MM/dd');
    todayy = ff.parse(ff.format(DateTime.now()));

    return Scaffold(
        backgroundColor: Colors.indigo[50],
        appBar: AppBar(
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
        drawer: getDrawer(),
        body: ListView(
          children: [
            Card(
                elevation: 12,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(children: [
                    SizedBox(height: 15),
                    Text("Fuel Type",
                        style: TextStyle(fontSize: 21, color: Colors.black45)),
                    SizedBox(height: 10),
                    Container(
                        width: 350.0,
                        height: 58,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1.0, style: BorderStyle.solid),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                isExpanded: true,
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue = newValue;
                                  });
                                },
                                items: fuel_types
                                    .map<DropdownMenuItem<String>>((f) {
                                  print(f.name.toString());
                                  return new DropdownMenuItem<String>(
                                      value: f.name.toString(),
                                      child: new Container(
                                        child: Center(
                                          child: new Text(
                                            '${f.name.toString()}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ));
                                }).toList()))),
                    SizedBox(height: 15),
                    Text("From Date",
                        style: TextStyle(fontSize: 21, color: Colors.black45)),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: t1,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.date_range_rounded,
                                color: Colors.indigo[300]),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2.0),
                            ),
                            labelText: "mm/dd/yy",
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Colors.black45),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueAccent, width: 2.0))),
                        onChanged: (String s) {}),
                    SizedBox(height: 15),
                    Text("To Date",
                        style: TextStyle(fontSize: 21, color: Colors.black45)),
                    SizedBox(height: 10),
                    TextFormField(
                        controller: t2,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.date_range_rounded,
                                color: Colors.indigo[300]),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2.0),
                            ),
                            labelText: "mm/dd/yy",
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Colors.black45),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueAccent, width: 2.0))),
                        onChanged: (String s) {}),
                    SizedBox(height: 10),
                    Divider(height: 10, thickness: 2, color: Colors.grey),
                    SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonTheme(
                            height: 50.0,
                            minWidth: 100,
                            child: RaisedButton(
                              color: Color(0xFF083369),
                              elevation: 6,
                              child: Text('Submit',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 19)),
                              onPressed: () {
                                submitbtn();
                              },
                            ),
                          ),
                          ButtonTheme(
                            height: 50.0,
                            minWidth: 100,
                            child: RaisedButton(
                              color: Color(0xFF083369),
                              elevation: 6,
                              child: Text('Today',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 19)),
                              onPressed: () {
                                gettoday();
                              },
                            ),
                          ),
                          ButtonTheme(
                            height: 50.0,
                            minWidth: 100,
                            child: RaisedButton(
                              color: Color(0xFF083369),
                              elevation: 6,
                              child: Text('Last Record',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 19)),
                              onPressed: () {
                                getlastreacord();
                              },
                            ),
                          ),
                        ]),
                    SizedBox(height: 10),
                  ]),
                )),
            SizedBox(height: 10),
            // totalbill;

            isloading == true
                ? CircularProgressIndicator()
                : button_type == 3
                    ? TotalCard(totalbill, totalprofit)
                    : Text(""),
          ],
        ));
  }
}

class TotalCard extends StatefulWidget {
  int bill, profit;
  TotalCard(int bill, int profit) {
    this.bill = bill;
    this.profit = profit;
  }

  @override
  _TotalCardState createState() => _TotalCardState();
}

class _TotalCardState extends State<TotalCard> {
  var formatter = NumberFormat('###,###,###');

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(7),
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(width: 4, color: Colors.green)),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Total',
                      style: TextStyle(fontSize: 35, color: Color(0xFF083369))),
                ),
              ),
              SizedBox(height: 10),
              Card(
                  child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Bill',
                        style: TextStyle(fontSize: 22, color: Colors.green)),
                  ),
                ),
                SizedBox(height: 30),
                Text('${formatter.format(widget.bill)}L.L',
                    style: TextStyle(fontSize: 35, color: Colors.green))
              ])),
              SizedBox(height: 10),
              Card(
                  child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Profit',
                        style: TextStyle(fontSize: 22, color: Colors.green)),
                  ),
                ),
                SizedBox(height: 30),
                Text('${formatter.format(widget.profit)}L.L',
                    style: TextStyle(fontSize: 35, color: Colors.green))
              ]))
            ],
          ),
        ));
  }
}

class Fuel {
  int id;
  String name;
  Fuel(int id, String name) {
    this.id = id;
    this.name = name;
  }
}


class specificfuel{

}
