import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final role = Storage.getUserRole() ?? 'Kasir';
    final username = Storage.getUserName() ?? 'kasir@medix.com';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Role: $role', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar (Logout)', style: TextStyle(color: Colors.red)),
              onTap: () {
                Storage.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
