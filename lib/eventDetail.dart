import 'dart:convert';
import 'package:flutter/material.dart';
import 'MapDemo.dart'; // Make sure this contains your GoogleMapScreen

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    final imageBase64 = eventData['image_base64'];
    final decodedImage = base64Decode(imageBase64 ?? "");

    const orangeColor = Color(0xFFFF6F00); // Orange

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(eventData['name']),
        backgroundColor: orangeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (decodedImage.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      decodedImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        eventData['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.category, 'Category', eventData['category'], orangeColor),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.date_range, 'Date', eventData['date'], orangeColor),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.info_outline, 'Status', eventData['status'], orangeColor),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              "Description",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: orangeColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventData['description'],
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 30),

            // Get Directions Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text("Get Directions"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleMapScreen(
                        eventLatitude: eventData['latitude'],
                        eventLongitude: eventData['longitude'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
