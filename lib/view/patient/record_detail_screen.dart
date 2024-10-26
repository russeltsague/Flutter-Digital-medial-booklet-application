import 'package:flutter/material.dart';

class RecordDetailScreen extends StatelessWidget {
  final String recordName;
  final String date;
  final String doctor;
  final String complications;
  final String treatments;
  final String duration;
  final String followUp;

  const RecordDetailScreen({
    required this.recordName,
    required this.date,
    required this.doctor,
    required this.complications,
    required this.treatments,
    required this.duration,
    required this.followUp,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recordName),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Record Name and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' $recordName',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Date: $date',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.medical_services,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Doctor Information
              _buildInfoRow(Icons.person, 'Doctor:', doctor),
              _buildInfoRow(Icons.warning, 'Complications:', complications),
              _buildInfoRow(Icons.healing, 'Treatments:', treatments),
              _buildInfoRow(Icons.timer, 'Duration:', duration),
              _buildInfoRow(Icons.calendar_today, 'Follow-Up:', followUp),

              SizedBox(height: 20),
              Text(
                'Remarks:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),

              // Remarks Card
              Card(
                elevation: 4,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Detailed remarks will go here.', // Placeholder for remarks content
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Add Remark Button
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build info rows with descriptive icons
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
