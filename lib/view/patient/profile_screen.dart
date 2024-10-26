import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String patientId;

  const ProfileScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _name = '';
  String _email = '';
  String _avatarUrl = ''; // URL for avatar image
  List<DocumentSnapshot> _authorizedDoctors = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchAuthorizedDoctors();
  }

  Future<void> _fetchUserData() async {
    final userDoc =
        await _firestore.collection('users').doc(widget.patientId).get();
    if (userDoc.exists) {
      setState(() {
        _name = userDoc['name'] ?? 'N/A';
        _email = userDoc['email'] ?? 'N/A';
        _avatarUrl = userDoc['avatar_url'] ?? ''; // Fetch avatar URL
      });
    }
  }

  Future<void> _fetchAuthorizedDoctors() async {
    try {
      final authorizationSnapshot = await _firestore
          .collection('authorization_requests')
          .where('patient_id', isEqualTo: widget.patientId)
          .where('status', isEqualTo: 'approved')
          .get();

      List<DocumentSnapshot> authorizedDoctors = [];

      for (var doc in authorizationSnapshot.docs) {
        final doctorId = doc['doctor_id'];
        final doctorDoc =
            await _firestore.collection('users').doc(doctorId).get();

        if (doctorDoc.exists) {
          authorizedDoctors.add(doctorDoc);
        }
      }

      setState(() {
        _authorizedDoctors = authorizedDoctors;
      });
    } catch (e) {
      print('Error fetching authorized doctors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load authorized doctors.')),
      );
    }
  }

  Future<void> _revokeDoctorAuthorization(String doctorId) async {
    try {
      // Fetch the specific authorization request document to revoke
      final querySnapshot = await _firestore
          .collection('authorization_requests')
          .where('doctor_id', isEqualTo: doctorId)
          .where('patient_id', isEqualTo: widget.patientId)
          .where('status', isEqualTo: 'approved')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Revoke the authorization
        await _firestore
            .collection('authorization_requests')
            .doc(querySnapshot.docs.first.id)
            .update({
          'status': 'revoked',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor authorization revoked!')),
        );
        _fetchAuthorizedDoctors(); // Refresh the list
      }
    } catch (e) {
      print('Error revoking authorization: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to revoke authorization.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundImage: _avatarUrl.isNotEmpty
                    ? NetworkImage(_avatarUrl)
                    : AssetImage('assets/default_avatar.png')
                        as ImageProvider, // Placeholder image
                child: _avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              SizedBox(height: 20),
              Text(
                'Your Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildProfileInfo('Name', _name),
              _buildProfileInfo('Email', _email),
              SizedBox(height: 20),
              Text(
                'Authorized Doctors',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: _authorizedDoctors.isEmpty
                    ? Center(child: Text('No authorized doctors found.'))
                    : ListView.builder(
                        itemCount: _authorizedDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _authorizedDoctors[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(doctor['name']),
                              subtitle: Text(doctor['email']),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    _revokeDoctorAuthorization(doctor.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
