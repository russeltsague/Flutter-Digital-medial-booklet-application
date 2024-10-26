// // access_request_screen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AccessRequestScreen extends StatefulWidget {
//   final String patientId;

//   AccessRequestScreen({required this.patientId});

//   @override
//   _AccessRequestScreenState createState() => _AccessRequestScreenState();
// }

// class _AccessRequestScreenState extends State<AccessRequestScreen> {
//   late Stream<QuerySnapshot> _requestsStream;

//   @override
//   void initState() {
//     super.initState();
//     _requestsStream = FirebaseFirestore.instance
//         .collection('access_requests')
//         .where('patient_id', isEqualTo: widget.patientId)
//         .where('status', isEqualTo: 'pending')
//         .snapshots();
//   }

//   void _updateRequestStatus(String requestId, String status) async {
//     await FirebaseFirestore.instance
//         .collection('access_requests')
//         .doc(requestId)
//         .update({
//       'status': status,
//     });
//     // Send notification to doctor or patient as needed
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Access Requests')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _requestsStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No access requests.'));
//           }
//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               return ListTile(
//                 title: Text('Request from ${doc['doctor_name']}'),
//                 subtitle: Text('Message: ${doc['message']}'),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.check),
//                       onPressed: () =>
//                           _updateRequestStatus(doc.id, 'authorized'),
//                     ),
//                     // IconButton(
//                     //   icon: Icon(Icons.close),
//                     //   onPressed: () => _updateRequestStatus(doc.id, 'denied'),
//                     // ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
