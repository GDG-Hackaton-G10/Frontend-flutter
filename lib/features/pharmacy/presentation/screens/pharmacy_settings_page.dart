import 'package:flutter/material.dart';

class PharmacySettingsPage extends StatefulWidget {
  const PharmacySettingsPage({super.key});

  @override
  State<PharmacySettingsPage> createState() => _PharmacySettingsPageState();
}

class _PharmacySettingsPageState extends State<PharmacySettingsPage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacy Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Pharmacy Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Pharmacy Location'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Save logic here (persist if needed)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pharmacy info updated!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
