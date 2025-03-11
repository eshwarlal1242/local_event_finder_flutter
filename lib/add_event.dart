import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_event/services/location_screen/location_Screen.dart';

import 'MapDemo.dart';



class AddEventScreen extends StatefulWidget {
  final Function(String, String, File?, LatLng?) onEventAdded;

  const AddEventScreen({super.key, required this.onEventAdded});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  String? selectedCategory;
  File? _image;
  LatLng? selectedLocation;

  final List<String> categories = ['Music', 'Art', 'Sports', 'Tech', 'Food', 'Business'];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _pickLocation() async {
    LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(),
      ),
    );

    if (pickedLocation != null) {
      setState(() => selectedLocation = pickedLocation);
    }
  }

  void _saveEvent() {
    if (_eventNameController.text.isNotEmpty && selectedCategory != null && selectedLocation != null) {
      widget.onEventAdded(_eventNameController.text, selectedCategory!, _image, selectedLocation);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all event details.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: "Event Name"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Select Category"),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: const Text("Pick Event Image")),
            const SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover)
                : const Text("No Image Selected"),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickLocation, child: const Text("Pick Event Location")),
            selectedLocation != null
                ? Text("Location: (${selectedLocation!.latitude}, ${selectedLocation!.longitude})")
                : const Text("No Location Selected"),
            const Spacer(),
            ElevatedButton(onPressed: _saveEvent, child: const Text("Save Event")),
          ],
        ),
      ),
    );
  }
}
