import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/models/driver.dart';
import 'package:taxi_driver/models/journey.dart';
import 'package:taxi_driver/screens/a_my_bottom_appbar.dart';
import 'package:taxi_driver/screens/g_history_screen.dart';
import 'package:taxi_driver/screens/home_screen.dart';
import 'package:taxi_driver/screens/income_screen.dart';
import 'package:taxi_driver/services/networking.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}

class JourneyScreen extends StatefulWidget {
  String? docID;
  JourneyScreen({
    Key? key,
    @required this.docID,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _JourneyScreenState createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  final docID = JourneyScreen().docID;
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  Driver driver = Driver();
  Journey journey = Journey();

  bool startState = true;
  bool isDelete = false;

  final formKey = GlobalKey<FormState>();
  TextEditingController startAddress = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController distancetext = TextEditingController();
  TextEditingController costText = TextEditingController();

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 12,
  );

  CollectionReference journeysCollection =
      FirebaseFirestore.instance.collection("journeys");
  CollectionReference passengersCollection =
      FirebaseFirestore.instance.collection("passengers");
  CollectionReference journeysByIDCollection = FirebaseFirestore.instance
      .collection('journeys')
      .doc(JourneyScreen().docID)
      .collection('passenger_s');

  double endLat = 0;
  double endLng = 0;
  double sumLat = 0;
  double sumLng = 0;
  int count = 0;
  double currentLat = 0;
  double currentLng = 0;
  int countFin = 0;
  bool isAllPick = true;

  List<bool> downChk = [false, false, false];
  List<dynamic> colorList = [Colors.orange, Colors.yellow, Colors.greenAccent];

  List<dynamic> pinColor = [
    BitmapDescriptor.hueOrange,
    BitmapDescriptor.hueYellow,
    BitmapDescriptor.hueGreen
  ];

  var customMarker;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      // ignore: avoid_print
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  loadCurrentLocation() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  int person = 0;
  String? creator = '';
  String? status = '';

  getJourney() async {
    var journey = await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .get();

    //person = journey['person'];
    //creator = journey['creator'];
    //status = journey['status'];

    return journey;
  }

  String currentJourney = '';
  bool isFree = false;

  getDriver() async {
    var driver = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .get();

    currentJourney = driver['currentJourney'];
    isFree = driver['isFree'];

    return driver;
  }

  List<double> latList = [];
  List<double> lngList = [];
  List<double> distanceList = [];

  getDestination() async {
    var des = await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .get();

    setState(() {
      endLat = des['endLat'];
      endLng = des['endLng'];
      latList.add(des['endLat']);
      lngList.add(des['endLng']);
    });

    _markers.add(Marker(
      markerId: const MarkerId('des'),
      position: LatLng(des['endLat'] as double, des['endLng'] as double),
      //icon: BitmapDescriptor.fromBytes(customMarker)
    ));

    //print(des['endLat']);
    return des;
  }

  getJourneyData() async {
    await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .collection('passenger_s')
        .orderBy('distance', descending: false) /////////////HERE
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          sumLat += element['startLat'];
          sumLng += element['startLng'];
          latList.add(element['startLat']);
          lngList.add(element['startLng']);
          distanceList.add(element['distance']);
          count++;
        });

