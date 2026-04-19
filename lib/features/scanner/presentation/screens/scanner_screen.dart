import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_prescription_navigator/core/index.dart';

import '../../../pharmacy_map/presentation/screens/map_screen.dart';
import '../../data/services/ocr_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final WidgetService _widgetService = const WidgetService();

  File? _capturedImage;
  String? _recognizedText;
  bool _isProcessing = false;

  late final AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

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
            'Camera permission is permanently denied. Enable it in settings to scan prescriptions.',
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

  Future<void> _openMapWithQuery() async {
    final detectedQuery = _extractFirstDetectedString(_recognizedText);
    final widgetName = detectedQuery ?? 'Scanned Medicine';

    await _widgetService.saveWidgetData(widgetName);

    HapticFeedback.mediumImpact();

    if (!mounted) {
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
        imageQuality: 90,
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

      HapticFeedback.mediumImpact();
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Scanner Studio',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _captureAndScan,
        backgroundColor: AppTheme.primary,
        child: _isProcessing
            ? const AppLoadingSpinner(
                size: AppSpinnerSize.small,
                color: Colors.white,
              )
            : const Icon(Icons.camera_alt_rounded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Capture medicine labels and send results directly to pharmacy search.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _PreviewCard(
                      imageFile: _capturedImage,
                      isProcessing: _isProcessing,
                      lineController: _lineController,
                    ),
                    const SizedBox(height: 16),
                    _ResultCard(recognizedText: _recognizedText),
                    const SizedBox(height: 16),
                    AppButton.primary(
                      label: 'Confirm and Open Map',
                      leadingIcon: Icons.map_rounded,
                      onPressed: _capturedImage == null
                          ? null
                          : () {
                              _openMapWithQuery();
                            },
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
  const _PreviewCard({
    required this.imageFile,
    required this.isProcessing,
    required this.lineController,
  });

  final File? imageFile;
  final bool isProcessing;
  final AnimationController lineController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Preview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final frameHeight = constraints.maxWidth * 0.82;

              return SizedBox(
                height: frameHeight,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        width: double.infinity,
                        color: Colors.black.withValues(alpha: 0.16),
                        child: imageFile == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.document_scanner_outlined,
                                      size: 56,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      isProcessing
                                          ? 'Scanning image...'
                                          : 'Tap camera to capture label',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )
                            : (kIsWeb
                                  ? Image.network(
                                      imageFile!.path,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.file(
                                                imageFile!,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : Image.file(imageFile!, fit: BoxFit.cover)),
                      ),
                    ),
                    const Positioned(
                      left: 18,
                      top: 18,
                      child: _ViewfinderBracket(corner: _BracketCorner.topLeft),
                    ),
                    const Positioned(
                      right: 18,
                      top: 18,
                      child: _ViewfinderBracket(
                        corner: _BracketCorner.topRight,
                      ),
                    ),
                    const Positioned(
                      left: 18,
                      bottom: 18,
                      child: _ViewfinderBracket(
                        corner: _BracketCorner.bottomLeft,
                      ),
                    ),
                    const Positioned(
                      right: 18,
                      bottom: 18,
                      child: _ViewfinderBracket(
                        corner: _BracketCorner.bottomRight,
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.center_focus_strong_rounded,
                                  size: 18,
                                  color: AppTheme.textPrimary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Position the label within the frame.',
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (imageFile != null || isProcessing)
                      AnimatedBuilder(
                        animation: lineController,
                        builder: (context, child) {
                          return Positioned(
                            left: 20,
                            right: 20,
                            top:
                                54 +
                                (lineController.value * (frameHeight - 108)),
                            child: child!,
                          );
                        },
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withValues(alpha: 0),
                                AppTheme.primary,
                                AppTheme.accent,
                                AppTheme.primary.withValues(alpha: 0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _BracketCorner { topLeft, topRight, bottomLeft, bottomRight }

class _ViewfinderBracket extends StatelessWidget {
  const _ViewfinderBracket({required this.corner});

  final _BracketCorner corner;

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      color: Colors.white.withValues(alpha: 0.95),
      width: 2,
    );

    final border = switch (corner) {
      _BracketCorner.topLeft => Border(top: borderSide, left: borderSide),
      _BracketCorner.topRight => Border(top: borderSide, right: borderSide),
      _BracketCorner.bottomLeft => Border(bottom: borderSide, left: borderSide),
      _BracketCorner.bottomRight => Border(
        bottom: borderSide,
        right: borderSide,
      ),
    };

    return SizedBox(
      width: 34,
      height: 34,
      child: DecoratedBox(decoration: BoxDecoration(border: border)),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.recognizedText});

  final String? recognizedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OCR Results',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              recognizedText ?? 'Scanned text will appear here after OCR.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: recognizedText == null
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
