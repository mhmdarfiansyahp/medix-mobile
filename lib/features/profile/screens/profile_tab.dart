import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await AuthService.getProfile();
      if (!mounted) return;
      _nameController.text = user['nama_user'] ?? user['username'] ?? '';
      _phoneController.text = user['no_telp'] ?? '';
    } catch (_) {}
  }

  void _showEditProfileDialog() {
    final user = Storage.getUser() ?? {};
    _nameController.text = user['nama_user'] ?? user['username'] ?? '';
    _phoneController.text = user['no_telp'] ?? '';
    _error = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Edit Profil & Kontak'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon (08xxx / +62xxx)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (user['foto'] ?? '').isNotEmpty
                            ? NetworkImage('https://medix-be.example.com/uploads/profiles/${user['foto']}')
                            : null,
                        child: (user['foto'] ?? '').isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () async {
                              final imagePath = await _pickImage();
                              if (imagePath != null) {
                                setModalState(() {
                                  _isLoading = true;
                                });
                                try {
                                  await AuthService.updateProfilePhoto(imagePath);
                                  if (!ctx.mounted) return;
                                  setModalState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
                                  );
                                } catch (e) {
                                  setModalState(() {
                                    _error = e.toString().replaceAll('Exception: ', '');
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final phone = _phoneController.text.trim();
                      if (phone.isNotEmpty && !RegExp(r'^(\+62|0)[0-9]{9,12}$').hasMatch(phone)) {
                        setModalState(() => _error = 'Format HP salah (contoh: 08123456789 / +628123456789)');
                        return;
                      }

                      setModalState(() => _isLoading = true);
                      try {
                        await AuthService.updateProfile(
                          _nameController.text.trim(),
                          phone,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        setModalState(() {
                          _error = null;
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        setModalState(() {
                          _error = e.toString().replaceAll('Exception: ', '');
                          _isLoading = false;
                        });
                      }
                    },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickImage() async {
    return null; // TODO: Implement with image_picker package
  }

  Future<void> _updateProfilePhoto(String imagePath) async {
    // TODO: Implement API call to upload profile photo
    // Should be: await AuthService.updateProfilePhoto(imagePath)
    throw UnimplementedError('Photo upload not implemented yet');
  }

  @override
  Widget build(BuildContext context) {
    final user = Storage.getUser() ?? {};
    final role = (user['role'] ?? Storage.getUserRole() ?? 'kasir').toString().toUpperCase();
    final username = user['username'] ?? Storage.getUserName() ?? 'kasir';
    final nama = user['nama_user'] ?? username;
    final phone = user['no_telp'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF2563EB),
              child: const Icon(Icons.person, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
                ),
              child: Text(
                'ROLE: $role',
                style: const TextStyle(
                  color: const Color(0xFF1E40AF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Username'),
                    subtitle: Text(username),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Nomor Telepon'),
                    subtitle: Text(phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: const Color(0xFF2563EB)),
                      onPressed: _showEditProfileDialog,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar (Logout)', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                AuthService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
