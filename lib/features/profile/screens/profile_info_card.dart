import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String username;
  final String phoneNumber;
  
  const ProfileInfoCard({
    super.key,
    required this.username,
    required this.phoneNumber,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle, color: const Color(0xFF2563EB)),
            title: const Text('Username'),
            subtitle: Text(username),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone, color: const Color(0xFF2563EB)),
            title: const Text('Nomor Telepon'),
            subtitle: Text(phoneNumber.isNotEmpty ? phoneNumber : 'Tidak ada'),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: const Color(0xFF2563EB)),
              onPressed: () {
              },
            ),
          ),
        ],
      ),
    );
  }
}