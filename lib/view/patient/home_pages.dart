import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medrec/view/patient/message_screen.dart';
import 'package:medrec/view/patient/patient_response_screen.dart';
import 'package:medrec/view/patient/profile_screen.dart';
import 'package:medrec/view/patient/record_detail_screen.dart';
import 'package:medrec/view/util/record.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _userName = 'User';
  String _welcomeMessage = '';
  String _searchQuery = '';
  late Stream<QuerySnapshot> _recordsStream;

  final String _encryptionKey =
      'my32lengthsupersecretnooneknows1'; // 32 bytes key
  final String _ivString = '1234567890123456'; // 16 bytes IV

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _updateWelcomeMessage();
    _setupRecordsStream();
  }

  // Decrypt method
  String _decrypt(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromUtf8(_ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv); // Decrypt the text
  }

  void _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('patients') // Adjusted to match the patient collection
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ??
              'User'; // Default to 'User' if name is not found
        });
      }
    }
  }

  void _updateWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _welcomeMessage = 'Good Morning';
    } else if (hour < 17) {
      _welcomeMessage = 'Good Afternoon';
    } else {
      _welcomeMessage = 'Good Evening';
    }
  }

  void _setupRecordsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _recordsStream = FirebaseFirestore.instance
          .collection('records')
          .where('patient_id', isEqualTo: user.uid) // Filter by user ID
          .snapshots();
    } else {
      // Handle the case where user is not authenticated
      _recordsStream = Stream.empty();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _recordsStream = FirebaseFirestore.instance
            .collection('records')
            .where('patient_id', isEqualTo: user.uid)
            .where('record_title', isGreaterThanOrEqualTo: _searchQuery)
            .where('record_title', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
            .snapshots();
      }
    });
  }

  DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      // Handle string date format if necessary
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now(); // Fallback in case of parsing error
      }
    } else {
      return DateTime.now(); // Fallback if the date type is unknown
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final user = FirebaseAuth.instance.currentUser;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MessageScreen()),
        );
        break;
      case 2:
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(patientId: user.uid)), // Pass patientId
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 96, 180),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Colors.blue),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.blue),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Greetings row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_welcomeMessage, $_userName',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientResponseScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.white),
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // How do you feel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  const SizedBox(height: 20),
                  // 4 different faces
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                color: const Color.fromARGB(255, 233, 230, 230),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Find all your medical records here',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Icon(Icons.more_horiz)
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _recordsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No records found'));
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: Text('Loading....'));
                            default:
                              return ListView(
                                children: snapshot.data!.docs.map((doc) {
                                  final String recordTitle =
                                      _decrypt(doc['title']);
                                  final String recordDate =
                                      _decrypt(doc['creation_date']);
                                  final String doctor = _decrypt(doc['doctor']);
                                  final String complications =
                                      _decrypt(doc['complications']);
                                  final String treatments =
                                      _decrypt(doc['treatments']);
                                  final String duration =
                                      _decrypt(doc['duration']);
                                  final String followUp =
                                      _decrypt(doc['follow_up_date']);

                                  return GestureDetector(
                                    onTap: () {
                                      final String formattedDate =
                                          _parseDate(recordDate).toString();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecordDetailScreen(
                                            recordName: recordTitle,
                                            date: formattedDate,
                                            doctor: doctor,
                                            complications: complications,
                                            treatments: treatments,
                                            duration: duration,
                                            followUp: followUp,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Record(
                                      recordName: recordTitle,
                                      date: _parseDate(recordDate).toString(),
                                      doctor: doctor,
                                    ),
                                  );
                                }).toList(),
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
