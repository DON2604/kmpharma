import 'package:flutter/material.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/Ambulance_Screen.dart';
import 'package:kmpharma/Screens/DoctorAppointment/DoctorsScreen.dart';
import 'package:kmpharma/Screens/Emergency_call/EmergencyScreen.dart';
import 'package:kmpharma/Screens/LabTestScreen/LabTestScreen.dart';
//import 'package:kmpharma/Screens/MedicineInfoScreen/MedicineInfoScreen.dart';
import 'package:kmpharma/Screens/Medicine_order/MedicineOrderScreen.dart';
//import 'package:kmpharma/Screens/PregCare/PregCareScreen.dart';
import 'package:kmpharma/Screens/ReminderScreen/ReminderScreen.dart';
import 'package:kmpharma/services/logout_service.dart';
import 'package:marquee/marquee.dart';
import 'package:kmpharma/Screens/ServicesScreen/widgets/HorizontalCard.dart';
import 'package:kmpharma/Screens/ServicesScreen/widgets/QuickAccessItem.dart';
import 'package:kmpharma/Screens/ServicesScreen/widgets/ServiceTile.dart';
import 'package:kmpharma/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ServicesScreen extends StatefulWidget {
  final String? phoneNumber;

  const ServicesScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
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
                      backgroundImage: AssetImage("assets/avatar.jpg"),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Good Evening 👋",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.phoneNumber ?? "User",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 24, color: Colors.white),
                      onPressed: () {
                        LogoutService.logout(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ----------- SEARCH BAR -----------
                // Container(
                //   height: 50,
                //   decoration: BoxDecoration(
                //     color: Colors.white10,
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(color: Colors.white24),
                //   ),
                //   child: Marquee(
                //     text:
                //         "✨ 24/7 Available Services with voice • Online Doctor Consultations • Medicine Delivery • Lab Tests • Health Tips • Emergency Support ✨",
                //     style: const TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.white,
                //     ),
                //     scrollAxis: Axis.horizontal,
                //     blankSpace: 60.0,
                //     velocity: 35.0,
                //     pauseAfterRound: Duration(seconds: 0),
                //     startPadding: 10.0,
                //     accelerationDuration: Duration(seconds: 1),
                //     accelerationCurve: Curves.linear,
                //     decelerationDuration: Duration(milliseconds: 500),
                //     decelerationCurve: Curves.easeOut,
                //   ),
                // ),

                const SizedBox(height: 20),
                const Text(
                      "Top Offers",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),),
                const SizedBox(height: 10),

                // ----------- ADVERTISEMENT CAROUSEL -----------
                Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 160,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                      items: [
                        _buildAdBanner(
                          "Special Discount 50% OFF",
                          "On all medicines this week",
                          Colors.purple,
                          Icons.local_offer,
                        ),
                        _buildAdBanner(
                          "Free Home Delivery",
                          "Order above ₹500",
                          Colors.teal,
                          Icons.delivery_dining,
                        ),
                        _buildAdBanner(
                          "Health Checkup Package",
                          "Starting from ₹999",
                          Colors.orange,
                          Icons.health_and_safety,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ----------- QUICK ACCESS -----------
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Access",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
                                builder: (context) => Emergencyscreen(
                                  phoneNumber: widget.phoneNumber,
                                ),
                              ),
                            );
                          },
                          child: quickAccessItem(
                            bgColor: const Color(0xFFC62828),
                            iconBg: const Color(0xFFFFCDD2),
                            icon: Icons.call,
                            title: "Emergency Call",
                            sub: "Immediate help",
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AmbulanceScreen(),
                              ),
                            );
                          },
                          child: quickAccessItem(
                            bgColor: const Color(0xFF1565C0),
                            iconBg: const Color(0xFFBBDEFB),
                            icon: Icons.local_hospital_outlined,
                            title: "Ambulance",
                            sub: "Request now",
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorsScreen(),
                              ),
                            );
                          },
                          child: quickAccessItem(
                            bgColor: const Color.fromARGB(255, 213, 158, 4),
                            iconBg: Colors.yellowAccent,
                            icon: Icons.calendar_month,
                            title: "Book Appointment",
                            sub: "Find a doctor",
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineOrderScreen(),
                              ),
                            );
                          },
                          child: quickAccessItem(
                            bgColor: const Color.fromARGB(255, 101, 164, 7),
                            iconBg: Colors.greenAccent,
                            icon: Icons.medication,
                            title: "Order Medicine",
                            sub: "Upload prescription",
                          ),
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
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookLabTestScreen(),
                              ),
                            );
                          },
                          child: serviceTile(
                            Icons.biotech_rounded,
                            "Lab Tests",
                          ),
                        ),
                        // InkWell(onTap: () {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => MedicineInfoScreen(),
                        //       ),
                        //     );
                        // }, child: serviceTile(Icons.info_outline, "Medicine Info")),
                        InkWell(onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RemindersScreen(),
                              ),
                            );
                        }, child: serviceTile(Icons.alarm, "Reminders")),
                        // InkWell(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => PregnancyCareScreen(),
                        //       ),
                        //     );
                        //   },
                        //   child: serviceTile(Icons.pregnant_woman, "Pregnancy Care")),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdBanner(String title, String subtitle, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 120,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
