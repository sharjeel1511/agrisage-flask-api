import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResultPage extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> prediction;

  const ResultPage({
    Key? key,
    required this.imagePath,
    required this.prediction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUncertain = prediction['status'] == 'uncertain';
    final confidenceScores =
        prediction['confidence_scores'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: kIsWeb
                    ? NetworkImage(imagePath)
                    : FileImage(File(imagePath)) as ImageProvider,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUncertain) ...[
                      const Text(
                        'Uncertain Prediction',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prediction['message'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Diagnosis: ${prediction['disease']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${(prediction['confidence'] * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Confidence Scores:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...confidenceScores.entries.map((entry) {
                      final confidence = entry.value * 100;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(entry.key),
                            ),
                            Expanded(
                              flex: 7,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: confidence / 100,
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2ECC71)
                                            .withOpacity(confidence / 100),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${confidence.toStringAsFixed(1)}%'),
                          ],
                        ),
                      );
                    }),
                    if (prediction['recommendations'] != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        (prediction['recommendations'] as List).length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF2ECC71)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prediction['recommendations'][index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
