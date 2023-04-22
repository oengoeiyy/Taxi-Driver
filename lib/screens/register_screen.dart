import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_driver/models/driver.dart';
import 'package:taxi_driver/screens/home_screen.dart';
import 'package:taxi_driver/screens/login_screen.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Driver driver = Driver();
  final registerFormKey = GlobalKey<FormState>();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final TextEditingController pass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();
  TextEditingController dateinput = TextEditingController();

  final auth = FirebaseAuth.instance;
  CollectionReference driverCollection =
      FirebaseFirestore.instance.collection("drivers");

  String? dropdownValue; // = list.first;
  bool isObscure = true;
  bool isObscureChk = true;
  bool isValid = true;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 1, 2, 23),
              body: SingleChildScrollView(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: SafeArea(
                      child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                opacity: 1,
                                image: AssetImage("assets/taxi-bggg.jpg"),
                                fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                            child: Form(
                                key: registerFormKey,
                                child: Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Column(
                                      children: [
                                        Text("Sign Up",
                                            style: GoogleFonts.ptSans(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red)),
                                        const SizedBox(
                                          height: 30,
                                        ),

                                        //email
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        "email required*"),
                                                EmailValidator(
                                                    errorText: "invalid email")
                                              ]),
                                              onSaved: (String? email) {
                                                driver.email = email;
                                              },
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.email),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText: 'Email',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                                errorStyle: TextStyle(
                                                    color:
                                                        Colors.redAccent[700],
                                                    fontWeight: FontWeight.w700
                                                    //fontSize: 0,
                                                    ),
                                              )),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),
                                        //password
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              obscureText: isObscure,
                                              onSaved: (String? password) {
                                                driver.password = password;
                                              },
                                              controller: pass,
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        'password required*'),
                                                MinLengthValidator(8,
                                                    errorText:
                                                        'password at least 8 character'),
                                              ]),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.lock),
                                                suffixIcon: IconButton(
                                                    icon: Icon(isObscure
                                                        ? Icons.visibility
                                                        : Icons.visibility_off),
                                                    onPressed: () {
                                                      setState(() {
                                                        isObscure = !isObscure;
                                                      });
                                                    }),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText: 'Password',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),

                                        //comfirm pass
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              obscureText: isObscureChk,
                                              controller: confirmPass,
                                              validator: (val) {
                                                if (val!.isEmpty) {
                                                  return 'confirm password required*';
                                                }
                                                if (val != pass.text) {
                                                  return 'password not match';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.lock),
                                                suffixIcon: IconButton(
                                                    icon: Icon(isObscure
                                                        ? Icons.visibility
                                                        : Icons.visibility_off),
                                                    onPressed: () {
                                                      setState(() {
                                                        isObscureChk =
                                                            !isObscureChk;
                                                      });
                                                    }),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText: 'Confirm Password',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),

                                        const Divider(
                                          color: Colors.white,
                                          thickness: 2,
                                          height: 40,
                                        ),

                                        //fname
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              onSaved: (String? fname) {
                                                driver.fname = fname;
                                              },
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        "firstname required*"),
                                              ]),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.person),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText: 'Fisrtname',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                    //style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        //lname
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              onSaved: (String? lname) {
                                                driver.lname = lname;
                                              },
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        "lastname required*"),
                                              ]),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.person),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText: 'Lastname',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                    //style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (String? thID) {
                                                driver.thID = thID;
                                              },
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        "citizen id required*"),
                                                PatternValidator(
                                                    r'(^(?:[+0]9)?[0-9]{13}$)',
                                                    errorText:
                                                        "invalid citizen id")
                                              ]),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.badge),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText:
                                                    'Citizen Number (13digits)',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                    //style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (String? driverLc) {
                                                driver.driveLc = driverLc;
                                              },
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        "driver license required*"),
                                                PatternValidator(
                                                    r'(^(?:[+0]9)?[0-9]{8}$)',
                                                    errorText:
                                                        "invalid driver license")
                                              ]),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.drive_eta),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText:
                                                    'Driver License (8digits)',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                    //style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                            readOnly: true,
                                            controller: dateinput,
                                            // onSaved: (String? birthday) {
                                            //   //driver.birthday = birthday;
                                            // },
                                            validator: MultiValidator([
                                              RequiredValidator(
                                                  errorText:
                                                      "birthday required*"),
                                            ]),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(
                                                  Icons.calendar_month),
                                              contentPadding:
                                                  const EdgeInsets.all(17),
                                              fillColor: const Color.fromARGB(
                                                  250, 255, 255, 255),
                                              hintText: 'Birthday',
                                              hintStyle:
                                                  const TextStyle(fontSize: 16),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: const BorderSide(
                                                  width: 1,
                                                  style: BorderStyle.none,
                                                  //style: BorderStyle.none,
                                                ),
                                              ),
                                              filled: true,
                                            ),
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context:
                                                    context, //context of current state
                                                initialDate: DateTime(
                                                    (DateTime.now().year - 20),
                                                    1,
                                                    1),
                                                firstDate: DateTime(DateTime
                                                            .now()
                                                        .year -
                                                    60), //DateTime.now() - not to allow to choose before today.
                                                lastDate: DateTime(
                                                    (DateTime.now().year - 20),
                                                    12,
                                                    31),
                                              );

                                              if (pickedDate != null) {
                                                print(
                                                    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                String formattedDate =
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(pickedDate);
                                                print(
                                                    formattedDate); //formatted date output using intl package =>  2021-03-16

                                                setState(() {
                                                  driver.birthday = pickedDate;
                                                  dateinput.text =
                                                      formattedDate;
                                                });
                                              } else {
                                                //print("Date is not selected");
                                              }
                                            },
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        SizedBox(
                                          width: double.infinity,
                                          child: TextFormField(
                                              onSaved: (String? tel) {
                                                driver.tel = tel;
                                              },
                                              keyboardType: TextInputType.phone,
                                              validator: MultiValidator([
                                                RequiredValidator(
                                                    errorText:
                                                        "telephone number required*"),
                                                PatternValidator(
                                                    r'(^(?:[+0]9)?0[689]{1}[0-9]{8}$)',
                                                    errorText:
                                                        "invalid telephone number")
                                              ]),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.phone_android),
                                                contentPadding:
                                                    const EdgeInsets.all(17),
                                                fillColor: const Color.fromARGB(
                                                    250, 255, 255, 255),
                                                hintText: 'Telephone Number',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    width: 1,
                                                    style: BorderStyle.none,
                                                    //style: BorderStyle.none,
                                                  ),
                                                ),
                                                filled: true,
                                              )),
                                        ),

                                        const SizedBox(
                                          height: 5,
                                        ),

                                        SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                checkColor: Colors.white,
                                                fillColor: MaterialStateProperty
                                                    .resolveWith(getColor),
                                                value: isChecked,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    isChecked = value!;
                                                  });
                                                },
                                              ),
                                              const Text(
                                                'Please check the box if you permit us\nto keep your personal information.',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        SizedBox(
                                          width: 130,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              if (!(registerFormKey
                                                  .currentState!
                                                  .validate())) {
                                                setState(() {
                                                  isValid = false;
                                                });
                                              } else if (!isChecked) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please check the permission box",
                                                    gravity:
                                                        ToastGravity.BOTTOM);
                                              } else if (registerFormKey
                                                      .currentState!
                                                      .validate() &&
                                                  isChecked) {
                                                registerFormKey.currentState
                                                    ?.save();
                                                setState(() {
                                                  isValid = true;
                                                });
                                                try {
                                                  await FirebaseAuth.instance
                                                      .createUserWithEmailAndPassword(
                                                          email: (driver.email)
                                                              .toString(),
                                                          password:
                                                              (driver.password)
                                                                  .toString())
                                                      .then((value) async {
                                                    final auth =
                                                        FirebaseAuth.instance;
                                                    await driverCollection
                                                        .doc(auth
                                                            .currentUser!.uid)
                                                        .set({
                                                      'fname': driver.fname,
                                                      'lname': driver.lname,
                                                      'thID': driver.thID,
                                                      'driverLc':
                                                          driver.driveLc,
                                                      'birthday':
                                                          driver.birthday,
                                                      'email': driver.email,
                                                      'tel': driver.tel,
                                                      'role': 'driver',
                                                      "isFree": true,
                                                      "currentJourney": '',
                                                      "imageURL": '',
                                                    });
                                                  }).then((value) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Register finish, Welcome!",
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 10);
                                                    registerFormKey.currentState
                                                        ?.reset();
                                                    pass.text = '';
                                                    confirmPass.text = '';
                                                    dateinput.text = '';
                                                    isChecked = false;
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return const HomeScreen();
                                                    }));
                                                  });
                                                } on FirebaseAuthException catch (e) {
                                                  //print(e.message);
                                                  //print(e.code);
                                                  String? message;
                                                  if (e.code ==
                                                      'email-already-in-use') {
                                                    message =
                                                        "อีเมล์นี้ถูกใช้ไปแล้ว";
                                                  } else {
                                                    message = e.message;
                                                  }
                                                  Fluttertoast.showToast(
                                                      //msg: e.message.toString(),
                                                      msg: message.toString(),
                                                      gravity:
                                                          ToastGravity.CENTER);
                                                }
                                              }
                                            },
                                            style: ButtonStyle(
                                                elevation:
                                                    MaterialStateProperty.all(
                                                        10),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red),
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                        Colors.amber),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          27.0),
                                                  //side: BorderSide(color: Colors.red)
                                                ))),
                                            child: Text("SIGN UP",
                                                style: GoogleFonts.cairo(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: InkWell(
                                child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 40,
                                color: Color.fromARGB(255, 95, 95, 95),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const LoginScreen();
                                }));
                              },
                            )),
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
              ),
            );
          }

          return Scaffold(
            body: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: SafeArea(
                    child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 80, horizontal: 55),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                opacity: 1,
                                image: AssetImage("assets/taxi-bggg.jpg"),
                                fit: BoxFit.cover),
                          ),
                          child: Form(
                              child: Center(
                            child: Column(
                              children: [
                                Text("Sign Up",
                                    style: GoogleFonts.ptSans(
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                                const SizedBox(
                                  height: 50,
                                ),
                                //username
                                const SizedBox(height: 80),

                                const SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 10,
                                  ),
                                ),

                                const SizedBox(
                                  height: 220,
                                )
                              ],
                            ),
                          ))),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: InkWell(
                              child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 40,
                              color: Color.fromARGB(255, 95, 95, 95),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const LoginScreen();
                              }));
                            },
                          )),
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          );
        }));
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.red;
    }
    return Colors.red;
  }
}


  // SizedBox(
                                        //     width: double.infinity,
                                        //     child:
                                        //         DropdownButtonFormField<String>(
                                        //       value: dropdownValue,
                                        //       decoration: InputDecoration(
                                        //         contentPadding:
                                        //             const EdgeInsets.all(19),
                                        //         fillColor: const Color.fromARGB(
                                        //             250, 255, 255, 255),
                                        //         hintText: 'Gender',
                                        //         hintStyle: const TextStyle(
                                        //             fontSize: 16),
                                        //         border: OutlineInputBorder(
                                        //           borderRadius:
                                        //               BorderRadius.circular(30),
                                        //           borderSide: const BorderSide(
                                        //             width: 1,
                                        //             style: BorderStyle.none,
                                        //             //style: BorderStyle.none,
                                        //           ),
                                        //         ),
                                        //         filled: true,
                                        //       ),
                                        //       icon: const Icon(
                                        //           Icons.arrow_downward),
                                        //       elevation: 16,
                                        //       style: const TextStyle(
                                        //           color: Colors.black),
                                        //       onChanged: (String? value) {
                                        //         // This is called when the user selects an item.
                                        //         setState(() {
                                        //           dropdownValue = value!;
                                        //         });
                                        //       },
                                        //       onSaved: (String? gender) {
                                        //         passenger.gender = gender;
                                        //       },
                                        //       items: list.map<
                                        //               DropdownMenuItem<String>>(
                                        //           (String value) {
                                        //         return DropdownMenuItem<String>(
                                        //           value: value,
                                        //           child: Text(
                                        //             value,
                                        //             style:
                                        //                 TextStyle(fontSize: 16),
                                        //           ),
                                        //         );
                                        //       }).toList(),
                                        //     )),

