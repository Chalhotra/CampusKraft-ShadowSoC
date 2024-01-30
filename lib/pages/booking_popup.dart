import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/utils.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class BookingPopup extends StatefulWidget {
  final Map<String, dynamic> product;
  const BookingPopup({super.key, required this.product});

  @override
  State<BookingPopup> createState() => _BookingPopupState();
}

class _BookingPopupState extends State<BookingPopup> {
  String email = "";
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
      getSnackBar(
          'Request sent, you will be updated on your email address regarding the progress of the request',
          context);
    } catch (e) {
      print(e.toString());
    }
  }

  List cart = [];
  void getCart() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
        .get();
    setState(() {
      cart = (snap.data() as Map<String, dynamic>)['cart'];
      print(cart[0].runtimeType);
    });
  }

  Future<void> addRequestToCart(
      String userId, Map<String, dynamic> newRequest) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);

        // Check if the request already exists in the user's cart
        final List cart = userSnapshot['cart'] ?? [];
        if (_isRequestAlreadyExists(cart, newRequest)) {
          // Request already exists, handle accordingly (e.g., throw an error)
          getSnackBar(
              'You can only book ${newRequest['title']} once in a day in one hostel and room combination',
              context);
          throw 'Request already exists in the cart';
        }

        // Add the new request to the cart
        else {
          cart.add(newRequest);
        }

        // Update the user's cart
        transaction.update(userRef, {'cart': cart});
        sendMail(
            recipientMail: newRequest['email'],
            messageMail: '''Dear ${newRequest['title']},

We would like to inform you that a booking request has been submitted for ${newRequest['title']} service in ${bhawanChoice} Bhawan, Room ${roomController.text}, on ${chosenDate.toString().substring(0, 10)}. Your prompt attention to this matter is greatly appreciated.''');
      });
    } catch (e) {
      // Handle the error (e.g., show a message to the user)
      print('Error adding request to cart: $e');
    }
  }

  bool _isRequestAlreadyExists(
      List<dynamic> cart, Map<String, dynamic> newRequest) {
    // Check if there is an existing request with the same date, venue, and booking id
    return cart.any((request) =>
        request['date'] == newRequest['date'] &&
        request['bhawan'] == newRequest['bhawan'] &&
        request['room'] == newRequest['room'] &&
        request['id'] == newRequest['id']);
  }

  TextEditingController roomController = TextEditingController();
  String getDate() {
    return chosenDate.toString().substring(0, 10);
  }

  String getRoom() {
    return roomController.text;
  }

  String getBhawan() {
    return bhawanChoice;
  }

  DateTime chosenDate = DateTime.now();
  void pickDate() {
    showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2050))
        .then((value) {
      setState(() {
        chosenDate = value!;
        print(chosenDate.toString());
      });
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
    // TODO: implement initState
    super.initState();
    getCart();
    getEmployees();
    getUserInfo();
  }

  String bhawanChoice = "Rajendra";
  final bhawanList = [
    'Rajendra',
    'Jawahar',
    'Radhakrishnan',
    'Cautley',
    'Rajiv',
    'Ravindra',
    'Govind',
    'Kasturba',
    'Sarojini',
    'Himalaya',
    'Vigyan Kunj',
    'Azad'
  ];
  String dateLabel = "Choose Date";
  @override
  Widget build(BuildContext context) {
    final GlobalKey dropDownKey = GlobalKey();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Enter your Booking Details",
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Choose Your Bhawan:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      child: Builder(builder: (context) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton(
                            key: dropDownKey,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            items: bhawanList.map((String items) {
                              return DropdownMenuItem(
                                child: Text(items),
                                value: items,
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                bhawanChoice = newValue!;
                                dropDownKey.currentState?.setState(() {});
                                print(bhawanChoice);
                              });
                            },
                            value: bhawanChoice,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Enter your Room Number:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 120,
                      child: TextField(
                          controller: roomController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(width: 0)),
                            hintStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.normal),
                            hintText: "Room No.",
                          )),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Pick the Date:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    MaterialButton(
                      onPressed: pickDate,
                      child: Text(
                        chosenDate.toString().substring(0, 10),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child:
                                Text("Cancel", style: TextStyle(fontSize: 20))),
                      ),
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            Map<String, dynamic> cartItem = {
                              'id': widget.product['id'],
                              'title': widget.product['title'],
                              'price': widget.product['price'],
                              'company': widget.product['company'],
                              'imageUrl': widget.product['imageUrl'],
                              'bhawan': bhawanChoice,
                              'room': roomController.text,
                              'date': chosenDate.toString().substring(0, 10),
                              'email': widget.product['email'],
                              'service_providers': 0
                            };

                            for (int i = 0; i < empList.length; i++) {
                              final empInfo = empList[i].data();

                              if (empInfo['service'] == cartItem['title'] &&
                                  !(cart.contains(cartItem))) {
                                print(empInfo);
                                Map<String, dynamic> req =
                                    Map<String, dynamic>.from(cartItem);
                                req['req_id'] = FirebaseAuth
                                    .instance.currentUser!.email!
                                    .substring(0, 8);

                                req['user_email'] = email;
                                final user_id = (FirebaseAuth
                                    .instance.currentUser!.email!
                                    .substring(0, 8));
                                final dateDoc =
                                    chosenDate.toString().substring(0, 10);

                                final bhawanDoc = bhawanChoice;
                                final roomDoc = roomController.text;
                                final docID =
                                    "${user_id}_${dateDoc}_${bhawanDoc}_${roomDoc}";
                                FirebaseFirestore.instance
                                    .collection('service_providers')
                                    .doc(empInfo['employee_id'].toString())
                                    .collection('requests')
                                    .doc("$docID")
                                    .set(req);
                                cartItem['service_providers']++;
                              } else if (cart.contains(cartItem)) {
                                getSnackBar(
                                    'U can only book one ${cartItem['title']} service in one day :)',
                                    context);
                              }
                            }

//                             if (!cart.contains(cartItem)) {
//                               cart.add(cartItem);
//                               FirebaseFirestore.instance
//                                   .collection('users')
//                                   .doc(FirebaseAuth.instance.currentUser!.email!
//                                       .substring(0, 8))
//                                   .update({'cart': cart});
//                               sendMail(
//                                   recipientMail: cartItem['email'],
//                                   messageMail: '''Dear ${cartItem['title']},

// We would like to inform you that a booking request has been submitted for ${cartItem['title']} service in ${bhawanChoice} Bhawan, Room ${roomController.text}, on ${chosenDate.toString().substring(0, 10)}. Your prompt attention to this matter is greatly appreciated.''');
//                             } else {
//                               print("Item already exists in the cart");
//                             }
                            addRequestToCart(
                                FirebaseAuth.instance.currentUser!.email!
                                    .substring(0, 8),
                                cartItem);
                          },
                          child: Text("Book it",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                        ),
                      )
                    ])
              ],
            ),
          ),
        ));
  }
}
