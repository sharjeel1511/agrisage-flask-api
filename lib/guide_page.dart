import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({Key? key}) : super(key: key);

  Widget _buildGuideCard(String title, String tips, String bestPractices) {
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
                  'Key Tips:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(tips),
                const SizedBox(height: 16),
                const Text(
                  'Best Practices:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(bestPractices),
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
        title: const Text('Planting Guide'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGuideCard(
              'Watering Guide',
              'Learn proper watering techniques for healthy plants.',
              '• Water deeply but less frequently\n• Water at the base\n• Best times: Early morning or evening',
            ),
            _buildGuideCard(
              'Soil Preparation',
              'Prepare soil properly for optimal plant growth.',
              '• Test soil pH\n• Add organic matter\n• Ensure good drainage',
            ),
            _buildGuideCard(
              'Plant Care',
              'Essential care tips for plant maintenance.',
              '• Regular pruning\n• Proper spacing\n• Mulching techniques',
            ),
          ],
        ),
      ),
    );
  }
}
