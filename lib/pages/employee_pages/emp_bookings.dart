import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeBookings extends StatefulWidget {
  const EmployeeBookings({super.key});

  @override
  State<EmployeeBookings> createState() => _EmployeeBookingsState();
}

class _EmployeeBookingsState extends State<EmployeeBookings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Padding(
        padding: EdgeInsets.only(top: 5.0),
        child: Text(
          "Your Bookings",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      )),
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('service_providers')
            .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
            .collection('bookings')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookList = snapshot.data!.docs;
          return ListView.builder(
            itemBuilder: (context, index) {
              final currentBook = bookList[index];
              return ListTile(
                // trailing: TextButton(
                //   style: TextButton.styleFrom(
                //     side: BorderSide(width: 2, color: Colors.green),
                //     foregroundColor: Colors.green,
                //   ),
                //   onPressed: () {},
                //   child: const Text(
                //     "Completed",
                //     style: TextStyle(
                //         color: Colors.green, fontWeight: FontWeight.bold),
                //   ),
                // ),
                leading: CircleAvatar(
                  radius: 10,
                  child: Image.asset(currentBook['imageUrl']),
                ),
                title: Text(
                    "${currentBook['bhawan']} Bhawan, ${currentBook['room']}"),
                subtitle: Text(currentBook['date']),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      )),
    );
  }
}
