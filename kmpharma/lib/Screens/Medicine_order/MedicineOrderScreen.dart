import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/medicine_service.dart';
import 'widgets/upload_card.dart';
import 'widgets/analysis_result_card.dart';
import 'widgets/bottom_action_bar.dart';
import 'OrderHistoryScreen.dart';

class MedicineOrderScreen extends StatefulWidget {
  const MedicineOrderScreen({super.key});

  @override
  State<MedicineOrderScreen> createState() => _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends State<MedicineOrderScreen> {
  PlatformFile? _pickedFile;
  final MedicineService _medicineService = MedicineService();
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _isOrdering = false;
  Map<String, dynamic>? _analysisResult;
  List<Map<String, dynamic>> _orderedMedicines = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Order Medicine",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search for medicine...",
                        hintStyle: TextStyle(color: Colors.white54),
                        icon: Icon(Icons.search, color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'micFab',
            onPressed: () {},
            backgroundColor: Colors.blueAccent,
            shape: const CircleBorder(),
            child: const Icon(Icons.mic, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomBar(),
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

    final recommendedMedicines = _analysisResult!['recommended_medicines'] as List? ?? [];
    final medicinesCount = recommendedMedicines.length;

    return BottomOrderBar(
      medicinesCount: medicinesCount,
      isOrdering: _isOrdering,
      onOrder: (medicinesCount > 0 && !_isOrdering) ? _handleOrdering : null,
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

      final response = await _medicineService.analyzePrescription(file: fileToSend);

      debugPrint('=== Prescription Analysis Result ===');
      debugPrint('Doctor: ${response['doctor']?['name']}');
      debugPrint('Diagnosis: ${response['diagnosis']}');
      debugPrint('Recommended Medicines: ${response['recommended_medicines']}');
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

  Future<void> _handleOrdering() async {
    final recommendedMedicines = _analysisResult!['recommended_medicines'] as List? ?? [];
    
    if (recommendedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No medicines available to order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isOrdering = true;
    });

    try {
      final medicines = recommendedMedicines.map((medicine) => medicine.toString()).toList();
      
      final response = await _medicineService.orderMedicine(
        medicines: medicines,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Medicine ordered successfully'),
            backgroundColor: Colors.green,
          ),
        );


        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error ordering medicine: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ordering medicine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOrdering = false;
        });
      }
    }
  }
}
