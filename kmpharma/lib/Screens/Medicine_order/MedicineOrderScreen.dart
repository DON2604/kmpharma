import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kmpharma/constants.dart';

class MedicineOrderScreen extends StatefulWidget {
  const MedicineOrderScreen({super.key});

  @override
  State<MedicineOrderScreen> createState() => _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends State<MedicineOrderScreen> {
  PlatformFile? _pickedFile;

  Future<void> pickPrescription() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.single;
      });

      // TODO: Upload to server
      // final file = result.files.single;
      // send to backend
    }
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

                  // UPLOAD PRESCRIPTION CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left section text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Have a Prescription?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Upload a photo of your prescription to order.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ElevatedButton(
                                onPressed: pickPrescription,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  "Upload Now",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Icon Box
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.upload_file,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_pickedFile != null) ...[
                    const SizedBox(height: 16),
                    _buildFilePreview(),
                  ],

                  const SizedBox(height: 25),

                  const Text(
                    "Reorder Your Essentials",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // MEDICINE HORIZONTAL SCROLLER
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        medicineCard(
                          "Paracetamol",
                          "500mg, Tablet",
                          "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNpbmV8ZW58MHx8MHx8fDA%3D",
                        ),
                        medicineCard(
                          "Ibuprofen",
                          "200mg, Capsule",
                          "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNpbmV8ZW58MHx8MHx8fDA%3D",
                        ),
                        medicineCard(
                          "Cough Syrup",
                          "100ml Bottle",
                          "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNpbmV8ZW58MHx8MHx8fDA%3D",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
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
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final file = _pickedFile!;
    final extension = file.extension?.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(extension);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: isImage && file.path != null
                ? Image.file(
                    File(file.path!),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: Colors.redAccent.withOpacity(0.2),
                    child: const Icon(Icons.picture_as_pdf,
                        color: Colors.redAccent),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  "${(file.size / 1024).toStringAsFixed(1)} KB",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: () {
              setState(() {
                _pickedFile = null;
              });
            },
          ),
        ],
      ),
    );
  }

  // Medicine Card Widget
  Widget medicineCard(String name, String desc, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(child: Center(child: Image.network(imageUrl, height: 80))),
          const SizedBox(height: 10),

          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),

          Text(desc, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Reorder", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
