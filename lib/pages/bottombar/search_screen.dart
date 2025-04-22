import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../eventDetail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> _categories = ['Music', 'Tech', 'Sports', 'Food', 'Arts'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> event) {
    final query = _searchQuery.toLowerCase();
    final name = (event['name'] ?? '').toLowerCase();
    final location = (event['location'] ?? '').toLowerCase();
    final matchesText = name.contains(query) || location.contains(query);

    final category = event['category'] ?? '';
    final matchesCategory = _selectedCategory == null || category == _selectedCategory;

    final eventDateString = event['date'] ?? '';
    final eventDate = DateTime.tryParse(eventDateString);
    final matchesDate = _selectedDate == null || eventDate?.day == _selectedDate?.day;

    return matchesText && matchesCategory && matchesDate;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedDate = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  label: Text(
                    _selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                        : 'Pick Date',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_selectedDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedDate = null),
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Wrap(
              spacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val ? category : null;
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                  backgroundColor: Colors.grey.shade200,
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.deepOrange : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No events available.'));
                }

                final filteredEvents = snapshot.data!.docs
                    .where((doc) => _matchesSearch(doc.data() as Map<String, dynamic>))
                    .toList();

                if (filteredEvents.isEmpty) {
                  return const Center(child: Text('No matching events found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final doc = filteredEvents[index];
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
                        color: Colors.white, // 👈 Card background set to white
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: decodedImage != null
                                  ? Image.memory(
                                decodedImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 80,
                                height: 80,
                                color: Colors.orange.shade100,
                              //  child: const Icon(Icons.event, size: 32, color: Colors.deepOrange),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['name'] ?? 'Unnamed Event',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                       // const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          event['date'] ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (event['category'] != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          event['category'],
                                          style: const TextStyle(
                                            fontSize: 11,
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
          ),
        ],
      ),
    );
  }
}
