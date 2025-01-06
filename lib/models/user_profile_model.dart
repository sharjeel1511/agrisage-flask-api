class UserProfile {
  final String uid;
  final String name;
  final String? photoUrl;
  final String email;

  UserProfile({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'email': email,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      email: map['email'] ?? '',
    );
  }
}
