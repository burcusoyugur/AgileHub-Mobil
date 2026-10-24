import 'package:flutter/material.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görevlerim')),
      body: const Center(
        child: Text('Görevlerim – 7. haftada geliştirilecek'),
      ),
    );
  }
}
