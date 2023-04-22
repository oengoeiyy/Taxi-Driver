import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:taxi_driver/screens/a_my_bottom_appbar.dart';
import 'package:taxi_driver/screens/a_my_drawer.dart';
import 'package:taxi_driver/screens/e_journey_screen.dart';

class JourneyListScreen extends StatefulWidget {
  const JourneyListScreen({Key? key}) : super(key: key);

  @override
  State<JourneyListScreen> createState() => _JourneyListScreenState();
}

class _JourneyListScreenState extends State<JourneyListScreen> {
  final auth = FirebaseAuth.instance;
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");

  double currentLat = 0;
  double currentLng = 0;

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      // ignore: avoid_print
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  double findDistance(double lat, double lng) {
    double distance =
        Geolocator.distanceBetween(currentLat, currentLng, lat, lng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  loadData() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  String currentJourney = '';
  bool isFree = true;
  bool isShowPopup = false;

  getDriver() async {
    var driver = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .get();

    isFree = driver['isFree'];
    currentJourney = driver['currentJourney'];
    setState(() {});
    //return driver;
  }

  TextEditingController textController = TextEditingController();
  final FocusNode textfieldNode = FocusNode();
  String searchtext = '';
  bool searchState = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getDriver();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        textfieldNode.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              "Journey List",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
            ),
          ),
          drawer: const MyDrawer(),
          bottomNavigationBar: BottomAppBar(
            child: MyBottomAppbar(
              page: 'journey-list',
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey)),
                      alignment: const AlignmentDirectional(0, 0),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  4, 0, 4, 0),
                              child: SizedBox(
                                child: TextFormField(
                                  focusNode: textfieldNode,
                                  controller: textController,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(
                                      Icons.search_sharp,
                                      color: Color(0xFF57636C),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Lexend Deca',
                                    color: Color(0xFF57636C),
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          (textController.text.isEmpty ||
                                  textController.text == '')
                              ? const SizedBox(
                                  width: 0,
                                  height: 0,
                                )
                              : Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 8, 0),
                                  child: SizedBox(
                                    width: 30,
                                    height: 40,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          textController.text = '';
                                          searchState = false;
                                          setState(() {});
                                        });
                                      },
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 6, 8, 6),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (textController.text.isNotEmpty) {
                                  setState(() {
                                    searchState = true;
                                    searchtext =
                                        textController.text.toLowerCase();
                                  });
                                } else {
                                  setState(() {
                                    searchState = false;
                                    searchtext = '';
                                  });
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.orange),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: const BorderSide(
                                              color: Colors.orange)))),
                              child: const Text(
                                "Search",
                                style: TextStyle(
                                  fontFamily: 'Lexend Deca',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  searchState
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('journeys')
                                    .where("status",
                                        isEqualTo: "waiting_driver")
                                    .orderBy('placeName')
                                    .startAt([
                                  searchtext,
                                ]).snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator(
                                      color: Colors.grey,
                                    );
                                  } else if (snapshot.data!.docs.isEmpty) {
                                    return const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "We didn't find any journey.\nPlease try another name.",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }

                                  return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: ((context, index) {
                                            return StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('journeys')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .collection('passenger_s')
                                                    .orderBy('distance')
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapcol) {
                                                  if (snapcol.hasData) {
                                                    if (findDistance(
                                                            snapcol.data!.docs
                                                                    .last[
                                                                'startLat'],
                                                            snapcol.data!.docs
                                                                    .last[
                                                                'startLng']) <
                                                        10) {
                                                      return SizedBox(
                                                        height: 155,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 7),
                                                          child: ElevatedButton(
                                                              onPressed: () {
                                                                if (isFree) {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (context) {
                                                                    return JourneyScreen(
                                                                      docID: snapshot
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                              [
                                                                              'id']
                                                                          .toString(),
                                                                    );
                                                                  }));
                                                                } else {
                                                                  setState(() {
                                                                    isShowPopup =
                                                                        true;
                                                                  });
                                                                }
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                elevation:
                                                                    MaterialStateProperty
                                                                        .all(1),
                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    side: const BorderSide(
                                                                        width:
                                                                            0.5,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            213,
                                                                            213,
                                                                            213)))),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        const Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        10.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  // crossAxisAlignment:
                                                                  //     CrossAxisAlignment.center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.48,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                const SizedBox(
                                                                                  width: 25,
                                                                                  child: Icon(
                                                                                    Icons.location_pin,
                                                                                    size: 24,
                                                                                    color: Colors.deepOrangeAccent,
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Text(
                                                                                  " ${snapshot.data!.docs[index]['placeName']}",
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(fontSize: 16),
                                                                                ))
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          // Text(
                                                                          //   'Overall ${snapcol.data!.docs.last['distance']} km',
                                                                          //   style:
                                                                          //       const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          // ),
                                                                          Text(
                                                                            "${findDistance(snapcol.data!.docs.last['startLat'], snapcol.data!.docs.last['startLng'])} km from first passenger",
                                                                            style:
                                                                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          ),
                                                                          Text(
                                                                            "${findDistance(snapshot.data!.docs[index]['endLat'], snapshot.data!.docs[index]['endLng'])} km from destination",
                                                                            style:
                                                                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          ),

                                                                          Text(
                                                                            DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate()),
                                                                            style:
                                                                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              TextField(
                                                                            readOnly:
                                                                                true,
                                                                            controller:
                                                                                TextEditingController(text: "${snapcol.data!.docs.length}"),
                                                                            style:
                                                                                const TextStyle(fontSize: 15),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              enabled: false,
                                                                              border: InputBorder.none,
                                                                              icon: Icon(
                                                                                Icons.people,
                                                                                size: 21,
                                                                                color: Colors.orange.shade400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              TextField(
                                                                            readOnly:
                                                                                true,
                                                                            controller:
                                                                                TextEditingController(text: "${snapshot.data!.docs[index]['cost']} ฿"),
                                                                            style:
                                                                                const TextStyle(fontSize: 15),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              enabled: false,
                                                                              border: InputBorder.none,
                                                                              icon: Icon(
                                                                                Icons.paid,
                                                                                size: 21,
                                                                                color: Colors.orange.shade400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              TextField(
                                                                            readOnly:
                                                                                true,
                                                                            controller:
                                                                                TextEditingController(text: "${snapcol.data!.docs.last['distance']} km"),
                                                                            style:
                                                                                const TextStyle(fontSize: 15),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              enabled: false,
                                                                              border: InputBorder.none,
                                                                              icon: Icon(
                                                                                Icons.add_road,
                                                                                size: 21,
                                                                                color: Colors.orange.shade400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                      );
                                                    } else {
                                                      return const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      );
                                                    }
                                                  }

                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    color: Colors.pinkAccent,
                                                  ));
                                                });
                                          })));
                                }),
                          ),
                        )
                      :

                      //////////////// not search
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("journeys")
                                    .where("status",
                                        isEqualTo: "waiting_driver")
                                    .orderBy("timestamp", descending: false)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator(
                                      color: Colors.amber,
                                    );
                                  } else if (snapshot.data!.docs.isEmpty) {
                                    return const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "We don't have any journey rigth now :(",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }

                                  return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: ((context, index) {
                                            return StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('journeys')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .collection('passenger_s')
                                                    .orderBy('distance')
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapcol) {
                                                  if (snapcol.hasData) {
                                                    if (findDistance(
                                                            snapcol.data!.docs
                                                                    .last[
                                                                'startLat'],
                                                            snapcol.data!.docs
                                                                    .last[
                                                                'startLng']) <
                                                        10) {
                                                      return SizedBox(
                                                        height: 155,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 7),
                                                          child: ElevatedButton(
                                                              onPressed: () {
                                                                if (isFree) {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (context) {
                                                                    return JourneyScreen(
                                                                      docID: snapshot
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                              [
                                                                              'id']
                                                                          .toString(),
                                                                    );
                                                                  }));
                                                                } else {
                                                                  setState(() {
                                                                    isShowPopup =
                                                                        true;
                                                                  });
                                                                }
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                elevation:
                                                                    MaterialStateProperty
                                                                        .all(1),
                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    side: const BorderSide(
                                                                        width:
                                                                            0.5,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            213,
                                                                            213,
                                                                            213)))),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        const Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        10.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  // crossAxisAlignment:
                                                                  //     CrossAxisAlignment.center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.48,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                const SizedBox(
                                                                                  width: 25,
                                                                                  child: Icon(
                                                                                    Icons.location_pin,
                                                                                    size: 24,
                                                                                    color: Colors.deepOrangeAccent,
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Text(
                                                                                  " ${snapshot.data!.docs[index]['placeName']}",
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(fontSize: 16),
                                                                                ))
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // Text(
                                                                          //   'Overall ${snapcol.data!.docs.last['distance']} km',
                                                                          //   style:
                                                                          //       const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          // ),

                                                                          Text(
                                                                            "${findDistance(snapcol.data!.docs.last['startLat'], snapcol.data!.docs.last['startLng'])} km from first passenger",
                                                                            style:
                                                                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          ),

                                                                          Text(
                                                                            "${findDistance(snapshot.data!.docs[index]['endLat'], snapshot.data!.docs[index]['endLng'])} km from destination",
                                                                            style:
                                                                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          ),

                                                                          Text(
                                                                            DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate()),
                                                                            style:
                                                                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              TextField(
                                                                            readOnly:
                                                                                true,
                                                                            controller:
                                                                                TextEditingController(text: "${snapcol.data!.docs.length}"),
                                                                            style:
                                                                                const TextStyle(fontSize: 15),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              enabled: false,
                                                                              border: InputBorder.none,
                                                                              icon: Icon(
                                                                                Icons.people,
                                                                                size: 21,
                                                                                color: Colors.orange.shade400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              TextField(
                                                                            readOnly:
                                                                                true,
                                                                            controller:
                                                                                TextEditingController(text: "${snapshot.data!.docs[index]['cost']} ฿"),
                                                                            style:
                                                                                const TextStyle(fontSize: 15),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              enabled: false,
                                                                              border: InputBorder.none,
                                                                              icon: Icon(
                                                                                Icons.paid,
                                                                                size: 21,
                                                                                color: Colors.orange.shade400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              TextField(
                                                                            readOnly:
                                                                                true,
                                                                            controller:
                                                                                TextEditingController(text: "${snapcol.data!.docs.last['distance']} km"),
                                                                            style:
                                                                                const TextStyle(fontSize: 15),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              enabled: false,
                                                                              border: InputBorder.none,
                                                                              icon: Icon(
                                                                                Icons.add_road,
                                                                                size: 21,
                                                                                color: Colors.orange.shade400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                      );
                                                    } else {
                                                      return const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      );
                                                    }
                                                  }

                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    color: Colors.pinkAccent,
                                                  ));
                                                });
                                          })));
                                }),
                          ),
                        ),
                ],
              ),
              isShowPopup
                  ? GestureDetector(
                      onTap: () {
                        isShowPopup = false;
                        setState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Color.fromARGB(126, 237, 237, 237),
                      ),
                    )
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
              isShowPopup
                  ? notFreePopup()
                  : const SizedBox(width: 0, height: 0),
            ],
          )),
    );
  }

  notFreePopup() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: const BorderSide(color: Colors.grey, width: 0.5)
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 10,
                ),
                const ListTile(
                  leading: Icon(
                    Icons.navigation,
                    color: Colors.deepOrange,
                    size: 30,
                  ),
                  title: Text('You already have your journey.'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text(
                        'Go to current journey',
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return JourneyScreen(docID: currentJourney);
                        }));
                        setState(() {
                          isShowPopup = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: Text('Close',
                          style: TextStyle(color: Colors.grey[700])),
                      onPressed: () {
                        setState(() {
                          isShowPopup = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
