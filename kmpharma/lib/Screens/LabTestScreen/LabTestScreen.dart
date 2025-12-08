import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/lab_test_service.dart';
import 'widgets/upload_card.dart';
import 'widgets/analysis_result_card.dart';
import 'widgets/bottom_action_bar.dart';
import 'widgets/booked_tests_card.dart';

class BookLabTestScreen extends StatefulWidget {
  const BookLabTestScreen({super.key});

  @override
  State<BookLabTestScreen> createState() => _BookLabTestScreenState();
}

class _BookLabTestScreenState extends State<BookLabTestScreen> {
  PlatformFile? _pickedFile;
  final LabTestService _labTestService = LabTestService();
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _isBooking = false;
  bool _isLoadingTests = false;
  Map<String, dynamic>? _analysisResult;
  List<Map<String, dynamic>> _bookedTests = [];

  @override
  void initState() {
    super.initState();
    _loadBookedTests();
  }

  Future<void> _loadBookedTests() async {
    setState(() {
      _isLoadingTests = true;
    });

    try {
      final tests = await _labTestService.getUserLabTests();
      setState(() {
        _bookedTests = tests;
      });
    } catch (e) {
      debugPrint('Error loading booked tests: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTests = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              centerTitle: true,
              title: const Text(
                "Book a Lab Test",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UploadCard(
                    isUploading: _isUploading,
                    onUpload: _handleUpload,
                    pickedFile: _pickedFile,
                    onRemoveFile: () {
                      setState(() {
                        _pickedFile = null;
                        _analysisResult = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_analysisResult != null) ...[
                    AnalysisResultCard(result: _analysisResult!),
                    const SizedBox(height: 16),
                  ],
                  if (_isLoadingTests)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    BookedTestsCard(
                      bookedTests: _bookedTests,
                      onRefresh: _loadBookedTests,
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_analysisResult == null) {
      return BottomActionBar(
        isSubmitting: _isSubmitting,
        onSubmit: _handleSubmit,
      );
    }

    final recommendedTests = _analysisResult!['recommended_tests'] as List? ?? [];
    final testsCount = recommendedTests.length;

    return BottomBookingBar(
      testsCount: testsCount,
      isBooking: _isBooking,
      onBook: (testsCount > 0 && !_isBooking) ? _handleBooking : null,
    );
  }

  Future<void> _handleUpload() async {
    setState(() {
      _isUploading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e, st) {
      debugPrint('File pick error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a prescription first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    File? fileToSend;
    try {
      if (_pickedFile!.path != null && _pickedFile!.path!.isNotEmpty) {
        fileToSend = File(_pickedFile!.path!);
      } else {
        if (_pickedFile!.bytes == null) {
          throw Exception('No file bytes available to upload.');
        }
        final temp = File('${Directory.systemTemp.path}/${_pickedFile!.name}');
        await temp.writeAsBytes(_pickedFile!.bytes!, flush: true);
        fileToSend = temp;
      }

      final response = await _labTestService.analyzePrescription(file: fileToSend);

      debugPrint('=== Prescription Analysis Result ===');
      debugPrint('Phone Number: ${response['phone_number']}');
      debugPrint('Doctor: ${response['doctor']?['name']}');
      debugPrint('Specialization: ${response['doctor']?['specialization']}');
      debugPrint('Registration: ${response['doctor']?['registration_number']}');
      debugPrint('Diagnosis: ${response['diagnosis']}');
      debugPrint('Tests Found: ${response['tests_found']}');
      debugPrint('File URL: ${response['file_url']}');
      debugPrint('Recommended Tests: ${response['recommended_tests']}');
      debugPrint('===================================');

      setState(() {
        _analysisResult =
            (response is Map<String, dynamic>) ? response : Map<String, dynamic>.from(response);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Prescription analyzed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('Error uploading prescription: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing prescription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleBooking() async {
    final recommendedTests = _analysisResult!['recommended_tests'] as List? ?? [];
    
    if (recommendedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tests available to book'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final tests = recommendedTests.map((test) => test.toString()).toList();
      
      final response = await _labTestService.bookLabTest(
        tests: tests,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Lab test booked successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the booked tests list
        await _loadBookedTests();

        await Future.delayed(const Duration(milliseconds: 15));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error booking lab test: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking lab test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
}
