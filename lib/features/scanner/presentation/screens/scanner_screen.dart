import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/services/ocr_service.dart';
import '../../../pharmacy_map/presentation/screens/map_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final OCRService _ocrService = OCRService();

  File? _capturedImage;
  String? _recognizedText;
  bool _isProcessing = false;

  Future<bool> _ensureCameraPermission() async {
    var cameraStatus = await Permission.camera.status;

    if (cameraStatus.isGranted) {
      return true;
    }

    if (cameraStatus.isDenied) {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus.isGranted) {
        return true;
      }
    }

    if (cameraStatus.isPermanentlyDenied && mounted) {
      _showSettingsSnackBar(
        message:
            'Camera permission is permanently denied. Please enable it in App Settings to scan prescriptions.',
      );
    }

    return false;
  }

  void _showSettingsSnackBar({required String message}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
  }

  String? _extractFirstDetectedString(String? text) {
    if (text == null) {
      return null;
    }

    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return null;
    }

    return lines.first;
  }

  void _openMapWithQuery() {
    final detectedQuery = _extractFirstDetectedString(_recognizedText);
    if (detectedQuery == null || detectedQuery.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MapScreen(searchQuery: detectedQuery)),
    );
  }

  Future<void> _captureAndScan() async {
    final hasCameraPermission = await _ensureCameraPermission();
    if (!hasCameraPermission) {
      return;
    }

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _capturedImage = File(pickedImage.path);
        _recognizedText = null;
        _isProcessing = true;
      });

      final extractedText = await _ocrService.processImage(_capturedImage!);

      if (!mounted) {
        return;
      }

      setState(() {
        _recognizedText = extractedText.trim().isEmpty
            ? 'No readable text found in the image.'
            : extractedText.trim();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _recognizedText = 'Unable to scan the image. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _captureAndScan,
        child: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.camera_alt_outlined),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Capture a prescription label or document and extract the text instantly.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _PreviewCard(
                      imageFile: _capturedImage,
                      isProcessing: _isProcessing,
                    ),
                    const SizedBox(height: 16),
                    _ResultCard(recognizedText: _recognizedText),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isProcessing || _recognizedText == null
                          ? null
                          : _openMapWithQuery,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Confirm and Open Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.imageFile, required this.isProcessing});

  final File? imageFile;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFFF0F2F6),
                  child: imageFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.document_scanner_outlined,
                                size: 52,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isProcessing
                                    ? 'Scanning image...'
                                    : 'Tap the camera button to scan',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.recognizedText});

  final String? recognizedText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recognized Text',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6EAF0)),
              ),
              child: Text(
                recognizedText ?? 'The scanned text will appear here.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: recognizedText == null
                      ? Colors.black45
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
