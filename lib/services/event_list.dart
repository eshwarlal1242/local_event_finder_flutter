import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../eventDetail.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4), // Creamy white
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final event = doc.data() as Map<String, dynamic>;
              final image = event['image_base64'];
              final decodedImage = image != null ? base64Decode(image) : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(eventData: event),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.deepOrange.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: decodedImage != null
                            ? Image.memory(
                          decodedImage,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 90,
                          height: 90,
                          color: Colors.deepOrange.shade100,
                          child: const Icon(Icons.event, size: 32, color: Colors.white),
                        ),
                      ),
                      // Text Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['name'] ?? 'Unnamed Event',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    event['date'] ?? '',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                              if (event['category'] != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE0B2), // light orange
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    event['category'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
