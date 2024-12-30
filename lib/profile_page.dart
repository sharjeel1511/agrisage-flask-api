import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2ECC71), size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2ECC71)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF2ECC71),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'john.doe@example.com',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Scans', '23', Icons.document_scanner),
                        _buildStatCard('Diseases', '15', Icons.bug_report),
                        _buildStatCard('Saved', '7', Icons.bookmark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              Icons.person_outline,
              'Edit Profile',
              'Update your personal information',
              () {},
            ),
            _buildProfileOption(
              Icons.notifications_outlined,
              'Notifications',
              'Manage your notification preferences',
              () {},
            ),
            _buildProfileOption(
              Icons.security_outlined,
              'Privacy & Security',
              'Control your privacy settings',
              () {},
            ),
            _buildProfileOption(
              Icons.help_outline,
              'Help & Support',
              'Get help and contact support',
              () {},
            ),
            _buildProfileOption(
              Icons.info_outline,
              'About',
              'Learn more about AgriSage',
              () {},
            ),
            _buildProfileOption(
              Icons.logout,
              'Logout',
              'Sign out of your account',
              () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
