import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/medicine_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _medicineInfo;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
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
                  // SEARCH BAR with Mic
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white70),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search for medicine...",
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                            onSubmitted: (_) => _handleSearch(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : Colors.white70,
                          ),
                          onPressed: _toggleListening,
                        ),
                        if (_isSearching)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white70),
                            onPressed: _handleSearch,
                          ),
                      ],
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
                  if (_medicineInfo != null) ...[
                    _buildMedicineInfoCard(),
                    const SizedBox(height: 16),
                  ],
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
            heroTag: 'callFab',
            onPressed: _makePhoneCall,
            backgroundColor: Colors.green,
            shape: const CircleBorder(),
            child: const Icon(Icons.phone, color: Colors.white, size: 28),
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

  Widget _buildMedicineInfoCard() {
    final info = _medicineInfo!['medicine_info'];
    final prescriptionRequired = info['prescription_required'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  info['corrected_name'] ?? 'Unknown Medicine',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!prescriptionRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'No Prescription',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info['generic_name'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            info['category'] ?? '',
            style: const TextStyle(color: Colors.white60, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          _buildInfoSection('Uses', info['uses']),
          const SizedBox(height: 8),
          _buildInfoSection('Dosage', [info['dosage']]),
          const SizedBox(height: 8),
          _buildInfoSection('Side Effects', info['side_effects']),
          const SizedBox(height: 8),
          _buildInfoSection('Precautions', info['precautions']),
          if (info['alternative_medicines'] != null && info['alternative_medicines'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoSection('alternative_medicines', [info['alternative_medicines']]),
          ],
          if (!prescriptionRequired) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isOrdering ? null : () => _handleDirectOrder(info['corrected_name']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isOrdering
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Order Now',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, dynamic content) {
    List<String> items = [];
    if (content is List) {
      items = content.map((e) => e.toString()).toList();
    } else if (content is String) {
      items = [content];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _handleSearch() async {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medicine name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _medicineInfo = null;
    });

    try {
      final response = await _medicineService.searchMedicine(medicineName: searchQuery);
      
      if (response['status'] == 'success' && response['medicine_info'] != null) {
        setState(() {
          _medicineInfo = response;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Medicine not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching medicine: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching medicine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _handleDirectOrder(String medicineName) async {
    setState(() {
      _isOrdering = true;
    });

    try {
      final response = await _medicineService.orderMedicine(
        medicines: [medicineName],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Medicine ordered successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _medicineInfo = null;
          _searchController.clear();
        });

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

  Future<void> _toggleListening() async {
    // Stop listening if already active
    if (_isListening) {
      setState(() => _isListening = false);
      await _speech.stop();
      return;
    }

    // Request microphone permission
    var status = await Permission.microphone.request();

    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Microphone permission denied"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enable microphone permission from Settings"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      openAppSettings();
      return;
    }

    // Initialize and start listening
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == "notListening" || status == "done") {
            if (mounted) {
              setState(() => _isListening = false);
            }
          }
        },
        onError: (e) {
          debugPrint('Speech error: ${e.errorMsg}');
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: ${e.errorMsg}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _searchController.text = result.recognizedWords;
              });
            }
          },
          partialResults: true,
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Speech recognition not available"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      if (mounted) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start microphone: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    try 
    {
      await FlutterPhoneDirectCaller.callNumber(phone_no);
    }
     catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
