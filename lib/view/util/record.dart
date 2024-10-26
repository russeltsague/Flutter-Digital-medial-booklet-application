import 'package:flutter/material.dart';

class Record extends StatelessWidget {
  final String recordName; // Reason
  final String date; // Date of the record
  final String doctor; // Doctor's name

  const Record({
    super.key,
    required this.recordName,
    required this.date,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main topic (Reason) in blue
            Text(
              recordName, // Display only the reason
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20, // Adjust font size for emphasis
                color: Colors.blue, // Color for the reason
              ),
            ),
            const SizedBox(height: 8),
            // Record date with icon
            _buildInfoRow(Icons.calendar_today, 'Date: $date'),
            const SizedBox(height: 8),
            // Doctor's name with icon
            _buildInfoRow(Icons.person, 'Doctor: Dr. $doctor'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
