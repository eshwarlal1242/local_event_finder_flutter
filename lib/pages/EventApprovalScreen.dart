// import 'package:flutter/material.dart';
//
// class EventApprovalScreen extends StatelessWidget {
//   final Map<String, dynamic> eventData;
//   final VoidCallback onApprove;
//
//   const EventApprovalScreen({
//     Key? key,
//     required this.eventData,
//     required this.onApprove,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final Color orange = Color(0xFFFF6B00);
//     final Color white = Colors.white;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Approve Event"),
//         backgroundColor: orange,
//         iconTheme: IconThemeData(color: white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("📅 Name: ${eventData['name']}"),
//             Text("📝 Description: ${eventData['description']}"),
//             Text("📆 Date: ${eventData['date']}"),
//             Text("🎭 Category: ${eventData['category']}"),
//             Text("📍 Location: ${eventData['latitude']}, ${eventData['longitude']}"),
//             Text("📌 Status: ${eventData['status']}"),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: onApprove,
//                     icon: Icon(Icons.check, color: white),
//                     label: Text("Approve", style: TextStyle(color: white)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       minimumSize: Size(double.infinity, 50),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context, false); // rejected
//                     },
//                     icon: Icon(Icons.cancel, color: white),
//                     label: Text("Reject", style: TextStyle(color: white)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       minimumSize: Size(double.infinity, 50),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
