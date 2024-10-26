// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class RecordReaderScreen extends StatefulWidget {
//   RecordReaderScreen(this.doc, {super.key});

//   QueryDocumentSnapshot doc;

//   @override
//   State<RecordReaderScreen> createState() => _RecordReaderScreenState();
// }

// class _RecordReaderScreenState extends State<RecordReaderScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amber,
//       appBar: AppBar(
//         backgroundColor: Colors.amber,
//         elevation: 0.0,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(widget.doc["record_title"].toString(),
//                 style: TextStyle(fontSize: 18)),
//             Text(widget.doc["creation_date"].toString(),
//                 style: TextStyle(fontSize: 14)),
//             SizedBox(height: 10),
//             Text(widget.doc["record_content"].toString()),
//           ],
//         ),
//       ),
//     );
//   }
// }
