
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:local_event/pages/bottombar/profile_screen.dart';
import 'package:local_event/pages/onboaring_screen.dart';
import 'package:local_event/pages/signin.dart';
import 'package:local_event/pages/signup.dart';
import 'package:local_event/services/event_list.dart';

import 'Admin/admin_screen.dart';
import 'MapDemo.dart';
import 'add_event.dart';
import 'google_screen.dart';
import 'homepages.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps Demo',

      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:  AddEventScreen(), // Set HomeScreen as the initial screen
    );
  }
}

