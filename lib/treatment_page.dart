import 'package:flutter/material.dart';

class TreatmentPage extends StatelessWidget {
  const TreatmentPage({Key? key}) : super(key: key);

  Widget _buildTreatmentCard(String title, String method, String precautions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Treatment Method:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(method),
                const SizedBox(height: 16),
                const Text(
                  'Precautions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(precautions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Treatment Guide'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTreatmentCard(
              'Organic Pesticides',
              'Natural solutions made from neem oil, garlic, or soap spray.',
              '• Wear protective gear\n• Apply in early morning or evening\n• Keep away from beneficial insects',
            ),
            _buildTreatmentCard(
              'Pruning Method',
              'Remove affected parts to prevent disease spread.',
              '• Use clean, sharp tools\n• Cut at 45-degree angle\n• Dispose infected parts properly',
            ),
            _buildTreatmentCard(
              'Soil Treatment',
              'Improve soil health using organic amendments.',
              '• Test soil before treatment\n• Apply correct dosage\n• Maintain proper moisture',
            ),
          ],
        ),
      ),
    );
  }
}
