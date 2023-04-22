import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/screens/a_map_screen.dart';
import 'package:taxi_driver/screens/a_my_bottom_appbar.dart';
import 'package:taxi_driver/screens/a_my_drawer.dart';
import 'package:taxi_driver/screens/a_profile_screen.dart';
import 'package:taxi_driver/screens/e_journey_screen.dart';
import 'package:taxi_driver/screens/g_history_screen.dart';
import 'package:taxi_driver/screens/income_screen.dart';
import 'package:taxi_driver/screens/journey_list_screen.dart';
import 'package:taxi_driver/services/networking.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  //final auth = FirebaseAuth.instance;

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

  bool isFree = true;
  String currentJourney = '';
  bool isShowPopup = false;

  getDriver() async {
    var driver = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .get();

    setState(() {
      isFree = driver['isFree'];
      currentJourney = driver['currentJourney'];
    });

    //return driver;
  }

  TextEditingController textController = TextEditingController();
  //List<dynamic> placeList = [];
  //List<dynamic> labelList = [];
  String tmp = '';
  final formKeys = GlobalKey<FormState>();
  final FocusNode textfieldNode = FocusNode();
  String searchtext = '';
  bool searchState = false;
  int countFree = 0;

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
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        //color: Colors.pink,
        child: MyBottomAppbar(
          page: 'home',
        ),
      ),
      key: scaffoldKey,
      backgroundColor: Colors.white, //const Color.fromARGB(255, 241, 244, 248),
      drawer: const MyDrawer(),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          textfieldNode.unfocus();
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white //Color.fromARGB(255, 250, 250, 250)
                      //color: Color(0xFFF1F4F8),
                      ),
                  child: Align(
                    alignment: const AlignmentDirectional(0, 0.5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            topImage(),
                            topElement(),
                            //journeyList(),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 228, 20, 0),
                                child: Container(
                                    //color: Colors.pink,
                                    height: 180,
                                    child: const SizedBox(
                                        height: 80,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "You're too far from journeys",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        )))),

                            searchState
                                ? Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            10, 259, 10, 0),
                                    child: SizedBox(
                                      //color: Color.fromARGB(255, 222, 222, 222),
                                      height: 180,
                                      width: double.infinity,
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
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: Colors.grey,
                                              ));
                                            } else if (snapshot
                                                .data!.docs.isEmpty) {
                                              return Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 0, 20, 0),
                                                  child: Container(
                                                      color: Colors.white,
                                                      height: 180,
                                                      child: const SizedBox(
                                                          height: 80,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              "We didn't find any journey.\nPlease try another name.",
                                                              style: TextStyle(
                                                                  fontSize: 15),
                                                            ),
                                                          ))));
                                            }

                                            return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        17, 0, 17, 0),
                                                child: Container(
                                                  //color: Colors.white,
                                                  height: 180,
                                                  child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount: snapshot
                                                          .data!.docs.length,
                                                      itemBuilder:
                                                          ((context, index) {
                                                        return StreamBuilder(
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
                                                                .orderBy(
                                                                    'distance')
                                                                .snapshots(),
                                                            builder: (context,
                                                                AsyncSnapshot<
                                                                        QuerySnapshot>
                                                                    snapcol) {
                                                              if (snapcol
                                                                  .hasData) {
                                                                if (findDistance(
                                                                        snapcol.data!.docs.last[
                                                                            'startLat'],
                                                                        snapcol
                                                                            .data!
                                                                            .docs
                                                                            .last['startLng']) <
                                                                    10) {
                                                                  return SizedBox(
                                                                    height: 85,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              5),
                                                                      child: ElevatedButton(
                                                                          onPressed: () {
                                                                            if (isFree) {
                                                                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                                                return JourneyScreen(
                                                                                  docID: snapshot.data!.docs[index]['id'].toString(),
                                                                                );
                                                                              }));
                                                                            } else {
                                                                              setState(() {
                                                                                isShowPopup = true;
                                                                              });
                                                                            }
                                                                          },
                                                                          style: ButtonStyle(
                                                                            elevation:
                                                                                MaterialStateProperty.all(1),
                                                                            shape:
                                                                                MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: const BorderSide(color: Color.fromARGB(255, 229, 229, 229)))),
                                                                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                255,
                                                                                255)),
                                                                          ),
                                                                          child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 8.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              //crossAxisAlignment:
                                                                              //    CrossAxisAlignment.center,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.57,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        height: 30,
                                                                                        child: Row(
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
                                                                                      Text(
                                                                                        " Overall ${snapcol.data!.docs.last['distance']} km",
                                                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                                                                      ),
                                                                                      Text(
                                                                                        " ${findDistance(snapcol.data!.docs.last['startLat'], snapcol.data!.docs.last['startLng'])} km from first passenger",
                                                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      TextField(
                                                                                        readOnly: true,
                                                                                        controller: TextEditingController(text: "${snapcol.data!.docs.length}"),
                                                                                        style: const TextStyle(fontSize: 14),
                                                                                        decoration: const InputDecoration(
                                                                                          isDense: true,
                                                                                          enabled: false,
                                                                                          border: InputBorder.none,
                                                                                          icon: Icon(
                                                                                            Icons.people,
                                                                                            size: 20,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      TextField(
                                                                                        readOnly: true,
                                                                                        controller: TextEditingController(text: "${snapshot.data!.docs[index]['cost']}฿"),
                                                                                        style: const TextStyle(fontSize: 14),
                                                                                        decoration: const InputDecoration(
                                                                                          isDense: true,
                                                                                          enabled: false,
                                                                                          border: InputBorder.none,
                                                                                          icon: Icon(
                                                                                            Icons.paid,
                                                                                            size: 20,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return const SizedBox(
                                                                      width: 0,
                                                                      height:
                                                                          0);
                                                                }
                                                              }

                                                              return const CircularProgressIndicator(
                                                                color: Colors
                                                                    .deepOrange,
                                                              );
                                                            });
                                                      })),
                                                ));
                                          }),
                                    ),
                                  )
                                : journeyList(),

                            //searchbar
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  18, 200, 18, 0),
                              child: SizedBox(
                                height: 250,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Row(
                                        //mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(4, 0, 4, 0),
                                              child: SizedBox(
                                                child: TextFormField(
                                                  focusNode: textfieldNode,
                                                  controller: textController,
                                                  onChanged: (value) {
                                                    setState(() {});
                                                  },
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.white,
                                                        width: 0.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(0, 4, 8, 0),
                                                  child: SizedBox(
                                                    width: 30,
                                                    height: 40,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.cancel_outlined,
                                                        size: 20,
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          textController.text =
                                                              '';
                                                          searchState = false;
                                                          setState(() {});
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 4, 8, 0),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                if (textController
                                                    .text.isNotEmpty) {
                                                  setState(() {
                                                    searchState = true;
                                                    searchtext = textController
                                                        .text
                                                        .toLowerCase();
                                                  });
                                                } else {
                                                  setState(() {
                                                    searchState = false;
                                                    searchtext = '';
                                                  });
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.orange,
                                              ),
                                              child: const Text(
                                                "Search",
                                                style: TextStyle(
                                                  fontFamily: 'Lexend Deca',
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            topMenu(),
                          ],
                        ),
                        InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.65),
                            child: const Text('See all journey >>'),
                          ),
                          onTap: () {
                            setState(() {
                              countFree++;
                            });
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return const JourneyListScreen();
                            // }));
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 140,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const JourneyListScreen();
                                      }));
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (Rect bounds) {
                                            return ui.Gradient.linear(
                                              const Offset(0.0, 24.0),
                                              const Offset(24.0, 0.0),
                                              [
                                                Colors.orange,
                                                Colors.deepOrange.shade100,
                                              ],
                                            );
                                          },
                                          child: const Icon(
                                            Icons.explore,
                                            size: 70,
                                            //color: Colors.black,
                                          ),
                                        ),
                                        const Text(
                                          'Journey\nList',
                                          style: TextStyle(color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  height: 140,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const IncomeScreen();
                                      }));
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (Rect bounds) {
                                            return ui.Gradient.linear(
                                              Offset(0.0, 24.0),
                                              Offset(24.0, 0.0),
                                              [
                                                Colors.orange,
                                                Colors.deepOrange.shade100,
                                              ],
                                            );
                                          },
                                          child: const Icon(
                                            Icons.history,
                                            size: 70,
                                            //color: Colors.black,
                                          ),
                                        ),
                                        const Text(
                                          'History\n&Income',
                                          style: TextStyle(color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  height: 140,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const ProfileScreen();
                                      }));
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (Rect bounds) {
                                            return ui.Gradient.linear(
                                              Offset(0.0, 24.0),
                                              Offset(24.0, 0.0),
                                              [
                                                Colors.orange,
                                                Colors.deepOrange.shade100,
                                              ],
                                            );
                                          },
                                          child: const Icon(
                                            Icons.person,
                                            size: 70,
                                            //color: Colors.black,
                                          ),
                                        ),
                                        const Text(
                                          'Profile\n',
                                          style: TextStyle(color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                isShowPopup
                    ? GestureDetector(
                        onTap: () {
                          isShowPopup = false;
                          setState(() {});
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                          color: const Color.fromARGB(126, 237, 237, 237),
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
            ),
          ),
        ),
      ),
    );
  }

  topMenu() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 25, 16, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              scaffoldKey.currentState!.openDrawer();
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(33, 255, 255, 255)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MapScreen();
                }));
              },
              icon: const Icon(
                Icons.map_outlined,
                color: Colors.white,
                size: 30,
              ),
              label: const Text(
                "Map",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  topImage() {
    return ClipRect(
        child: ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 2,
        sigmaY: 2,
      ),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF262D34),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/taxi-orange.jpg',
            ).image,
          ),
        ),
      ),
    ));
  }

  topElement() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E2429), Color(0x001E2429)],
          stops: [0, 1],
          begin: AlignmentDirectional(0, 1),
          end: AlignmentDirectional(0, -1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              child: SizedBox(
                width: 150,
                height: 90,
              )
              // Image.asset(
              //   'assets/anya.jpg',
              //   width: 230,
              //   height: 90,
              //   fit: BoxFit.fitWidth,
              // ),
              ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Keep up the good work.',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xB3FFFFFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  journeyList() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 259, 10, 0),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('journeys')
                .where("status", isEqualTo: "waiting_driver")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.data!.docs.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                        color: Colors.white,
                        height: 180,
                        child: const SizedBox(
                            height: 80,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "We don't have any journey rigth now :(",
                                style: TextStyle(fontSize: 15),
                              ),
                            ))));
              }

              return Padding(
                  padding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
                  child: Container(
                    //color: Colors.white,
                    height: 180,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('journeys')
                                  .doc(snapshot.data!.docs[index].id)
                                  .collection('passenger_s')
                                  .orderBy('distance')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapcol) {
                                if (snapcol.hasData) {
                                  if (findDistance(
                                          snapcol.data!.docs.last['startLat'],
                                          snapcol.data!.docs.last['startLng']) <
                                      10) {
                                    return SizedBox(
                                      height: 85,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              if (isFree) {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return JourneyScreen(
                                                    docID: snapshot
                                                        .data!.docs[index]['id']
                                                        .toString(),
                                                  );
                                                }));
                                              } else {
                                                setState(() {
                                                  isShowPopup = true;
                                                });
                                              }
                                            },
                                            style: ButtonStyle(
                                              elevation:
                                                  MaterialStateProperty.all(1),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                      side: const BorderSide(
                                                          color: Color.fromARGB(
                                                              255,
                                                              229,
                                                              229,
                                                              229)))),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      const Color.fromARGB(
                                                          255, 255, 255, 255)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                //crossAxisAlignment:
                                                //    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.57,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        SizedBox(
                                                          height: 30,
                                                          child: Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 25,
                                                                child: Icon(
                                                                  Icons
                                                                      .location_pin,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .deepOrangeAccent,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                  child: Text(
                                                                " ${snapshot.data!.docs[index]['placeName']}",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            16),
                                                              ))
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          " Overall ${snapcol.data!.docs.last['distance']} km",
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          " ${findDistance(snapcol.data!.docs.last['startLat'], snapcol.data!.docs.last['startLng'])} km from first passenger",
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextField(
                                                          readOnly: true,
                                                          controller:
                                                              TextEditingController(
                                                                  text:
                                                                      "${snapcol.data!.docs.length}"),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                          decoration:
                                                              const InputDecoration(
                                                            isDense: true,
                                                            enabled: false,
                                                            border: InputBorder
                                                                .none,
                                                            icon: Icon(
                                                              Icons.people,
                                                              size: 20,
                                                              // color: Colors
                                                              //     .orange
                                                              //     .shade300,
                                                            ),
                                                          ),
                                                        ),
                                                        TextField(
                                                          readOnly: true,
                                                          controller:
                                                              TextEditingController(
                                                                  text:
                                                                      "${snapshot.data!.docs[index]['cost']}฿"),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                          decoration:
                                                              const InputDecoration(
                                                            isDense: true,
                                                            enabled: false,
                                                            border: InputBorder
                                                                .none,
                                                            icon: Icon(
                                                              Icons.paid,
                                                              size: 20,
                                                              // color: Colors
                                                              //     .orange
                                                              //     .shade300,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox(width: 0, height: 0);
                                  }
                                }

                                return const CircularProgressIndicator(
                                    color: Colors.amber);
                              });
                        })),
                  ));
            }),
      ),
    );
  }

  doit() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            countFree--;
          });
        },
        child: Text('countFree $countFree'));
  }

  doitp() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            countFree++;
          });
        },
        child: Text('countFree $countFree'));
  }

  notFreePopup() {
    return Padding(
      padding: const EdgeInsets.only(top: 300),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              //side: const BorderSide(color: Colors.grey, width: 0.5)
            ),
            elevation: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
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
      ),
    );
  }

  double calculateDistance(lat2, lon2) {
    var lat1 = 14.889937;
    var lon1 = 102.006134;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
