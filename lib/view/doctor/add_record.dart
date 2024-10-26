import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AddRecordScreen extends StatefulWidget {
  final String patientId; // Pass the patient ID

  AddRecordScreen({required this.patientId});

  @override
  _AddRecordScreenState createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _reasonController = TextEditingController();
  final _complicationsController = TextEditingController();
  final _treatmentsController = TextEditingController();
  final _hospitalizationDurationController = TextEditingController();
  final _postHospitalizationFollowupController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _doctorName = ''; // To hold the doctor's name

  // Hardcoded key and IV (Initialization Vector)
  final String _encryptionKey =
      'my32lengthsupersecretnooneknows1'; // 32 bytes key
  final String _ivString = '1234567890123456'; // 16 bytes IV

  @override
  void initState() {
    super.initState();
    _fetchDoctorName(); // Fetch the doctor's name when the screen initializes
  }

  Future<void> _fetchDoctorName() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch the doctor information from Firestore using the user ID
        DocumentSnapshot doctorDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doctorDoc.exists) {
          setState(() {
            _doctorName = doctorDoc['name'] ??
                'Doctor'; // Assuming the name field is 'name'
          });
        }
      } catch (e) {
        print('Error fetching doctor name: $e');
      }
    }
  }

  String _encrypt(String plaintext) {
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromUtf8(_ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return encrypted.base64; // Return the base64 encoded encrypted string
  }

  Future<void> _saveRecord() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('records').add({
          'patient_id': widget.patientId, // Use the passed patient ID
          'doctor_id': user.uid, // Save the doctor ID
          'doctor': _encrypt(_doctorName), // Encrypt the doctor's name
          'title': _encrypt(_reasonController.text), // Encrypt before saving
          'complications': _encrypt(_complicationsController.text), // Encrypt
          'treatments': _encrypt(_treatmentsController.text), // Encrypt
          'duration':
              _encrypt(_hospitalizationDurationController.text), // Encrypt
          'follow_up_date':
              _encrypt(_postHospitalizationFollowupController.text), // Encrypt
          'creation_date': _encrypt(
              DateTime.now().toIso8601String()), // Encrypt current date
        });

        Navigator.pop(context);
      } catch (e) {
        print('Error saving record: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Medical Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _reasonController,
              decoration:
                  InputDecoration(labelText: 'Reason for hospitalization'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Doctor\'s Name: $_doctorName',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _complicationsController,
              decoration: InputDecoration(labelText: 'Complications'),
            ),
            TextField(
              controller: _treatmentsController,
              decoration: InputDecoration(labelText: 'Treatments'),
              maxLines: 3,
            ),
            TextField(
              controller: _hospitalizationDurationController,
              decoration: InputDecoration(
                  labelText: 'Duration of Hospitalization (days)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _postHospitalizationFollowupController,
              decoration:
                  InputDecoration(labelText: 'Post-hospitalization Follow-up'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRecord,
              child: Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }
}
