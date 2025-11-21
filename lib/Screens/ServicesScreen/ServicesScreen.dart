import 'package:flutter/material.dart';
import 'package:kmpharma/Screens/Emergency_call/EmergencyScreen.dart';
import 'package:marquee/marquee.dart';
import 'package:kmpharma/Screens/ServicesScreen/widgets/HorizontalCard.dart';
import 'package:kmpharma/Screens/ServicesScreen/widgets/QuickAccessItem.dart';
import 'package:kmpharma/Screens/ServicesScreen/widgets/ServiceTile.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------- HEADER -----------
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage("assets/user.png"),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Good Evening 👋",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "Mrinmay",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined, size: 28),
                ],
              ),

              const SizedBox(height: 20),

              // ----------- SEARCH BAR -----------
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Marquee(
                  text:
                      "✨ 24/7 Available Services with voice • Online Doctor Consultations • Medicine Delivery • Lab Tests • Health Tips • Emergency Support ✨",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 60.0,
                  velocity: 35.0,
                  pauseAfterRound: Duration(seconds: 0),
                  startPadding: 10.0,
                  accelerationDuration: Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),

              const SizedBox(height: 20),

              // ----------- TOP HORIZONTAL CARDS -----------
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    horizontalCard(
                      title: "Save on Insurance",
                      subtitle: "Explore best plans for your needs",
                      color: const Color(0xffd0e3ff),
                      buttonText: "Learn More",
                    ),
                    horizontalCard(
                      title: "Stay Healthy",
                      subtitle: "Tips to keep you fit",
                      color: const Color(0xffd0ffe3),
                      buttonText: "Get Tips",
                    ),
                    horizontalCard(
                      title: "Daily Health Check",
                      subtitle: "Track your wellness",
                      color: const Color(0xffffe7d1),
                      buttonText: "Track",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ----------- QUICK ACCESS -----------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Access",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.3,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Emergencyscreen(),
                            ),
                          );
                        },
                        child: quickAccessItem(
                          bgColor: const Color(0xfffdecef),
                          iconBg: const Color(0xffffc8d1),
                          icon: Icons.call,
                          title: "Emergency Call",
                          sub: "Immediate help",
                        ),
                      ),
                      quickAccessItem(
                        bgColor: const Color(0xffeaf2ff),
                        iconBg: const Color(0xffcddcff),
                        icon: Icons.local_hospital_outlined,
                        title: "Ambulance",
                        sub: "Request now",
                      ),
                      quickAccessItem(
                        bgColor: Colors.white,
                        iconBg: const Color(0xffe0ecff),
                        icon: Icons.calendar_month,
                        title: "Book Appointment",
                        sub: "Find a doctor",
                      ),
                      quickAccessItem(
                        bgColor: Colors.white,
                        iconBg: const Color(0xffe4f1ff),
                        icon: Icons.medication,
                        title: "Order Medicine",
                        sub: "Upload prescription",
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ----------- OUR SERVICES -----------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    "Our Services",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      serviceTile(Icons.biotech_rounded, "Lab Tests"),
                      serviceTile(Icons.info_outline, "Medicine Info"),
                      serviceTile(Icons.alarm, "Reminders"),
                      serviceTile(Icons.pregnant_woman, "Pregnancy Care"),
                      serviceTile(Icons.child_care, "Newborn Care"),
                      serviceTile(Icons.smart_toy, "AI help"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
