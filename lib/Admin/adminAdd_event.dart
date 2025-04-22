import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_event/services/event_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../google_screen.dart';

class AdminaddEvent extends StatefulWidget {
  const AdminaddEvent({super.key});

  @override
  State<AdminaddEvent> createState() => _AdminaddEventState();
}

class _AdminaddEventState extends State<AdminaddEvent> {






  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  double? latitude;
  double? longitude;
  File? _selectedImage;
  String? _base64Image;
  String status = "Upcoming";
  String? category;

  @override
  void initState() {
    super.initState();
    _loadImageFromLocalStorage();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      setState(() => _selectedImage = image);

      List<int> imageBytes = await image.readAsBytes();
      _base64Image = base64Encode(imageBytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('event_image', _base64Image!);
    }
  }

  Future<void> _loadImageFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString('event_image');
    if (base64Image != null) {
      setState(() {
        _base64Image = base64Image;
      });
    }
  }

  void _selectLocation() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (selectedLocation != null) {
      setState(() {
        latitude = selectedLocation.latitude;
        longitude = selectedLocation.longitude;
      });
    }
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _submit() async {
    if (_nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        category != null &&
        latitude != null &&
        longitude != null) {
      try {
        await FirebaseFirestore.instance.collection('events').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'date': _dateController.text,
          'category': category,
          'latitude': latitude,
          'longitude': longitude,
          'status': status,
          'image_base64': _base64Image ?? '',
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🎉 Event Added Successfully!")),
        );

        _nameController.clear();
        _descriptionController.clear();
        _dateController.clear();

        setState(() {
          category = null;
          latitude = null;
          longitude = null;
          _selectedImage = null;
          _base64Image = null;
          status = "Upcoming";
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventListScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding event: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please fill all fields!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color orange = Color(0xFFFF6B00);
    final Color white = Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: orange,
        title: Text("Add Event", style: TextStyle(color: white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: white),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: screenWidth * 0.8,
                  height: 200,
                  decoration: BoxDecoration(
                    color: orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    image: _selectedImage != null
                        ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                        : _base64Image != null
                        ? DecorationImage(
                      image: MemoryImage(base64Decode(_base64Image!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (_selectedImage == null && _base64Image == null)
                      ? Icon(Icons.add_a_photo, size: 40, color: orange)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Event Name", orange),
              SizedBox(height: 10),
              _buildTextField(_descriptionController, "Event Description", orange),
              SizedBox(height: 10),
              _buildTextField(_dateController, "Event Date", orange, readOnly: true, onTap: _selectDate),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: _inputDecoration("Category", orange),
                items: ["Music", "Sports", "Tech", "Food", "Arts"].map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => setState(() => category = value),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _selectLocation,
                icon: Icon(Icons.location_on, color: white),
                label: Text("Select Event Location", style: TextStyle(color: white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),
              Text("Event Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRadioButton("Upcoming", orange),
                  _buildRadioButton("Past", orange),
                ],
              ),
              SizedBox(height: 6),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Submit", style: TextStyle(fontSize: 18, color: white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black87),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, Color color,
      {bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _inputDecoration(label, color),
    );
  }

  Widget _buildRadioButton(String value, Color color) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: status,
          activeColor: color,
          onChanged: (val) => setState(() => status = val.toString()),
        ),
        Text(value),
      ],
    );
  }
}
