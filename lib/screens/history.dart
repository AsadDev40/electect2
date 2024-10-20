// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class history extends StatelessWidget {
  final currentFCMToken; // Assuming you pass the current FCM token to this widget

  const history({super.key, this.currentFCMToken});
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9ED2FC), // Set to light blue color
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('FcmTokens')
                      .where('userid', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return DataTable(
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 50, // Adjust width as needed
                            child: Text('Date'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 40, // Adjust width as needed
                            child: Text('Time'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 60, // Adjust width as needed
                            child: Text('Duration'),
                          ),
                        ),
                      ],
                      rows: _buildRows(snapshot.data!.docs),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildRows(List<DocumentSnapshot> snapshot) {
    List<DataRow> rows = [];
    for (var document in snapshot) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      dynamic date = data['startDate'];
      dynamic time = data['startTime'];
      dynamic duration = data['duration'];

      // Null check before casting to String
      String dateString = date != null ? date.toString() : 'Not Available';
      String timeString = time != null ? time.toString() : 'Not Available';
      String durationString =
          duration != null ? duration.toString() : 'Not Available';

      rows.add(DataRow(
        cells: [
          DataCell(Text(dateString)),
          DataCell(Text(timeString)),
          DataCell(Text(durationString)),
        ],
      ));
    }
    return rows;
  }
}
