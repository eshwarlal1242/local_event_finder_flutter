import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  String? _profileImagePath;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _profileImagePath = pickedFile.path;
      });
      _saveProfileData();
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);
    if (_profileImagePath != null) {
      await prefs.setString('imagePath', _profileImagePath!);
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? 'Space dan';
      _emailController.text = prefs.getString('email') ?? 'sp@easports.com';
      _phoneController.text = prefs.getString('phone') ?? '567890456';
      _profileImagePath = prefs.getString('imagePath');
      if (_profileImagePath != null) {
        _profileImage = File(_profileImagePath!);
      }
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  (Colors.white),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                setState(() => _isEditMode = !_isEditMode);
                if (!_isEditMode) _saveProfileData();
              } else if (value == 'logout') {
                _logout();
              } else if (value == 'midDrivers') {
                // Add your mid driver action here
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(_isEditMode ? 'Done' : 'Edit')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: _isEditMode ? _pickImage : null,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage('assets/profile_image.png') as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _isEditMode
                          ? TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name"))
                          : _infoTile(Icons.person, "Full Name", _nameController.text),
                      _isEditMode
                          ? TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email"))
                          : _infoTile(Icons.email, "Email", _emailController.text),
                      _isEditMode
                          ? TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Contact"))
                          : _infoTile(Icons.phone, "Contact", _phoneController.text),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),

    );
  }
}
