import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResultPage extends StatefulWidget {
  final String imagePath;

  const ResultPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isLoading = true;
  Map<String, double>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _results = {
          'Healthy': 0.85,
          'Diseased': 0.15,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb
                  ? Image.network(
                      widget.imagePath,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2ECC71),
                ),
              )
            else if (_error != null)
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
            else if (_results != null) ...[
              const Text(
                'Analysis Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._results!.entries.map((pred) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                        children: [
                          Expanded(
                            child: Text(
                              pred.key,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(pred.value * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: pred.value > 0.5
                                  ? const Color(0xFF2ECC71)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
