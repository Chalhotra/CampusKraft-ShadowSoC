import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ig_clone/pages/booking_popup.dart';

import 'package:ig_clone/utils.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

// import 'package:shop_app_proj/global_variables.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  DateTime chosenDate = DateTime.now();
  void pickDate() {
    showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2050))
        .then((value) {
      setState(() {
        chosenDate = value!;
      });
    });
  }

  TextEditingController roomController = TextEditingController();
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

  List<dynamic> cart = [];
  void getCart() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
        .get();
    setState(() {
      cart = (snap.data() as Map<String, dynamic>)['cart'];
    });
  }

  void sendMail(
      {required String recipientMail, required String messageMail}) async {
    String username = "campuskraft69@gmail.com";
    String password = "yoahilaxsghpeffa";
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientMail)
      ..subject = 'Booking Change'
      ..text = 'Message: $messageMail';

    try {
      await send(message, smtpServer);
      getSnackBar('Successfully Booked', context);
    } catch (e) {
      print(e.toString());
    }
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String name = "";
  // int enrollment = 0;
  // String email = "";

  // Future<void> getUserInfo() async {
  //   DocumentSnapshot snap = await _firestore
  //       .collection('users')
  //       .doc(_auth.currentUser!.email!.substring(0, 8))
  //       .get();

  //   setState(() {
  //     name = (snap.data() as Map<String, dynamic>)['name'];
  //     email = (snap.data() as Map<String, dynamic>)['mail'];
  //     enrollment = (snap.data() as Map<String, dynamic>)['enrollment_number'];
  //     cart = (snap.data() as Map<String, dynamic>)['cart'];
  //   });
  // }

  int selectedSize = 0;
  @override
  void initState() {
    super.initState();
    getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: Column(
        children: [
          Center(
            child: Text(widget.product['title'] as String,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              widget.product['imageUrl'] as String,
              width: 300,
            ),
          ),
          const Spacer(flex: 2),
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.04),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Text("\₹${widget.product['price'].toString()}",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Spacer(),
                SizedBox(
                  width: 400,
                  height: 70,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              BookingPopup(product: widget.product),
                        ));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          Text("Book this Service",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black87,
                          textStyle: Theme.of(context).textTheme.titleMedium)),
                ),
                const Spacer(flex: 1)
              ],
            ),
          )
        ],
      ),
    );
  }
}
