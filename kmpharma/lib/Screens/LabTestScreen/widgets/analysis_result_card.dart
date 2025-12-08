import 'package:flutter/material.dart';

class AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const AnalysisResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final doctor = result['doctor'] as Map<String, dynamic>?;
    final testsFound = result['tests_found'] as bool? ?? false;
    final recommendedTests = result['recommended_tests'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                testsFound ? Icons.check_circle : Icons.info,
                color: testsFound ? Colors.greenAccent : Colors.orangeAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result['message'] ?? 'Analysis Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (doctor != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.person, label: 'Doctor', value: doctor['name'] ?? 'N/A'),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.medical_services,
              label: 'Specialization',
              value: doctor['specialization'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.badge,
              label: 'Registration',
              value: doctor['registration_number'] ?? 'N/A',
            ),
          ],
          if (result['diagnosis'] != null &&
              result['diagnosis'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.healing,
              label: 'Diagnosis',
              value: result['diagnosis'].toString(),
            ),
          ],
          if (testsFound && recommendedTests.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'Recommended Tests:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendedTests.map((test) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          test.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
