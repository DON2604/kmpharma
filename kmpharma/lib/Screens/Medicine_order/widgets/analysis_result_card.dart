import 'package:flutter/material.dart';

class AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const AnalysisResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Handle both upload response and analysis response formats
    final fileUrl = result['file_url'] as String?;
    final message = result['message'] as String?;
    final doctor = result['doctor'] as Map<String, dynamic>?;
    final medicines = result['recommended_medicines'] as List? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show upload success UI if file_url is present
          if (fileUrl != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Prescription Uploaded",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            // Show analysis result UI (original format)
            const Text(
              "Analysis Result",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (doctor != null) ...[
              _buildInfoRow("Doctor", doctor['name'] ?? 'N/A'),
              _buildInfoRow("Specialization", doctor['specialization'] ?? 'N/A'),
            ],
            if (result['diagnosis'] != null)
              _buildInfoRow("Diagnosis", result['diagnosis']),
            const SizedBox(height: 8),
            const Text(
              "Recommended Medicines:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...medicines.map((medicine) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.medication, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          medicine.toString(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
