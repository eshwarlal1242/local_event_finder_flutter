import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../MapDemo.dart';

class EventListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const EventListScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events List")),
      body: events.isEmpty
          ? const Center(child: Text("No events available."))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            leading: event['image'] != null
                ? Image.file(event['image'], width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.event),
            title: Text(event['name']),
            subtitle: Text("Category: ${event['category']}"),
            trailing: const Icon(Icons.location_on, color: Colors.red),
            onTap: () {
              if (event['location'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(location: event['location']),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
