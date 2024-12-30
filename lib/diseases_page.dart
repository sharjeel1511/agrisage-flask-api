import 'package:flutter/material.dart';

class DiseasesPage extends StatelessWidget {
  const DiseasesPage({Key? key}) : super(key: key);

  Widget _buildDiseaseCard(String title, String description, String symptoms) {
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
                  'Description:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 16),
                const Text(
                  'Common Symptoms:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(symptoms),
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
        title: const Text('Plant Diseases'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDiseaseCard(
              'Leaf Blight',
              'A fungal disease that affects various plants, causing leaf tissue death.',
              '• Brown or black spots on leaves\n• Yellowing around spots\n• Wilting leaves\n• Premature leaf drop',
            ),
            _buildDiseaseCard(
              'Powdery Mildew',
              'A common fungal disease that appears as a white powdery coating on leaves.',
              '• White powdery spots on leaves\n• Yellowing leaves\n• Distorted growth\n• Reduced plant vigor',
            ),
            _buildDiseaseCard(
              'Root Rot',
              'A disease caused by various fungi that attack plant roots in wet conditions.',
              '• Wilting despite moist soil\n• Yellowing leaves\n• Stunted growth\n• Rotting roots',
            ),
          ],
        ),
      ),
    );
  }
}
