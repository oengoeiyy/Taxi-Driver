import 'package:flutter/material.dart';
import 'package:taxi_driver/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_driver/screens/a_profile_screen.dart';
import 'package:taxi_driver/screens/e_journey_screen.dart';
import 'package:taxi_driver/screens/g_history_screen.dart';
import 'package:taxi_driver/screens/home_screen.dart';
import 'package:taxi_driver/screens/income_screen.dart';
import 'package:taxi_driver/screens/journey_list_screen.dart';

class MyBottomAppbar extends StatefulWidget {
  String? page;
  MyBottomAppbar({
    Key? key,
    @required this.page,
  }) : super(key: key);

  @override
  State<MyBottomAppbar> createState() => _MyBottomAppbarState();
}

class _MyBottomAppbarState extends State<MyBottomAppbar> {
  final page = MyBottomAppbar().page;

  getDriver() async {
    var driver = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(auth.currentUser!.uid)
        .get();
    return driver;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 2,
      //shape: shape,
      color: Colors.white,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (widget.page == 'home')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomeScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.home,
                              size: 30,
                            ),
                            Text(
                              ' Home',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Home',
                      icon: Icon(
                        Icons.home,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const HomeScreen();
                        }));
                      },
                    ),

              (widget.page == 'journey-list')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const JourneyListScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.explore,
                              size: 30,
                            ),
                            Text(
                              ' Journey\n List',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Journey List',
                      icon: Icon(
                        Icons.explore,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const JourneyListScreen();
                        }));
                      },
                    ),

              ////////////////////
              FutureBuilder(
                  future: getDriver(),
                  builder: (context, AsyncSnapshot snapdoc) {
                    if (snapdoc.hasData) {
                      if (!(snapdoc.data!['isFree'])) {
                        if (widget.page == 'journey') {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: 130,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return JourneyScreen(
                                      docID: snapdoc.data!['currentJourney']);
                                }));
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 255, 205, 139)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.navigation,
                                    size: 30,
                                    color: Colors.deepOrange,
                                  ),
                                  Text(
                                    ' Journey',
                                    style: TextStyle(fontSize: 17),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        return IconButton(
                          tooltip: 'Current Journey',
                          icon: const Icon(
                            Icons.navigation,
                            size: 40,
                            color: Colors.deepOrange,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return JourneyScreen(
                                  docID: snapdoc.data!['currentJourney']);
                            }));
                          },
                        );
                      }
                    }

                    return const SizedBox(width: 0, height: 0);
                  }),
              ///////////////////
              ///
              (widget.page == 'history')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const IncomeScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.history,
                              size: 30,
                            ),
                            Text(
                              ' History',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Income',
                      icon: Icon(
                        Icons.history_outlined,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const IncomeScreen();
                        }));
                      },
                    ),

              (widget.page == 'profile')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const JourneyListScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.person,
                              size: 30,
                            ),
                            Text(
                              ' Profile',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Profile',
                      icon: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ProfileScreen();
                        }));
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
