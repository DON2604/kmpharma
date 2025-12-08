import 'package:flutter/material.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/widgets/LoadingDots.dart';

class LocationDisplay extends StatelessWidget {
  final String currentAddress;
  final bool isLoadingLocation;
  final AnimationController dotController;

  const LocationDisplay({
    super.key,
    required this.currentAddress,
    required this.isLoadingLocation,
    required this.dotController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "YOUR CURRENT LOCATION",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: isLoadingLocation
                    ? LoadingDots(dotController: dotController)
                    : Text(
                        currentAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
