import 'package:flutter/material.dart';
import 'package:kmpharma/Screens/DoctorAppointment/widgets/category_filter_widget.dart';
import 'package:kmpharma/Screens/DoctorAppointment/widgets/doctor_card_widget.dart';
import 'package:kmpharma/Screens/DoctorAppointment/widgets/booking_bottom_sheet_widget.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  int selectedCategory = 0;
  int? selectedDoctorIndex;
  String? selectedTimeSlot;
  final List<String> categories = ["All", "Dentist", "General", "Dermatologist"];

  final List<String> timeSlots = [
    "Today, 2:30 PM",
    "Today, 3:00 PM",
    "Today, 4:00 PM",
    "Tomorrow, 10:00 AM",
    "Tomorrow, 11:00 AM",
    "Tomorrow, 2:00 PM",
    "Dec 20, 9:00 AM",
    "Dec 20, 10:30 AM",
    "Dec 21, 3:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Find your doctor",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.notifications_outlined, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 20),
                CategoryFilterWidget(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onCategorySelected: (index) {
                    setState(() => selectedCategory = index);
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "Available Doctors",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                DoctorCardWidget(
                  index: 0,
                  imageUrl: "https://i.pravatar.cc/150?img=47",
                  name: "Dr. Evelyn Reed",
                  title: "Cardiologist",
                  rating: "4.9 (124 reviews)",
                  availability: "Next available: Today, 2:30 PM",
                  price: "\$150",
                  isSelected: selectedDoctorIndex == 0,
                  onTap: (index) {
                    setState(() {
                      selectedDoctorIndex = selectedDoctorIndex == index ? null : index;
                    });
                  },
                ),
                DoctorCardWidget(
                  index: 1,
                  imageUrl: "https://i.pravatar.cc/150?img=12",
                  name: "Dr. Marcus Chen",
                  title: "Dermatologist",
                  rating: "4.8 (98 reviews)",
                  availability: "Next available: Tomorrow, 10:00 AM",
                  price: "\$120",
                  isSelected: selectedDoctorIndex == 1,
                  onTap: (index) {
                    setState(() {
                      selectedDoctorIndex = selectedDoctorIndex == index ? null : index;
                    });
                  },
                ),
                DoctorCardWidget(
                  index: 2,
                  imageUrl: "https://i.pravatar.cc/150?img=5",
                  name: "Dr. Anya Sharma",
                  title: "General Physician",
                  rating: "5.0 (210 reviews)",
                  availability: "Available Today",
                  price: "\$95",
                  isSelected: selectedDoctorIndex == 2,
                  onTap: (index) {
                    setState(() {
                      selectedDoctorIndex = selectedDoctorIndex == index ? null : index;
                    });
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
            if (selectedDoctorIndex != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BookingBottomSheetWidget(
                  timeSlots: timeSlots,
                  selectedTimeSlot: selectedTimeSlot,
                  onTimeSlotChanged: (value) {
                    setState(() => selectedTimeSlot = value);
                  },
                  onBookPressed: () {
                    // Handle booking
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
