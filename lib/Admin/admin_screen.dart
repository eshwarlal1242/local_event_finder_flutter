import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../add_event.dart';
import 'edit_event.dart';

class AdminEventScreen extends StatelessWidget {
  final CollectionReference eventsRef =
  FirebaseFirestore.instance.collection('events');

  void _deleteEvent(String docId) {
    eventsRef.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 👈 Important for avoiding overflow
      appBar: AppBar(
        title: Text('Manage Events'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventScreen()),
          );
        },
      ),
      body: SafeArea( // 👈 Wrap with SafeArea
        child: StreamBuilder<QuerySnapshot>(
          stream: eventsRef.orderBy('created_at', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Error loading events'));
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final events = snapshot.data!.docs;

            if (events.isEmpty) {
              return Center(
                child: Text(
                  'No Events Found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100, // 👈 Give space for FloatingActionButton
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final data = events[index].data() as Map<String, dynamic>;
                final docId = events[index].id;
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: MemoryImage(
                            base64Decode(data['image_base64'] ?? ''),
                          ),
                          radius: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text('📅 Date: ${data['date']}'),
                              Text('🏷 Category: ${data['category']}'),
                              Text('📌 Status: ${data['status']}'),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.deepOrange),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEventScreen(docId: docId),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(docId),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

              },
            );
          },
        ),
      ),
    );

  }
}
