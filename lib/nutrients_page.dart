import 'package:flutter/material.dart';

class NutrientsPage extends StatelessWidget {
  const NutrientsPage({Key? key}) : super(key: key);

  Widget _buildNutrientCard(
      String title, String role, String deficiencySymptoms) {
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
                  'Role in Plant Growth:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(role),
                const SizedBox(height: 16),
                const Text(
                  'Deficiency Symptoms:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(deficiencySymptoms),
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
        title: const Text('Plant Nutrients'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNutrientCard(
              'Nitrogen (N)',
              'Essential for leaf growth and chlorophyll production.',
              '• Yellowing of older leaves\n• Stunted growth\n• Poor leaf development',
            ),
            _buildNutrientCard(
              'Phosphorus (P)',
              'Important for root development and flowering.',
              '• Purple or reddish color in leaves\n• Poor root growth\n• Delayed maturity',
            ),
            _buildNutrientCard(
              'Potassium (K)',
              'Helps in overall plant health and disease resistance.',
              '• Yellowing leaf edges\n• Weak stems\n• Poor fruit development',
            ),
          ],
        ),
      ),
    );
  }
}
