import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/screens/a_my_bottom_appbar.dart';
import 'package:taxi_driver/screens/a_my_drawer.dart';
import 'package:taxi_driver/screens/e_journey_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  //final auth = FirebaseAuth.instance;
  CollectionReference driversCollection =
      FirebaseFirestore.instance.collection("drivers");
  bool showtextp = false;
  bool showtexts = false;

  getJourneys(docID) async {
    //List<dynamic> journeyList = [];
    return await FirebaseFirestore.instance
        .collection('journeys')
        .doc(docID)
        //.snapshots();
        .get();
  }

  //bool isFree = false;
  String currentJourney = '';

  getUser() async {
    var user = await driversCollection.doc(auth.currentUser!.uid).get();

    currentJourney = user['currentJourney'];

    return user;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (auth != null) {
      getUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    //final auth = FirebaseAuth.instance;
    return Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            "History",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FutureBuilder(
            future: getUser(),
            builder: (context, AsyncSnapshot snapdoc) {
              if (snapdoc.hasData) {
                if (!snapdoc.data!['isFree']) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.height * 0.1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return JourneyScreen(
                              docID: snapdoc.data!['currentJourney']);
                        }));
                      },
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Icons.directions,
                        size: MediaQuery.of(context).size.height * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              }

              return const Center(child: CircularProgressIndicator());
            }),
        bottomNavigationBar:BottomAppBar(
          //color: Colors.pink,
          child: MyBottomAppbar(page: 'history'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                ),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('drivers')
                        .doc(auth.currentUser!.uid)
                        .collection('journey_s')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Please take your first ride :))",
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

                                if (snapdoc.data['status'] == 'success') {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        vertical: 3),
                                    child: SizedBox(
                                      height: 90,
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
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
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
                                                      TextField(
                                                        readOnly: true,
                                                        controller:
                                                            TextEditingController(
                                                                text: snapdoc
                                                                        .data?[
                                                                    'placeName']),
                                                        decoration:
                                                            const InputDecoration(
                                                          enabled: false,
                                                          border:
                                                              InputBorder.none,
                                                          icon: Icon(Icons
                                                              .location_pin),
                                                        ),
                                                      ),
                                                      Text(
                                                        DateFormat.yMMMd()
                                                            .add_jm()
                                                            .format((snapdoc
                                                                        .data![
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
                                                snapdoc.data!['status'] ==
                                                        'waiting_passenger'
                                                    ? SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'journeys')
                                                              .doc(snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .id)
                                                              .collection(
                                                                  'passenger_s')
                                                              .snapshots(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      QuerySnapshot>
                                                                  snapcol) {
                                                            if (!snapcol
                                                                .hasData) {
                                                              return const Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                color: Colors
                                                                    .greenAccent,
                                                              ));
                                                            }

                                                            return TextField(
                                                              readOnly: true,
                                                              controller:
                                                                  TextEditingController(
                                                                      text:
                                                                          "${snapcol.data!.docs.length}/${snapdoc.data!['person']}"),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              decoration:
                                                                  const InputDecoration(
                                                                isDense: true,
                                                                enabled: false,
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                icon: Icon(
                                                                  Icons.people,
                                                                  size: 25,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: const Text(
                                                          'Success',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ))
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                }

                                /////////////////////////////////

                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 0, 18, 3),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'In progess',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 120,
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
                                                    MainAxisAlignment
                                                        .spaceAround,
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
                                                        TextField(
                                                          readOnly: true,
                                                          controller:
                                                              TextEditingController(
                                                                  text: snapdoc
                                                                          .data?[
                                                                      'placeName']),
                                                          decoration:
                                                              const InputDecoration(
                                                            enabled: false,
                                                            border: InputBorder
                                                                .none,
                                                            icon: Icon(
                                                              Icons
                                                                  .location_pin,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .add_jm()
                                                              .format((snapdoc
                                                                          .data![
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
                                                  snapdoc.data!['status'] ==
                                                          'waiting_passenger'
                                                      ? SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          child: StreamBuilder(
                                                            stream: FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'journeys')
                                                                .doc(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id)
                                                                .collection(
                                                                    'passenger_s')
                                                                .snapshots(),
                                                            builder: (context,
                                                                AsyncSnapshot<
                                                                        QuerySnapshot>
                                                                    snapcol) {
                                                              if (!snapcol
                                                                  .hasData) {
                                                                return const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                  color: Colors
                                                                      .greenAccent,
                                                                ));
                                                              }

                                                              return TextField(
                                                                readOnly: true,
                                                                controller:
                                                                    TextEditingController(
                                                                        text:
                                                                            "${snapcol.data!.docs.length}/${snapdoc.data!['person']}"),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  isDense: true,
                                                                  enabled:
                                                                      false,
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .people,
                                                                    size: 25,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          child: (snapdoc.data![
                                                                      'status'] ==
                                                                  'waiting_driver')
                                                              ? const Text(
                                                                  'Waiting for driver',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                )
                                                              : (snapdoc.data![
                                                                          'status'] ==
                                                                      'traveling')
                                                                  ? const Text(
                                                                      'Traveling',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    )
                                                                  : Text(
                                                                      snapdoc.data![
                                                                          'status'],
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                        )
                                                ],
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: const Divider(
                                          thickness: 2,
                                          height: 50,
                                        ),
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
