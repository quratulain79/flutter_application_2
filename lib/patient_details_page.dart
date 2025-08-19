import 'package:flutter/material.dart';
import 'upload_ctscan_page.dart';

class PatientDetailsPage extends StatelessWidget {
  final dynamic patientData;

  const PatientDetailsPage({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    final name = patientData['name'] ?? 'No Name';
    final age = patientData['age'] ?? '';
    final email = patientData['email'] ?? '';
    final gender = patientData['gender'] ?? '';
    final phone = patientData['phone'] ?? '';
    final uid = patientData['uid'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('$name\'s Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Age: $age', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Gender: $gender', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Phone: $phone', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('UID: $uid', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadCTScanPage(),
                          // ✅ If you later want to pass UID, you can update UploadCTScanPage to accept it
                        ),
                      );
                    },
                    icon: const Icon(Icons.cloud_upload,color: Colors.white),
                    label: const Text('Upload CT-Scan',
                    style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('View Results Coming Soon!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment,color: Colors.white),
                    label: const Text('View Results',
                    style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
