import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/utils.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmployeeRequests extends StatefulWidget {
  const EmployeeRequests({super.key});

  @override
  State<EmployeeRequests> createState() => _EmployeeRequestsState();
}

class _EmployeeRequestsState extends State<EmployeeRequests> {
  String empName = "";
  String empMail = "";
  String empEnr = "";
  int empNum = 0;
  String empService = "";
  void getEmpInfo() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('service_providers')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
        .get();
    setState(() {
      empName = (snap.data() as Map<String, dynamic>)['name'];
      empMail = (snap.data() as Map<String, dynamic>)['mail'];
      empEnr = (snap.data() as Map<String, dynamic>)['employee_id'].toString();
      empNum = (snap.data() as Map<String, dynamic>)['phone_number'];
      empService = (snap.data() as Map<String, dynamic>)['service'];
    });
  }

  Future<void> removeFromCart(
      {required String user_mail,
      required String userID,
      required Map<String, dynamic> productToBeRemoved}) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userID);
    DocumentSnapshot snap = await userRef.get();
    List<Map<String, dynamic>> currentCart =
        List.from((snap.data() as Map<String, dynamic>)['cart']);

    for (int i = 0; i < currentCart.length; i++) {
      if (currentCart[i]['id'] == productToBeRemoved['id'] &&
          currentCart[i]['date'] == productToBeRemoved['date'] &&
          currentCart[i]['bhawan'] == productToBeRemoved['bhawan'] &&
          currentCart[i]['room'] == productToBeRemoved['room']) {
        if (currentCart[i]['service_providers'] == 1) {
          currentCart.removeAt(i);
          sendMail(
              recipientMail: user_mail,
              messageMail:
                  'Tum logon ne daraasal mujhe gelchod samajh liya tha');
        } else {
          currentCart[i]['service_providers']--;
        }
      }
    }
    print(currentCart);
    await userRef.update({'cart': currentCart});
  }

  Future<void> sendToBookings(
      {required String userID,
      required Map<String, dynamic> productToBeRemoved}) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userID);
    DocumentSnapshot snap = await userRef.get();
    List<Map<String, dynamic>> currentCart =
        List.from((snap.data() as Map<String, dynamic>)['cart']);

    currentCart.removeWhere((element) =>
        (element['date'] == productToBeRemoved['date'] &&
            element['bhawan'] == productToBeRemoved['bhawan'] &&
            element['room'] == productToBeRemoved['room'] &&
            element['id'] == productToBeRemoved['id']));

    userRef.update({'cart': currentCart});
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
    } catch (e) {
      print(e.toString());
    }
  }

  List cart = [];
  void getCartUser({required String id}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    setState(() {
      cart = (snap.data() as Map<String, dynamic>)['cart'];
    });
  }

  List empList = [];
  void getEmployees() async {
    QuerySnapshot snap =
        await FirebaseFirestore.instance.collection('service_providers').get();
    setState(() {
      empList = snap.docs;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmployees();
    getEmpInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Text(
          "Current Requests",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      )),
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('service_providers')
            .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
            .collection('requests')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final reqList = snapshot.data!.docs;
          return ListView.builder(
            itemBuilder: (context, index) {
              final currentReq = reqList[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Image.asset(currentReq['imageUrl']),
                  radius: 10,
                ),
                title: Text(
                    "${currentReq['bhawan']} Bhawan, ${currentReq['room']}"),
                subtitle: Text(currentReq['date']),
                trailing: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            final user_id = currentReq['req_id'];
                            final dateDoc = currentReq['date'];
                            final bhawanDoc = currentReq['bhawan'];
                            final roomDoc = currentReq['room'];
                            final docID =
                                "${user_id}_${dateDoc}_${bhawanDoc}_${roomDoc}";
                            FirebaseFirestore.instance
                                .collection('service_providers')
                                .doc(FirebaseAuth.instance.currentUser!.email!
                                    .substring(0, 8))
                                .collection('bookings')
                                .doc(docID)
                                .set(currentReq.data());
                            sendToBookings(
                                userID: currentReq['req_id'],
                                productToBeRemoved: currentReq.data());
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentReq['req_id'])
                                .collection('bookings')
                                .doc(docID)
                                .set(currentReq.data());

                            for (int i = 0; i < empList.length; i++) {
                              final empInfo = empList[i].data();
                              if (empInfo['service'] == currentReq['title']) {
                                print("Hi");
                                final user_id = currentReq['req_id'];
                                final dateDoc = currentReq['date'];
                                final bhawanDoc = currentReq['bhawan'];
                                final roomDoc = currentReq['room'];
                                final docID =
                                    "${user_id}_${dateDoc}_${bhawanDoc}_${roomDoc}";
                                FirebaseFirestore.instance
                                    .collection('service_providers')
                                    .doc(empInfo['employee_id'].toString())
                                    .collection('requests')
                                    .doc(docID)
                                    .delete();
                              }
                            }
                            getSnackBar('Request moved to bookings', context);

                            sendMail(
                                recipientMail: currentReq['user_email'],
                                messageMail:
                                    'Your Request for ${currentReq['title']} has been accepted, your service will be made available at the earliest, you can contact the ${empService}, Mr.${empName} at ${empNum}');
                          },
                          icon: Icon(
                            Icons.check,
                            color: Colors.green,
                          )),
                      IconButton(
                          onPressed: () {
                            Map<String, dynamic> cartItem =
                                Map<String, dynamic>.from(currentReq.data());
                            final user_id = currentReq['req_id'];
                            final dateDoc = currentReq['date'];
                            final bhawanDoc = currentReq['bhawan'];
                            final roomDoc = currentReq['room'];
                            final docID =
                                "${user_id}_${dateDoc}_${bhawanDoc}_${roomDoc}";
                            String usMail = cartItem['user_email'];
                            cartItem.remove('user_email');
                            cartItem.remove('req_id');
                            print(cartItem);
                            FirebaseFirestore.instance
                                .collection('service_providers')
                                .doc(FirebaseAuth.instance.currentUser!.email!
                                    .substring(0, 8))
                                .collection('requests')
                                .doc(docID)
                                .delete();

                            setState(() {
                              removeFromCart(
                                  user_mail: usMail,
                                  userID: currentReq['req_id'],
                                  productToBeRemoved: cartItem);
                            });
                            getSnackBar(
                                'Request cancelled successfully', context);
                            sendMail(
                                recipientMail: currentReq['user_email'],
                                messageMail:
                                    'Your Request for ${currentReq['title']} has been cancelled by one employee, wait around to see if others respond');
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                          ))
                    ],
                  ),
                ),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      )),
    );
  }
}
