class ScanHistory {
  final String id;
  final String title;
  final DateTime scanDate;
  final String diagnosis;
  final String confidence;
  final String imagePath;

  ScanHistory({
    required this.id,
    required this.title,
    required this.scanDate,
    required this.diagnosis,
    required this.confidence,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'scanDate': scanDate.toIso8601String(),
      'diagnosis': diagnosis,
      'confidence': confidence,
      'imagePath': imagePath,
    };
  }

  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Maize Scan',
      scanDate: map['scanDate'] != null
          ? DateTime.parse(map['scanDate'])
          : DateTime.now(),
      diagnosis: map['diagnosis'] ?? 'Unknown',
      confidence: map['confidence'] ?? '0%',
      imagePath: map['imagePath'] ?? '',
    );
  }
}
