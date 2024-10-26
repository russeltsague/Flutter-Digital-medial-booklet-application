import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String profileImageUrl;
  final String lastMessage;
  final String lastMessageTime;

  Doctor({
    required this.name,
    required this.profileImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}

class MessageScreen extends StatelessWidget {
  final List<Doctor> doctors = [
    Doctor(
      name: 'Dr. John Doe',
      profileImageUrl: 'https://via.placeholder.com/150',
      lastMessage: 'Hello, how are you?',
      lastMessageTime: '12:45 PM',
    ),
    Doctor(
      name: 'Dr. Jane Smith',
      profileImageUrl: 'https://via.placeholder.com/150',
      lastMessage: 'Don’t forget your appointment.',
      lastMessageTime: '10:30 AM',
    ),
    // Add more doctors as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(doctor.profileImageUrl),
              ),
              title: Text(doctor.name),
              subtitle: Text(doctor.lastMessage),
              trailing: Text(doctor.lastMessageTime),
              onTap: () {
                // Navigate to chat screen for the selected doctor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(doctor: doctor),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChatDetailScreen extends StatelessWidget {
  final Doctor doctor;

  ChatDetailScreen({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              // Make a call to the doctor
            },
          ),
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {
              // Make a video call to the doctor
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Message list (placeholder for now)
            Expanded(
              child: ListView.builder(
                itemCount: 2, // Replace with actual number of messages
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(doctor.profileImageUrl),
                    ),
                    title: Text('Hello, how are you?'),
                    subtitle: Text('12:45 PM'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Message input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: Text('Send'),
                  onPressed: () {
                    // Send the message
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
