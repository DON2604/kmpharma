import 'package:flutter/material.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/ambulance_book_service.dart';

class AmbulanceHistoryScreen extends StatefulWidget {
  const AmbulanceHistoryScreen({super.key});

  @override
  State<AmbulanceHistoryScreen> createState() => _AmbulanceHistoryScreenState();
}

class _AmbulanceHistoryScreenState extends State<AmbulanceHistoryScreen> {
  late Future<List<Map<String, dynamic>>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = _fetchBookings();
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      final phoneNumber = await AmbulanceBookService.getPhoneNumber();
      final sessionId = await AmbulanceBookService.getSessionId();

      if (phoneNumber == null || sessionId == null) {
        throw Exception("Phone number or session ID not found");
      }

      return await AmbulanceBookService.getBookings(
        phoneNumber: phoneNumber,
        sessionId: sessionId,
      );
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
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
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Ambulance Booking History",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "No bookings found",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No bookings found",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                final bookings = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Booking #${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              "From:",
                              booking['current_location'] ?? 'N/A',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              "To:",
                              booking['destination'] ?? 'N/A',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              "Status:",
                              booking['status'] == true ? 'Completed' : 'Pending',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
