import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/screens/a_my_bottom_appbar.dart';
import 'package:taxi_driver/screens/a_my_drawer.dart';
import 'package:taxi_driver/screens/e_journey_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  //final auth = FirebaseAuth.instance;
  CollectionReference driversCollection =
      FirebaseFirestore.instance.collection("drivers");
  bool showtextp = false;
  bool showtexts = false;
  List<String> list = <String>['All-time', 'Today', 'This week', 'This month'];
  String dropdownValue = 'All-time';

  getJourneys(docID) async {
    return await FirebaseFirestore.instance
        .collection('journeys')
        .doc(docID)
        //.snapshots();
        .get();
  }

  var todayIncome = 0.0;
  var weekIncome = 0.0;
  var monthIncome = 0.0;

  getTodayIncome() async {
    var today = DateTime.now();
    var timestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch);
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .collection('journey_s')
        .orderBy('timestamp', descending: true)
        .where('timestamp', isGreaterThanOrEqualTo: timestamp)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        var tmp = await FirebaseFirestore.instance
            .collection('journeys')
            .doc(element.id)
            .get();

        setState(() {
          todayIncome += tmp['cost'] as double;
        });
      });
    });
  }

  getWeekIncome() async {
    var today = DateTime.now();
    var sunday = (today.subtract(Duration(days: today.weekday)));

    var timestamp =
        Timestamp.fromMillisecondsSinceEpoch(sunday.millisecondsSinceEpoch);
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .collection('journey_s')
        .orderBy('timestamp', descending: true)
        .where('timestamp', isGreaterThanOrEqualTo: timestamp)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        var tmp = await FirebaseFirestore.instance
            .collection('journeys')
            .doc(element.id)
            .get();

        setState(() {
          weekIncome += tmp['cost'] as double;
        });
      });
    });
  }

  getMonthIncome() async {
    var today = DateTime.now();
    //today = DateTime(today.year, today.month);
    //print(DateTime(today.year, today.month));
    var timestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(today.year, today.month).millisecondsSinceEpoch);
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .collection('journey_s')
        .orderBy('timestamp', descending: true)
        .where('timestamp', isGreaterThanOrEqualTo: timestamp)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        var tmp = await FirebaseFirestore.instance
            .collection('journeys')
            .doc(element.id)
            .get();

        setState(() {
          monthIncome += tmp['cost'] as double;
        });
      });
    });
  }

  getQuery() {
    if (dropdownValue == 'Today') {
      var today = DateTime.now();
      var timestamp = Timestamp.fromMillisecondsSinceEpoch(
          DateTime(today.year, today.month, today.day).millisecondsSinceEpoch);
      return FirebaseFirestore.instance
          .collection('drivers')
          .doc(auth.currentUser!.uid)
          .collection('journey_s')
          .orderBy('timestamp', descending: true)
          .where('timestamp', isGreaterThanOrEqualTo: timestamp)
          .snapshots();
    } else if (dropdownValue == 'This week') {
      var today = DateTime.now();
      var sunday = (today.subtract(Duration(days: today.weekday)));

      var timestamp =
          Timestamp.fromMillisecondsSinceEpoch(sunday.millisecondsSinceEpoch);
      return FirebaseFirestore.instance
          .collection('drivers')
          .doc(auth.currentUser!.uid)
          .collection('journey_s')
          .orderBy('timestamp', descending: true)
          .where('timestamp', isGreaterThanOrEqualTo: timestamp)
          .snapshots();
    } else if (dropdownValue == 'This week') {
      var today = DateTime.now();
      var timestamp = Timestamp.fromMillisecondsSinceEpoch(
          DateTime(today.year, today.month).millisecondsSinceEpoch);
      return FirebaseFirestore.instance
          .collection('drivers')
          .doc(auth.currentUser!.uid)
          .collection('journey_s')
          .orderBy('timestamp', descending: true)
          .where('timestamp', isGreaterThanOrEqualTo: timestamp)
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .collection('journey_s')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getTodayIncome();
    getWeekIncome();
    getMonthIncome();
  }

  @override
  Widget build(BuildContext context) {
    //final auth = FirebaseAuth.instance;
    return Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          //        flexibleSpace: Container(
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: <Color>[Colors.black, Colors.blue]),
          //   ),
          // ),
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            "History & Income",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          //color: Colors.pink,
          child: MyBottomAppbar(
            page: 'history',
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 30, 18, 10),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 1.0],
                      colors: [
                        Colors.deepOrange.shade400,
                        Colors.orange.shade300,
                      ],
                    ),
                    color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today income : ',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Colors.grey[850],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Text(
                              ' $todayIncome฿',
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  inherit: false,
                                  color: Colors.grey[850],
                                  fontSize: 45),
                            ),
                          ],
                        ),
                        Text(
                          'This week : $weekIncome฿',
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'This month : $monthIncome฿',
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const Divider(
                    thickness: 2,
                    height: 25,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: TextStyle(color: Colors.grey[800]),
                    underline: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: StreamBuilder(
                    stream: getQuery(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        ));
                      } else if (snapshot.data!.docs.isEmpty) {
                        return Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 150),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "You don't have any journey in this period.",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          return FutureBuilder(
                              future:
                                  getJourneys(snapshot.data!.docs[index].id),
                              builder: (context, AsyncSnapshot snapdoc) {
                                if (!snapdoc.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.grey,
                                  ));
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(25, 0, 25, 3),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return JourneyScreen(
                                                    docID: snapshot
                                                        .data!.docs[index].id);
                                              }));
                                            },
                                            style: ButtonStyle(
                                              elevation:
                                                  MaterialStateProperty.all(1),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                      side: const BorderSide(
                                                          width: 0.5,
                                                          color: Color.fromARGB(
                                                              255,
                                                              213,
                                                              213,
                                                              213)))),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      const Color.fromARGB(
                                                          255, 255, 255, 255)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .location_pin,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                snapdoc.data?[
                                                                    'placeName'],
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .add_jm()
                                                              .format((snapshot
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'timestamp'])
                                                                  .toDate()),
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: FutureBuilder(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'journeys')
                                                          .doc(snapshot.data!
                                                              .docs[index].id)
                                                          .get(),
                                                      //.collection(
                                                      //   'passenger_s')
                                                      //.snapshots(),
                                                      builder: (context,
                                                          AsyncSnapshot
                                                              snapcol) {
                                                        if (!snapcol.hasData) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                            color: Colors.pink,
                                                          ));
                                                        }

                                                        return TextField(
                                                          readOnly: true,
                                                          controller:
                                                              TextEditingController(
                                                                  text:
                                                                      "${snapcol.data['cost']}฿"),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                          decoration:
                                                              const InputDecoration(
                                                            isDense: true,
                                                            enabled: false,
                                                            border: InputBorder
                                                                .none,
                                                            icon: Icon(
                                                              Icons.paid,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }),
                      );
                    }),
              ),
            ],
          ),
        ));
  }
}
