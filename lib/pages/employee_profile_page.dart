import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/auth_methods.dart';
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

  Future<void> getEmployeeInfo() async {
    DocumentSnapshot snap = await _firestore
        .collection('service_providers')
        .doc(_auth.currentUser!.email!.substring(0, 8))
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['name'];
      email = (snap.data() as Map<String, dynamic>)['mail'];
      emp_id = (snap.data() as Map<String, dynamic>)['employee_id'];
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
            child: CircleAvatar(
              radius: 64,
              backgroundColor: Colors.blue,
            ),
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
            width: double.infinity,
            child: TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  AuthMethods().logOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => EmployeeLoginPage()));
                },
                child: Text("Logout",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          )
        ],
      ),
    ));
  }
}
