import 'package:flutter/material.dart';

class EmoticonFace extends StatelessWidget {
  final String emoticon;
  const EmoticonFace({
    super.key,
    required this.emoticon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Text(emoticon, style: const TextStyle(fontSize: 28)),
      //find a way to insert emoji
    );
  }
}
