import 'package:flutter/material.dart';

class BookLabTestScreen extends StatefulWidget {
  const BookLabTestScreen({super.key});

  @override
  State<BookLabTestScreen> createState() => _BookLabTestScreenState();
}

class _BookLabTestScreenState extends State<BookLabTestScreen> {
  int cartCount = 3; // demo value

  final List<_LabTest> tests = [
    _LabTest(
      title: "Comprehensive Full Body Checkup",
      description: "Includes 85 parameters. 12-hour fasting required.",
      price: 120.00,
      asset: 'assets/images/heart.png',
    ),
    _LabTest(
      title: "Vitamin D & B12 Profile",
      description: "Measures key vitamin levels. No fasting required.",
      price: 45.00,
      asset: 'assets/images/vitamins.png',
    ),
    _LabTest(
      title: "Advanced Thyroid Test",
      description: "Includes T3, T4, TSH. Consult doctor for fasting advice.",
      price: 70.00,
      asset: 'assets/images/thyroid.png',
    ),
  ];

  int selectedFilter = 0; // 0: Popular, 1: Full Body, 2: Diabetes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          "Book a Lab Test",
          style: TextStyle(
            color: Colors.black87,
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
            _buildUploadCard(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterRow(),
            const SizedBox(height: 16),
            ...tests.map(_buildTestCard).toList(),
            const SizedBox(height: 80), // space above bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ------------------ UI PARTS ------------------

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Have a Prescription?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Upload it and we'll add the tests for you.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1f7cff),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Upload Now",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 46,
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search for tests or packages",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final chips = ["Popular", "Full Body Checkup", "Diabetes"];

    return Row(
      children: List.generate(chips.length, (index) {
        final selected = index == selectedFilter;
        return Padding(
          padding: EdgeInsets.only(right: index == chips.length - 1 ? 0 : 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = index;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xff1f7cff) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? const Color(0xff1f7cff) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                chips[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xff1f7cff),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTestCard(_LabTest test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Text side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  test.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "\$${test.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Image + Add button column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTestImage(test.asset),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (!test.added) {
                      cartCount++;
                      test.added = true;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: test.added ? Colors.grey.shade400 : const Color(0xff22c55e),
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  test.added ? "Added" : "Add",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestImage(String asset) {
    // Replace with your own asset images.
    // Make sure they are declared in pubspec.yaml.
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xfffff3f3),
        image: DecorationImage(
          image: AssetImage(asset),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 4,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xffeff2ff),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$cartCount Items",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1f7cff),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Proceed to Book",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ MODEL ------------------

class _LabTest {
  final String title;
  final String description;
  final double price;
  final String asset;
  bool added;

  _LabTest({
    required this.title,
    required this.description,
    required this.price,
    required this.asset,
    this.added = false,
  });
}
