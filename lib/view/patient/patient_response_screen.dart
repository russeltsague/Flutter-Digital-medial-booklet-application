import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientResponseScreen extends StatefulWidget {
  const PatientResponseScreen({super.key});

  @override
  _PatientResponseScreenState createState() => _PatientResponseScreenState();
}

class _PatientResponseScreenState extends State<PatientResponseScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Fetch the current user
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Handle the case where there is no current user
      return Scaffold(
        appBar: AppBar(
          title: Text('Authorization Requests'),
        ),
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Authorization Requests & Notifications'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('authorization_requests')
                  .where('patient_id', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No authorization requests'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final request = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Doctor: ${request['doctor_name']}'),
                      subtitle:
                          Text('Requested on: ${request['request_date']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _respondToRequest(doc.id, 'approved');
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              _respondToRequest(doc.id, 'denied');
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('patient_notifications')
                  .where('patient_id', isEqualTo: currentUser.uid)
                  .orderBy('access_time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No notifications'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final notification = doc.data() as Map<String, dynamic>;
                    return _buildNotificationTile(notification, doc.id);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      Map<String, dynamic> notification, String notificationId) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text('From: ${notification['doctor_name']}'),
        subtitle: Text('Record Accessed: ${notification['record_name']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (notification['access_time'] as Timestamp).toDate().toString(),
              style: TextStyle(fontSize: 12),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteNotificationDialog(notificationId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('patient_notifications')
        .doc(notificationId)
        .delete();
  }

  void _showDeleteNotificationDialog(String notificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Notification'),
          content: Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteNotification(notificationId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _respondToRequest(String requestId, String status) async {
    await FirebaseFirestore.instance
        .collection('authorization_requests')
        .doc(requestId)
        .update({'status': status});
  }
}
