import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('home'),
      )


    );

  }
}







// import 'dart:io';
// import 'package:flutter/material.dart';
//
// import '../MapDemo.dart';
// import '../add_event.dart';
//
// import '../services/event_list.dart';
//
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final List<Map<String, dynamic>> events = [];
//
//   void _addEvent(String name, String city, File? image) {
//     setState(() {
//       events.add({'name': name, 'city': city, 'image': image});
//     });
//   }
//
//   void _navigateToMap(String city) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapScreen(cityName: city),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Local Events App")),
//       body: EventListScreen(events: events, onEventSelected: _navigateToMap),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddEventScreen(onEventAdded: _addEvent),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
