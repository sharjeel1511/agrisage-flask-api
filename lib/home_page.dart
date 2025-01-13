import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'result_page.dart';
import 'diseases_page.dart';
import 'nutrients_page.dart';
import 'treatment_page.dart';
import 'guide_page.dart';
import 'chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/scan_history_model.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Color> categoryColors = [
    const Color(0xFFE8F5E9).withOpacity(0.9), // Soft Green
    const Color(0xFFE3F2FD).withOpacity(0.9), // Soft Blue
    const Color(0xFFFCE4EC).withOpacity(0.9), // Soft Pink
    const Color(0xFFFFF3E0).withOpacity(0.9), // Soft Orange
  ];

  final List<Color> glowColors = [
    const Color(0xFF43A047), // Vibrant Green
    const Color(0xFF1E88E5), // Vibrant Blue
    const Color(0xFFE91E63), // Vibrant Pink
    const Color(0xFFFF9800), // Vibrant Orange
  ];

  final Color myColor = const Color(0xFF2C3E50);

  final List<Map<String, String>> carouselItems = [
    {
      'image': 'assets/images/maize1.jpg',
      'text': 'Healthy Maize Growth Tips',
    },
    {
      'image': 'assets/images/maize2.jpg',
      'text': 'Disease Prevention Guide',
    },
    {
      'image': 'assets/images/maize3.jpg',
      'text': 'Optimal Nutrition Guide',
    },
    {
      'image': 'assets/images/maize4.jpg',
      'text': 'Best Farming Practices',
    },
    {
      'image': 'assets/images/maize5.jpg',
      'text': 'Yield Improvement Tips',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Show a more informative loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Processing Image...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while our server initializes',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        );

        try {
          // First, check if server is responsive
          bool serverReady = false;
          int retryCount = 0;
          const maxRetries = 3;

          while (!serverReady && retryCount < maxRetries) {
            try {
              final response = await http.get(
                Uri.parse('https://agrisage-flask-api.onrender.com/predict'),
              );
              if (response.statusCode == 405) {
                // Method not allowed means server is up
                serverReady = true;
              }
            } catch (e) {
              retryCount++;
              if (retryCount < maxRetries) {
                await Future.delayed(const Duration(seconds: 5));
              }
            }
          }

          if (!serverReady) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Server is still initializing. Please try again in a moment.'),
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }

          // Proceed with image upload
          var uri =
              Uri.parse('https://agrisage-flask-api.onrender.com/predict');
          var request = http.MultipartRequest('POST', uri);

          // Add CORS headers for web
          request.headers.addAll({
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
          });

          if (kIsWeb) {
            final bytes = await pickedFile.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'image',
                bytes,
                filename: 'image.jpg',
              ),
            );
          } else {
            request.files.add(
              await http.MultipartFile.fromPath('image', pickedFile.path),
            );
          }

          var response = await request.send();
          var responseData = await response.stream.bytesToString();
          print('Response: $responseData');

          Navigator.pop(context); // Close loading dialog
          if (!mounted) return;

          final result = json.decode(responseData);

          String displayPath;
          if (kIsWeb) {
            final bytes = await pickedFile.readAsBytes();
            displayPath = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          } else {
            displayPath = pickedFile.path;
          }

          if (response.statusCode == 400) {
            // Show error or uncertain prediction dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  result['error'] != null ? 'Error' : 'Uncertain Prediction',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result['error'] != null
                          ? Icons.error_outline
                          : Icons.warning_amber,
                      color:
                          result['error'] != null ? Colors.red : Colors.orange,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result['error'] ?? result['message'],
                      style: GoogleFonts.inter(color: const Color(0xFF2C3E50)),
                      textAlign: TextAlign.center,
                    ),
                    if (result['confidence_scores'] != null) ...[
                      const SizedBox(height: 16),
                      ...result['confidence_scores'].entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                  '${(entry.value * 100).toStringAsFixed(1)}%'),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF2ECC71),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
            return;
          }

          // Navigate to result page for both uncertain and confident predictions
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultPage(
                imagePath: displayPath,
                prediction: result,
              ),
            ),
          );

          if (result != null) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                final scanHistory = ScanHistory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'Maize Scan',
                  scanDate: DateTime.now(),
                  diagnosis: result['disease'] ?? 'Unknown',
                  confidence:
                      '${(result['confidence'] * 100).toStringAsFixed(1)}%',
                  imagePath: displayPath,
                );

                // Get reference to scans collection
                final scansRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('scans');

                // Get current scans count
                final scansSnapshot =
                    await scansRef.orderBy('scanDate', descending: true).get();

                // If more than 9 scans exist, delete the oldest ones
                if (scansSnapshot.docs.length >= 9) {
                  final toDelete = scansSnapshot.docs
                      .sublist(8); // Keep newest 9, making room for new scan
                  for (var doc in toDelete) {
                    await doc.reference.delete();
                  }
                }

                // Add new scan
                await scansRef.doc(scanHistory.id).set(scanHistory.toMap());
                print('Scan saved successfully');
              } catch (e) {
                print('Error saving scan history: $e');
              }
            }
          }
        } catch (e) {
          print('Error processing image: $e');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().contains('XMLHttpRequest')
                  ? 'Server is warming up. Please try again in a moment.'
                  : 'Error: $e'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildCategoryCard(String title, IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColors[index],
            categoryColors[index].withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColors[index].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiseasesPage()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NutrientsPage()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TreatmentPage()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuidePage()),
                );
                break;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColors[index].withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: glowColors[index],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: glowColors[index],
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanPlantContainer() {
    print("Building Scan Plant Container");
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Scan Plant',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Take or select a photo to analyze',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: () => _pickImage(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF2ECC71)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousScanItem(String title, String time, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF0F2F5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://via.placeholder.com/60',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image,
                    color: Color(0xFF2ECC71),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Maize Care Guide',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        FlutterCarousel(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 0.85,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
          items: carouselItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item['image']!,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            child: Text(
                              item['text']!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Agri',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2ECC71),
                              ),
                            ),
                            TextSpan(
                              text: 'Sage',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildScanPlantContainer(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactCategory(
                        'Diseases',
                        Icons.coronavirus_outlined,
                        0,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DiseasesPage())),
                      ),
                      _buildCompactCategory(
                        'Nutrients',
                        Icons.water_drop_outlined,
                        1,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NutrientsPage())),
                      ),
                      _buildCompactCategory(
                        'Treatment',
                        Icons.healing_outlined,
                        2,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TreatmentPage())),
                      ),
                      _buildCompactCategory(
                        'Guide',
                        Icons.menu_book_outlined,
                        3,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GuidePage())),
                      ),
                    ],
                  ),
                ),
                _buildImageCarousel(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const ChatBubble(),
    );
  }

  Widget _buildCompactCategory(
      String title, IconData icon, int index, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColors[index],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: glowColors[index].withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: glowColors[index],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}
