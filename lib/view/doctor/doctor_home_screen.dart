import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'patient_profile.dart';

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  String _searchQuery = '';
  Stream<QuerySnapshot> _patientsStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _patientsStream = FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: _searchQuery)
          .where('email', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .where('role', isEqualTo: 'patient')
          .snapshots();
    });
  }

  Future<void> _sendNotificationToPatient(String doctorId, String doctorName,
      String recordTitle, String patientId) async {
    await FirebaseFirestore.instance.collection('patient_notifications').add({
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'patient_id': patientId,
      'record_name': recordTitle,
      'access_time': FieldValue.serverTimestamp(),
      'status': 'unread',
    });
  }

  Future<void> _requestAccess(String patientId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('authorization_requests').add({
      'doctor_id': currentUser.uid,
      'patient_id': patientId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Authorization request sent to patient.')),
    );
  }

  Future<void> _checkAuthorizationAndNavigate(String patientId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final doctorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final doctorData = doctorDoc.data();

    if (doctorData != null && doctorData['role'] == 'doctor') {
      final authorizationQuery = await FirebaseFirestore.instance
          .collection('authorization_requests')
          .where('doctor_id', isEqualTo: currentUser.uid)
          .where('patient_id', isEqualTo: patientId)
          .where('status', isEqualTo: 'approved')
          .get();

      if (authorizationQuery.docs.isNotEmpty) {
        // Fetch doctor's name for the notification
        String doctorName =
            doctorData['name'] ?? 'Doctor'; // Ensure you have the 'name' field

        // Fetch record title or set it to a default value
        String recordTitle =
            'Medical Booklet'; // Or fetch from the relevant record if necessary

        // Send notification after confirming authorization
        _sendNotificationToPatient(
            currentUser.uid, doctorName, recordTitle, patientId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientProfile(patientId: patientId),
          ),
        );
      } else {
        await _requestAccess(patientId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('You are not authorized to access this patient record.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 96, 180),
      appBar: AppBar(
        title: Text('Doctor Home'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for patients',
                      hintStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _patientsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No patients found.',
                            style: TextStyle(color: Colors.white)));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return GestureDetector(
                        onTap: () {
                          _checkAuthorizationAndNavigate(doc.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    doc['email'][0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  doc['email'],
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