        setMarkers(element.id, element['startLat'], element['startLng']);
        setState(() {});
      });
      //getPosition(lat, lng, count);
    });
  }

  getPosition(lat, lng, count) async {
    final GoogleMapController controller = await _controller.future;
    final klat = (lat + endLat) / (count + 1);
    final klng = (lng + endLng) / (count + 1);

    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(klat, klng),
      zoom: 10,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
    setState(() {});
  }

  int i = 0;

  setMarkers(index, lat, lng) {
    _markers.add(Marker(
        markerId: MarkerId(index.toString()),
        position: LatLng(lat as double, lng as double),
        icon: BitmapDescriptor.defaultMarkerWithHue(pinColor[i])
        //infoWindow: InfoWindow(title: address)
        ));

    setState(() {
      i++;
    });
  }

  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};

  setPolylineList() async {
    int latCount = latList.length;
    int lngCount = lngList.length;

    if (latCount != lngCount) {
      print('Lat & Lng dont equal');
    } else {
      for (int i = 0; i < latCount - 1; i++) {
        await getPolyline(
            latList[i], lngList[i], latList[i + 1], lngList[i + 1]);
      }
    }
  }

  getPolyline(startLat, startLng, endLat, endLng) async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
        startLat: startLat, startLng: startLng, endLat: endLat, endLng: endLng);

    try {
      // getData() returns a json Decoded data
      var data = await network.getData();
      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      //setPolyLines();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  setPolyLines() {
    Polyline polyline = Polyline(
        polylineId: const PolylineId("polyline"),
        color: Colors.red,
        width: 6,
        points: polyPoints,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round);
    polyLines.add(polyline);
    //setState(() {});
  }

  double findDistancewithCurrent(double startLat, double startLng) {
    double distance = Geolocator.distanceBetween(
        startLat as double, startLng as double, currentLat, currentLng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  double findDistancewithDes(double startLat, double startLng) {
    double distance = Geolocator.distanceBetween(
        startLat as double, startLng as double, endLat, endLng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  double findDistance(
      double startLat, double startLng, double endLat, double endLng) {
    double distance =
        Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  myLocationFromLatLng(lat, lng) async {
    MyLocationFromLatLng autocomplete =
        MyLocationFromLatLng(lat: lat, lng: lng);

    try {
      // getData() returns a json Decoded data
      var data = await autocomplete.getData();

      startAddress.text = data['features'][0]['properties']['label'];
      // startPlaceName.text = data['features'][0]['properties']['name'];
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  realinit() async {
    //customMarker = await getBytesFromAsset('assets/one.png', 100);
    getJourney();
    getDriver();
    await getDestination();
    await getJourneyData();
    getPosition(sumLat, sumLng, count);
    await setPolylineList();
    setPolyLines();
    loadCurrentLocation();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    realinit();
    countFin = 0;
    setState(() {});
  }

  bool chk = true;
  var ct;

  @override
  Widget build(BuildContext context) {
    double mapheight = chk
        ? (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top) *
            0.3
        : (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top) *
            0.55;
    double mapwidth =
        chk ? MediaQuery.of(context).size.width * 0.9 : double.infinity;
    double aboveMap = chk ? 3 : 0;
    return Scaffold(
      bottomNavigationBar: chk
          ? BottomAppBar(
              child: MyBottomAppbar(
                page: 'journey',
              ),
            )
          : null,
      backgroundColor: Colors.white,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.height * 0.1,
        height: MediaQuery.of(context).size.height * 0.1,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('drivers')
                .doc(auth.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!['currentJourney'] == widget.docID &&
                    isAllPick) {
                  return FloatingActionButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('journeys')
                              .doc(widget.docID)
                              .update({
                            "status": 'success',
                            "successTime": Timestamp.now()
                          });

                          await FirebaseFirestore.instance
                              .collection('journeys')
                              .doc(widget.docID)
                              .collection('passenger_s')
                              .orderBy('distance', descending: false)
                              .get()
                              .then((value) {
                            value.docs.forEach((element) async {
                              await journeysCollection
                                  .doc(widget.docID)
                                  .collection('passenger_s')
                                  .doc(element.id)
                                  .update({
                                'status': 'success',
                                'successTime': Timestamp.now()
                              });

                              await passengersCollection.doc(element.id).update(
                                  {'isFree': true, 'currentJourney': ''});
                            });
                          });

                          await FirebaseFirestore.instance
                              .collection('drivers')
                              .doc(auth.currentUser!.uid)
                              .update({
                            "isFree": true,
                            "currentJourney": ''
                          }).then((value) async {
                            Fluttertoast.showToast(
                                msg: "This journey has been successfully!",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 10);

                            setState(() {});

                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const IncomeScreen();
                            }));
                          });
                        } on FirebaseAuthException catch (e) {
                          String? message;

                          message = e.message;

                          Fluttertoast.showToast(
                              //msg: e.message.toString(),
                              msg: message.toString(),
                              gravity: ToastGravity.CENTER);
                        }
                      },
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Icons.check,
                        size: MediaQuery.of(context).size.height * 0.05,
                        color: Colors.white,
                      ));
                }
              }

              return const SizedBox(
                width: 0,
                height: 0,
              );
            }),
      ),
      appBar: AppBar(
          automaticallyImplyLeading: (chk && !isDelete),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              Colors.white, //const Color.fromARGB(255, 241, 243, 244),
          //elevation: 0,
          title: const Text('Journey')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            isDelete = false;
          });
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, aboveMap, 0, 0),
                    color: Colors.white,
                    height: mapheight,
                    width: mapwidth,
                    child: GoogleMap(
                      initialCameraPosition: _kGooglePlex,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      markers: Set<Marker>.of(_markers),
                      polylines: polyLines,
                      onTap: (latLng) async {
                        print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
                        print(count);
                        print(countFin);
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),

                  //Future Here !
                  GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('journeys')
                              .doc(widget.docID)
                              .collection('passenger_s')
                              .orderBy('distance', descending: false)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            ct = snapshot.data!.docs.length;

                            return Container(
                              // color: Colors.pink,
                              height: (MediaQuery.of(context).size.height -
                                      MediaQuery.of(context).padding.top) *
                                  0.4,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: ((context, index) {
                                    if (snapshot.data!.docs[index]['status'] !=
                                            'pick-up' &&
                                        snapshot.data!.docs[index]['status'] !=
                                            'success') {
                                      isAllPick = false;
                                    }
                                    bool dChk = downChk[index];
                                    return SizedBox(
                                      height: dChk
                                          ? (MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  MediaQuery.of(context)
                                                      .padding
                                                      .top) *
                                              0.35
                                          : 90,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              final GoogleMapController
                                                  controller =
                                                  await _controller.future;
                                              CameraPosition kGooglePlex =
                                                  CameraPosition(
                                                target: LatLng(
                                                    snapshot.data!.docs[index]
                                                        ['startLat'],
                                                    snapshot.data!.docs[index]
                                                        ['startLng']),
                                                zoom: 12,
                                              );
                                              controller.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                          kGooglePlex));
                                            },
                                            style: ButtonStyle(
                                              elevation:
                                                  MaterialStateProperty.all(0),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0.0),
                                                      side: const BorderSide(
                                                          color: Color.fromARGB(
                                                              255,
                                                              229,
                                                              229,
                                                              229)))),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  child: Text(
                                                      (index + 1).toString(),
                                                      style: TextStyle(
                                                          fontSize: 50,
                                                          color: colorList[
                                                              index])),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  mainAxisAlignment: dChk
                                                      ? MainAxisAlignment
                                                          .spaceEvenly
                                                      : MainAxisAlignment
                                                          .center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_city_outlined,
                                                          size: 20,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.55,
                                                          child: Text(
                                                            "${snapshot.data!.docs[index]['startAddress']}",
                                                            maxLines:
                                                                dChk ? 4 : 1,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .chat_bubble_outline,
                                                          size: 20,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.55,
                                                          child: Text(
                                                            " ${snapshot.data!.docs[index]['detail']}",
                                                            maxLines:
                                                                dChk ? 4 : 1,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    dChk
                                                        ? Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .person_pin_circle,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[700],
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.52,
                                                                child: Text(
                                                                  "${snapshot.data!.docs[index]['distance']} km far from destination.",
                                                                  maxLines: dChk
                                                                      ? 4
                                                                      : 1,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : const SizedBox(
                                                            width: 0,
                                                            height: 0),
                                                    dChk
                                                        ? Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .my_location_outlined,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[700],
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.52,
                                                                child: Text(
                                                                  "You're ${findDistancewithCurrent(snapshot.data!.docs[index]['startLat'], snapshot.data!.docs[index]['startLng'])} km far from\nthis passenger.",
                                                                  maxLines: dChk
                                                                      ? 4
                                                                      : 1,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : const SizedBox(
                                                            width: 0,
                                                            height: 0),
                                                    dChk
                                                        ? Row(
                                                            children: [
                                                              Icon(
                                                                Icons.paid,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[700],
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.52,
                                                                child: Text(
                                                                  "${snapshot.data!.docs[index]['cost']} ฿",
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : const SizedBox(
                                                            width: 0,
                                                            height: 0),
                                                  ],
                                                ),
                                                downChk[index]
                                                    ? Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    downChk[index] =
                                                                        false;
                                                                  });
                                                                  setState(
                                                                      () {});
                                                                },
                                                                icon: const Icon(
                                                                    Icons
                                                                        .expand_less)),
                                                            (snapshot.data!.docs[index]
                                                                            [
                                                                            'status'] ==
                                                                        'waiting' &&
                                                                    currentJourney ==
                                                                        widget
                                                                            .docID)
                                                                ? IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        finDocID = snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .id;
                                                                        isDelete =
                                                                            true;

                                                                        // downChk[index] =
                                                                        //     false;
                                                                      });
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .hail,
                                                                      size: 40,
                                                                      color: colorList[
                                                                          index],
                                                                    ))
                                                                : const SizedBox(
                                                                    width: 0,
                                                                    height: 0),
                                                          ],
                                                        ),
                                                      )
                                                    : Expanded(
                                                        child: IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                downChk[index] =
                                                                    true;
                                                              });
                                                            },
                                                            icon: const Icon(Icons
                                                                .expand_more)),
                                                      )
                                              ],
                                            )),
                                      ),
                                    );
                                  })),
                            );
                          }),
                    ),
                  ),

                  SizedBox(
                      height: 40,
                      width: 120,
                      child: FutureBuilder(
                          future: getJourney(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              if (isFree &&
                                  snapshot.data!['status'] ==
                                      'waiting_driver') {
                                return ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.deepOrange),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                side: const BorderSide(
                                                    color:
                                                        Colors.deepOrange)))),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('journeys')
                                          .doc(widget.docID)
                                          .update({'status': 'traveling'});

                                      await FirebaseFirestore.instance
                                          .collection('journeys')
                                          .doc(widget.docID)
                                          .update({
                                        "driver": auth.currentUser!.uid
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('drivers')
                                          .doc(auth.currentUser!.uid)
                                          .update({
                                        'isFree': false,
                                        'currentJourney': widget.docID
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('drivers')
                                          .doc(auth.currentUser!.uid)
                                          .collection('journey_s')
                                          .doc(widget.docID)
                                          .set({
                                        'timestamp': Timestamp.now()
                                      }).then((value) {
                                        Fluttertoast.showToast(
                                            msg: "Take journey succesfully!",
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 10);
                                      });
                                      setState(() {});
                                    },
                                    child: const Text(
                                      "Take a ride!",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ));
                              }
                            }

                            return const SizedBox(
                              width: 0,
                              height: 0,
                            );
                          }))
                  //: const SizedBox(width: 0, height: 0)
                ],
              ),
            ),
            isDelete
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color.fromARGB(134, 237, 237, 237),
                  )
                : const SizedBox(
                    width: 0,
                    height: 0,
                  ),
            isDelete ? pickUpPopUp() : const SizedBox(width: 0, height: 0),
          ],
        ),
      ),
    );
  }

  String finDocID = '';

  pickUpPopUp() {
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
                    Icons.hail,
                    color: Colors.orange,
                    size: 30,
                  ),
                  title: Text('Pick up this passenger?'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('journeys')
                              .doc(widget.docID)
                              .collection('passenger_s')
                              .doc(finDocID)
                              .update({
                            'status': 'pick-up',
                            'pickUpTime': Timestamp.now()
                          }).then((value) {
                            Fluttertoast.showToast(
                                msg: "Success",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 10);
                          });
                          setState(() {
                            isDelete = false;

                            finDocID = '';
                          });
                        } on FirebaseAuthException catch (e) {
                          String? message;

                          message = e.message;

                          Fluttertoast.showToast(
                              //msg: e.message.toString(),
                              msg: message.toString(),
                              gravity: ToastGravity.CENTER);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child:
                          Text('No', style: TextStyle(color: Colors.grey[700])),
                      onPressed: () {
                        setState(() {
                          isDelete = false;
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
