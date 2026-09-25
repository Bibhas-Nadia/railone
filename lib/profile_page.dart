import 'package:flutter/material.dart';
import 'database_helper.dart'; // Make sure this path is correct

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userPhone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await DatabaseHelper().getUserProfile();
    if (mounted) {
      setState(() {
        if (profile != null) {
          _userName = profile['name'] ?? '';
          _userPhone = profile['phone'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  void _showCompleteProfileSheet() {
    final nameController = TextEditingController(text: _userName);
    final phoneController = TextEditingController(text: _userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to move up with keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF143059),
                  ),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                      await DatabaseHelper().saveUserProfile(
                        nameController.text.trim(),
                        phoneController.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(context); // Close bottom sheet
                        _loadProfileData(); // Refresh UI
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  child: const Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF143059),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Icon Avatar
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: _userName.isEmpty ? Colors.grey.shade300 : const Color(0xFF143059).withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: _userName.isEmpty ? Colors.grey : const Color(0xFF143059),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Condition: Profile is complete or not
                    if (_userName.isEmpty) ...[
                      const Text(
                        'Profile Incomplete',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please complete your profile to enable a seamless booking experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF143059),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _showCompleteProfileSheet,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Complete Your Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ] else ...[
                      // Display Profile
                      Text(
                        _userName,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            _userPhone,
                            style: const TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      TextButton.icon(
                        onPressed: _showCompleteProfileSheet,
                        icon: const Icon(Icons.edit, color: const Color(0xFF143059)),
                        label: const Text('Edit Profile', style: TextStyle(fontSize: 16, color: const Color(0xFF143059))),
                      )
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
