import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'profile_header.dart';
import 'profile_info_card.dart';
import 'profile_edit_dialog.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileProvider _profileProvider;
  
  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    _profileProvider.loadProfile();
  }
  
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ProfileEditDialog(
        currentFullName: _profileProvider.fullName,
        currentPhoneNumber: _profileProvider.phoneNumber,
        currentPhotoUrl: _profileProvider.profilePhotoUrl,
        onProfileUpdated: (fullName, phoneNumber) async {
          await _profileProvider.updateProfileData(fullName, phoneNumber);
        },
        onPhotoUpdated: (imagePath) async {
          await _profileProvider.updateProfilePhoto(imagePath);
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Akun')),
      body: Provider.value(
        value: _profileProvider,
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.username.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadProfile(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ProfileHeader(
                    username: provider.username,
                    fullName: provider.fullName,
                    phoneNumber: provider.phoneNumber,
                    profilePhotoUrl: provider.profilePhotoUrl,
                    onEditPressed: _showEditDialog,
                  ),
                  const SizedBox(height: 16),
                  ProfileInfoCard(
                    username: provider.username,
                    phoneNumber: provider.phoneNumber,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Keluar (Logout)',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        AuthService.logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/login', 
                          (route) => false
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}