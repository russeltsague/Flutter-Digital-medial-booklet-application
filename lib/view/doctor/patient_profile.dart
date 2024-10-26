import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'add_record.dart';
import 'record_detail_screen.dart';
import 'doctor_message_screen.dart';
import 'medication_prescription.dart';
import 'package:medrec/view/util/record.dart';

class PatientProfile extends StatefulWidget {
  final String patientId;

  PatientProfile({required this.patientId});

  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  late Stream<QuerySnapshot> _recordsStream = Stream.empty();
  String _searchQuery = '';
  int _selectedIndex = 0;

  // Hardcoded key and IV (Initialization Vector)
  final String _encryptionKey =
      'my32lengthsupersecretnooneknows1'; // 32 bytes key
  final String _ivString = '1234567890123456'; // 16 bytes IV

  @override
  void initState() {
    super.initState();
    _setupRecordsStream();
  }

  void _setupRecordsStream() {
    _recordsStream = FirebaseFirestore.instance
        .collection('records')
        .where('patient_id', isEqualTo: widget.patientId)
        .snapshots();
  }

  String _decrypt(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromUtf8(_ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv); // Decrypt the text
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _recordsStream = FirebaseFirestore.instance
          .collection('records')
          .where('patient_id', isEqualTo: widget.patientId)
          .where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .snapshots();
    });
  }

  DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception('Unsupported date type');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildRecordScreen();
      case 1:
        return DoctorMessagesScreen();
      case 2:
        return MedicationPrescriptionScreen();
      default:
        return _buildRecordScreen();
    }
  }

  Widget _buildRecordScreen() {
    final currentUser =
        FirebaseAuth.instance.currentUser; // Get the current doctor
    final String doctorId = currentUser?.uid ?? ''; // Get the doctor's ID
    final String doctorName =
        currentUser?.displayName ?? 'Doctor'; // Get the doctor's name

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Patient Records',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        hintText: 'Search Records',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _recordsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No records found.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final String recordTitle = _decrypt(doc['title']);
                    final String recordDate = _decrypt(
                        doc['creation_date']); // Decrypt the creation date
                    final DateTime parsedDate =
                        _parseDate(recordDate); // Convert to DateTime
                    final String formattedDate =
                        '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}'; // Format date

                    final String doctor = _decrypt(doc['doctor']);
                    final String complications = _decrypt(doc['complications']);
                    final String treatments = _decrypt(doc['treatments']);
                    final String duration = _decrypt(doc['duration']);
                    final String followUp = _decrypt(doc['follow_up_date']);

                    // Send notification to the patient
                    _sendNotificationToPatient(
                        doctorId, doctorName, recordTitle, widget.patientId);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordDetailScreen(
                              recordName: recordTitle,
                              date: formattedDate, // Use formatted date
                              doctor: doctor,
                              complications: complications,
                              treatments: treatments,
                              duration: duration,
                              followUp: followUp,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        child: Record(
                          recordName: recordTitle,
                          date: formattedDate, // Use formatted date
                          doctor: doctor,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 96, 180),
      appBar: AppBar(
        title: Text('Patient Profile'),
      ),
      body: _getBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddRecordScreen(patientId: widget.patientId)),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null, // Hide FAB when not on the Patient Profile screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medications',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
      ),
    );
  }
}
