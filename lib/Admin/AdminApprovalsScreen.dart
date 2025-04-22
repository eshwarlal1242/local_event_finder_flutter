import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEventApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Event Approval"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('isApproved', isEqualTo: false)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event['name']),
                subtitle: Text(event['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('events')
                            .doc(event.id)
                            .update({
                          'isApproved': true,
                          'status': 'Upcoming', // or "Approved"
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('events')
                            .doc(event.id)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
