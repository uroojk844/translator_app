import 'package:flutter/material.dart';

class TextArea extends StatelessWidget {
  const TextArea({
    super.key,
    required this.textController,
    required this.setHeight,
  });

  final VoidCallback setHeight;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextField(
        onTap: setHeight,
        controller: textController,
        maxLines: 8,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
