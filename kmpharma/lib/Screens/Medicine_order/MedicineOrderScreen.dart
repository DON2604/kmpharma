import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/medicine_service.dart';
import 'package:kmpharma/services/cart_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'widgets/upload_card.dart';
import 'widgets/analysis_result_card.dart';
import 'widgets/bottom_action_bar.dart';
import 'OrderHistoryScreen.dart';
import 'CartScreen.dart';

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
  bool _isAddingToCart = false;
  Map<String, dynamic>? _analysisResult;
  List<Map<String, dynamic>> _orderedMedicines = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _medicineInfo;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final count = await CartService.getCartCount();
    if (mounted) {
      setState(() => _cartCount = count);
    }
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  FloatingActionButton(
                    heroTag: 'cartFab',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                      _loadCartCount();
                    },
                    backgroundColor: Colors.blueAccent,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                  ),
                  if (_cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'callFab',
                onPressed: _makePhoneCall,
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                child: const Icon(Icons.phone, color: Colors.white, size: 28),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomBar(),
        ),
      ),
    );
  }

  Widget? _buildBottomBar() {
    // Show upload button only when a file is picked and not yet uploaded
    if (_pickedFile != null && _analysisResult == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Upload Prescription',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    }
    return null;
  }

  // Widget _buildBottomOrderBar() {
  //   final recommendedMedicines =
  //       _analysisResult!['recommended_medicines'] as List? ?? [];
  //   final medicinesCount = recommendedMedicines.length;

  //   return BottomOrderBar(
  //     medicinesCount: medicinesCount,
  //     isOrdering: _isOrdering,
  //     isAddingToCart: _isAddingToCart,
  //     onAddToCart: (medicinesCount > 0 && !_isAddingToCart) ? _handleAddAllToCart : null,
  //     onOrder: (medicinesCount > 0 && !_isOrdering) ? _handleOrdering : null,
  //   );
  // }

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

      final response = await _medicineService.uploadPrescription(
        file: fileToSend,
      );

      debugPrint('=== Prescription Upload Result ===');
      debugPrint('Phone Number: ${response['phone_number']}');
      debugPrint('File URL: ${response['file_url']}');
      debugPrint('Message: ${response['message']}');
      debugPrint('===================================');

      if (mounted) {
        // Show success modal bottom sheet
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prescription Uploaded!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will get a call soon',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pop(context); // Pop the screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('Error uploading prescription: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading prescription: $e'),
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

  Future<void> _handleAddAllToCart() async {
    final recommendedMedicines =
        _analysisResult!['recommended_medicines'] as List? ?? [];

    if (recommendedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No medicines available to add'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      for (final medicine in recommendedMedicines) {
        final medicineInfo = {
          'name': medicine.toString(),
        };
        await CartService.addToCart(medicineInfo);
      }

      await _loadCartCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${recommendedMedicines.length} medicine(s) added to cart',
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
                _loadCartCount();
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding medicines to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _handleOrdering() async {
    final recommendedMedicines =
        _analysisResult!['recommended_medicines'] as List? ?? [];

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
      final medicines = recommendedMedicines
          .map((medicine) => medicine.toString())
          .toList();

      final response = await _medicineService.orderMedicine(
        medicines: medicines,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Medicine ordered successfully',
            ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: prescriptionRequired 
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: prescriptionRequired ? Colors.red : Colors.green,
                  ),
                ),
                child: Text(
                  prescriptionRequired 
                      ? 'Prescription Required' 
                      : 'No Prescription',
                  style: TextStyle(
                    color: prescriptionRequired ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
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
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoSection('Uses', info['uses']),
          const SizedBox(height: 8),
          _buildInfoSection('Dosage', [info['dosage']]),
          const SizedBox(height: 8),
          _buildInfoSection('Side Effects', info['side_effects']),
          const SizedBox(height: 8),
          _buildInfoSection('Precautions', info['precautions']),
          if (info['alternative_medicines'] != null &&
              info['alternative_medicines'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoSection('alternative_medicines', [
              info['alternative_medicines'],
            ]),
          ],
          // Action buttons for searched medicine
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleAddToCart(info),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isOrdering
                      ? null
                      : () => _handleDirectOrder(info['corrected_name']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: prescriptionRequired 
                        ? Colors.orange 
                        : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isOrdering
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.shopping_bag, size: 20),
                  label: Text(
                    _isOrdering ? '' : 'Order Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        ...items.map(
          (item) => Padding(
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
          ),
        ),
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
      final response = await _medicineService.searchMedicine(
        medicineName: searchQuery,
      );

      if (response['status'] == 'success' &&
          response['medicine_info'] != null) {
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

  Future<void> _handleAddToCart(Map<String, dynamic> medicineInfo) async {
    await CartService.addToCart(medicineInfo);
    await _loadCartCount();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${medicineInfo['corrected_name']} added to cart',
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
              _loadCartCount();
            },
          ),
        ),
      );
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
            content: Text(
              response['message'] ?? 'Medicine ordered successfully',
            ),
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
    try {
      await FlutterPhoneDirectCaller.callNumber(phone_no);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
