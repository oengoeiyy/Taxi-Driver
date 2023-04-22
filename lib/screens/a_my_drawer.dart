import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/models/journey.dart';
import 'package:taxi_driver/screens/a_profile_screen.dart';
import 'package:taxi_driver/screens/g_history_screen.dart';
import 'package:taxi_driver/screens/home_screen.dart';
import 'package:taxi_driver/screens/income_screen.dart';
import 'package:taxi_driver/screens/journey_list_screen.dart';
import 'package:taxi_driver/screens/login_screen.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  //final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('drivers')
          .where("email", isEqualTo: "${auth.currentUser?.email}")
          .snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          final data = docs[0].data();

          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: SafeArea(
                  child: Drawer(
                width: MediaQuery.of(context).size.width * 0.55,
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: 200,
                      child: DrawerHeader(
                          margin: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                opacity: 1,
                                image: AssetImage("assets/taxi-bgg.jpg"),
                                fit: BoxFit.cover),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (data['imageURL'] == '')
                                  ? const CircleAvatar(
                                      radius: 55, // Image radius
                                      backgroundImage: AssetImage(
                                          'assets/default_profile.jpg'))
                                  : CircleAvatar(
                                      radius: 55, // Image radius
                                      backgroundImage: NetworkImage(
                                          data['imageURL'].toString()),
                                    ),
                              const SizedBox(height: 15),
                              Text("${data['fname']} ${data['lname']}",
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                              Text(data['email'],
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                            ],
                          )),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Home',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.home_outlined,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomeScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Profile',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.person_outline,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ProfileScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Journey List',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.explore_outlined,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const JourneyListScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'History\n&Income',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.history,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const IncomeScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Logout',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.exit_to_app_rounded,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const LoginScreen();
                          }));

                          _signOut();
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              )));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
