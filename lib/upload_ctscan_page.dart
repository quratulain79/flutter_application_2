import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UploadCTScanPage extends StatefulWidget {
  const UploadCTScanPage({super.key});

  @override
  State<UploadCTScanPage> createState() => _UploadCTScanPageState();
}

class _UploadCTScanPageState extends State<UploadCTScanPage> {
  io.File? _imageFile; // For mobile
  Uint8List? _imageBytes; // For web
  String? _result;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null;
          _result = null;
        });
      } else {
        setState(() {
          _imageFile = io.File(pickedFile.path);
          _imageBytes = null;
          _result = null;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null && _imageBytes == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(
        'http://127.0.0.1:5000/predict',
      ); // 🔁 Replace with real IP on phone
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageBytes!,
            filename: 'upload.png',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            filename: basename(_imageFile!.path),
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final decoded = jsonDecode(responseData.body);
        setState(() {
          _result = decoded['prediction'];
        });

        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
            content: Text('Prediction received successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image or get prediction!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload CT-Scan'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Select a CT-Scan Image to Upload',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text(
                  'Choose Image',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              if (_imageFile != null || _imageBytes != null)
                Column(
                  children: [
                    const Text(
                      'Preview:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.memory(
                                _imageBytes!,
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                _imageFile!,
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                )
              else
                Column(
                  children: const [
                    Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No image selected yet!',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 30),
                  ],
                ),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadImage,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: _isLoading
                    ? const Text(
                        'Uploading...',
                        style: TextStyle(color: Colors.white),
                      )
                    : const Text(
                        'Upload & Predict',
                        style: TextStyle(color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 30),
                Text(
                  'Prediction: $_result',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
