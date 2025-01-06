import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/scan_history_model.dart';
import 'package:intl/intl.dart';
import 'result_page.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String title,
    required String date,
    required String diagnosis,
    required String confidence,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Create properly formatted prediction map
              final Map<String, dynamic> predictionData = {
                'disease': diagnosis,
                'confidence':
                    double.parse(confidence.replaceAll('%', '')) / 100,
                'recommendations': _getRecommendations(diagnosis),
                'confidence_scores': {
                  'Blight': diagnosis == 'Blight'
                      ? double.parse(confidence.replaceAll('%', '')) / 100
                      : 0.0,
                  'Common Rust': diagnosis == 'Common Rust'
                      ? double.parse(confidence.replaceAll('%', '')) / 100
                      : 0.0,
                  'Gray Leaf Spot': diagnosis == 'Gray Leaf Spot'
                      ? double.parse(confidence.replaceAll('%', '')) / 100
                      : 0.0,
                  'Healthy': diagnosis == 'Healthy'
                      ? double.parse(confidence.replaceAll('%', '')) / 100
                      : 0.0,
                },
                'status': 'confident' // Add status for consistent display
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultPage(
                    imagePath: imageUrl ?? '',
                    prediction: predictionData,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF0F2F5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null
                          ? kIsWeb
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.image,
                                    color: Color(0xFF2ECC71),
                                    size: 30,
                                  ),
                                )
                              : Image.file(
                                  File(imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.image,
                                    color: Color(0xFF2ECC71),
                                    size: 30,
                                  ),
                                )
                          : const Icon(
                              Icons.image,
                              color: Color(0xFF2ECC71),
                              size: 30,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            diagnosis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF2ECC71),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: $confidence',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this helper method to get recommendations
  List<String> _getRecommendations(String diagnosis) {
    switch (diagnosis) {
      case 'Blight':
        return [
          'Remove and destroy infected leaves',
          'Apply appropriate fungicide',
          'Ensure good air circulation'
        ];
      case 'Common Rust':
        return [
          'Apply fungicide early in the season',
          'Plant resistant varieties',
          'Monitor humidity levels'
        ];
      case 'Gray Leaf Spot':
        return [
          'Rotate crops annually',
          'Remove crop debris',
          'Consider fungicide application'
        ];
      case 'Healthy':
        return [
          'Continue regular maintenance',
          'Monitor for early signs of disease',
          'Maintain proper irrigation'
        ];
      default:
        return ['Consult a local agricultural expert'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Scan History',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF2C3E50),
            ),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Color(0xFF2C3E50),
            ),
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('scans')
            .orderBy('scanDate', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          print('Current user ID: ${FirebaseAuth.instance.currentUser?.uid}');
          print('Snapshot data: ${snapshot.data?.docs.length} items');

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history yet',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your plant scan results will appear here',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final scan = ScanHistory.fromMap(
                doc.data() as Map<String, dynamic>,
              );

              return _buildHistoryItem(
                context,
                title: scan.title,
                date: _formatDate(scan.scanDate),
                diagnosis: scan.diagnosis,
                confidence: scan.confidence,
                imageUrl: scan.imagePath,
              );
            },
          );
        },
      ),
    );
  }
}
