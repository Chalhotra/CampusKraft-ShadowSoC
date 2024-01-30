import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:ig_clone/auth_methods.dart';
import 'package:ig_clone/pages/dialog_box.dart';

import 'package:ig_clone/pages/user_bookings.dart';
import 'package:ig_clone/pages/user_login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String name = "";
  int enrollment = 0;
  String email = "";
  List<dynamic> cart = [];

  String? photoUrl;

  void uploadAvatar() {}

  Future<void> getUserInfo() async {
    DocumentSnapshot snap = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.email!.substring(0, 8))
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['name'];
      email = (snap.data() as Map<String, dynamic>)['mail'];
      enrollment = (snap.data() as Map<String, dynamic>)['enrollment_number'];
      cart = (snap.data() as Map<String, dynamic>)['cart'];
      photoUrl = (snap.data() as Map<String, dynamic>)['photoUrl'];
    });
    print('Photo URL: $photoUrl');
  }

  // Future<void> imageBytesFromUrl() async {
  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference ref = storage
  //       .ref()
  //       .child('userProfilePics')
  //       .child(FirebaseAuth.instance.currentUser!.email!.substring(0, 8));
  //   String photoUrl = await ref.getDownloadURL();
  //   http.Response response = await http.get(Uri.parse(photoUrl));

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _image = response.bodyBytes;
  //     });
  //   } else {
  //     throw Exception('Failed to load image');
  //   }
  // }

  void profileAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ProfileDialogBox(onAvatarUpdated: getUserInfo);
      },
    );
  }

  List<dynamic> get pintucart => cart;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();

    print(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Stack(children: [
              (photoUrl == null || photoUrl == "")
                  ? const CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.blue,
                    )
                  : CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage(photoUrl!),
                    ),
              Positioned(
                bottom: -5,
                left: 85,
                child: Stack(children: [
                  const Positioned(
                    left: 5,
                    top: 6,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                    ),
                  ),
                  IconButton(
                      onPressed: profileAlertDialog,
                      icon: const Icon(Icons.camera_alt)),
                ]),
              )
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          Text("$name",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    padding: EdgeInsets.all(10),
                    // decoration: BoxDecoration(
                    //     shape: BoxShape.rectangle,
                    //     borderRadius: BorderRadius.circular(10),
                    //     border: Border.all(
                    //       color: Colors.black,
                    //       width: 0,
                    //     )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Enrollment\nNumber:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("$enrollment",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ],
                    )),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Email Address:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('$email',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 200,
            child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    backgroundColor: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const UserBookingPage(),
                  ));
                },
                child: const Text("Booking History",
                    style: TextStyle(
                        // color: Color.fromRGBO(48, 48, 48, 1),
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 0),
          SizedBox(
            width: 200,
            child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  AuthMethods().logOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginPage()));
                },
                child: const Text("Logout",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          )
        ],
      ),
    ));
  }
}
