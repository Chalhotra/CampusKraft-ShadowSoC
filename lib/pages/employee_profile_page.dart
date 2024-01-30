import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/auth_methods.dart';
import 'package:ig_clone/pages/emp_dialog_box.dart';
import 'package:ig_clone/pages/employee_login_page.dart';

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String name = "";
  int emp_id = 0;
  String email = "";
  String? photoUrl;

  void profileAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EmployeeProfileDialog(onAvatarUpdated: getEmployeeInfo);
      },
    );
  }

  Future<void> getEmployeeInfo() async {
    DocumentSnapshot snap = await _firestore
        .collection('service_providers')
        .doc(_auth.currentUser!.email!.substring(0, 8))
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['name'];
      email = (snap.data() as Map<String, dynamic>)['mail'];
      emp_id = (snap.data() as Map<String, dynamic>)['employee_id'];
      photoUrl = (snap.data() as Map<String, dynamic>)['photoUrl'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmployeeInfo();
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
                    left: 6,
                    top: 6,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                    ),
                  ),
                  IconButton(
                      onPressed: profileAlertDialog,
                      icon: const Icon(Icons.add)),
                ]),
              )
            ]),
          ),
          SizedBox(
            height: 10,
          ),
          Text("$name",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(
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
                        Text(
                          "Employee\nNumber:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("$emp_id",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ],
                    )),
                Container(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Email Address:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '$email',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          SizedBox(
            width: 200,
            child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  AuthMethods().logOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const EmployeeLoginPage()));
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
