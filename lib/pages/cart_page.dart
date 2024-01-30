import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List empList = [];
  void getEmployees() async {
    QuerySnapshot snap =
        await FirebaseFirestore.instance.collection('service_providers').get();
    setState(() {
      empList = snap.docs;
    });
  }

  void sendMail(
      {required String recipientMail, required String messageMail}) async {
    String username = "campuskraft69@gmail.com";
    String password = "yoahilaxsghpeffa";
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'CampusKraft')
      ..recipients.add(recipientMail)
      ..subject = 'Booking Change'
      ..text = 'Message: $messageMail';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(
          child: Text("Successful"),
        ),
      ));
    } catch (e) {
      print(e.toString());
    }
  }

  List<dynamic> cart = [];
  String email = "";
  void getUserInfo() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
        .get();

    setState(() {
      email = (snap.data() as Map<String, dynamic>)['mail'];
    });
  }

  @override
  void initState() {
    super.initState();
    getEmployees();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text('Current Requests',
              style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          builder: (context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            cart = (snapshot.data!).data()!['cart'];
            return ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final cartItem = cart[index];
                return ListTile(
                  trailing: MaterialButton(
                    color: Colors.white,
                    elevation: 0,
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              content: Text(
                                  "Are you sure you want to canel this booking?",
                                  style: Theme.of(context).textTheme.bodySmall),
                              title: Text('Remove Item',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue),
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        cart.remove(cartItem);
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.email!
                                                .substring(0, 8))
                                            .update({'cart': cart});
                                      });
                                      for (int i = 0; i < empList.length; i++) {
                                        final empInfo = empList[i].data();

                                        if (empInfo['service'] ==
                                            cartItem['title']) {
                                          print(empInfo); //print debugging
                                          Map<String, dynamic> req = cartItem;
                                          req['req_id'] = FirebaseAuth
                                              .instance.currentUser!.email!
                                              .substring(0, 8);

                                          req['user_email'] = email;
                                          final user_id = (FirebaseAuth
                                              .instance.currentUser!.email!
                                              .substring(0, 8));
                                          final dateDoc = req['date'];
                                          final bhawanDoc = req['bhawan'];
                                          final roomDoc = req['room'];
                                          final docID =
                                              "${user_id}_${dateDoc}_${bhawanDoc}_${roomDoc}";
                                          FirebaseFirestore.instance
                                              .collection('service_providers')
                                              .doc(empInfo['employee_id']
                                                  .toString())
                                              .collection('requests')
                                              .doc(docID)
                                              .delete();
                                        }
                                      }

                                      Navigator.of(context).pop();
                                      sendMail(
                                          recipientMail: cartItem['email'],
                                          messageMail:
                                              '''Dear ${cartItem['title']},

We hope this message finds you well. We regret to inform you that your booking request in ${cartItem['bhawan']} Bhawan, Room ${cartItem['room']}, scheduled for ${cartItem['date']}, has been cancelled.

We understand the importance of your booking, and we sincerely apologize for any inconvenience this may cause. Our team is committed to providing you with the best service, and we are here to assist you with any further inquiries.

Thank you for your understanding.''');
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    child: Text("Yes",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)))
                              ]);
                        },
                      );
                    },
                    child: Icon(Icons.delete),
                  ),
                  title: Text(cartItem['title'] as String,
                      style: Theme.of(context).textTheme.bodySmall),
                  subtitle: Text(
                      "Bhawan: ${cartItem['bhawan'].toString()}\nRoom: ${cartItem['room']}\nDate: ${cartItem['date']}"),
                  leading: CircleAvatar(
                    foregroundImage: AssetImage(cartItem['imageUrl'] as String),
                    radius: 30,
                  ),
                );
              },
            );
          },
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
              .snapshots()),
    );
  }
}
