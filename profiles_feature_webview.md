// profiles_feature_webview.md
# Architecture Moduler untuk Fitur Profil

## Gambaran Umum

Modul ini mendefinisikan struktur arsitektur modular untuk fitur Profil di aplikasi Medix Mobile, mengikuti prinsip-prinsip berikut:

1. **Single Responsibility Principle**: Setiap kelas/komponen memiliki satu tanggung jawab yang jelas
2. **Separation of Concerns**: Pisahkan UI, logika bisnis, dan data management
3. **Reuse**: Buat komponen dan layanan yang dapat digunakan kembali
4. **Testability**: Buat setiap bagian mudah diuji secara unit
5. **Pola Konstan**: Ikuti pola yang sudah ada di seluruh codebase

## Struktur Direktori

```
lib/features/profile/
├── screens/
│   ├── ProfileScreen.dart        # Root widget
│   ├── ProfileHeader.dart        # Header profil
│   ├── ProfileInfoCard.dart      # Kartu info (username, telepon)
│   └── ProfileEditDialog.dart    # Dialog edit profil
├── services/
│   ├── ProfileService.dart       # Logika profil khusus (get/update)
│   └── ProfilePhotoService.dart  # Logika upload foto khusus
└── providers/
    └── ProfileProvider.dart       # Provider untuk state management
```

## Arsitektur saat Ini

### Struktur Saat Ini (Sebelum Refactor)

```
lib/features/profile/
└── screens/
    └── profile_tab.dart (252 baris)
        ├── State management (controllers)
        ├── Data loading (getProfile)
        ├── Business logic (updateProfile, updateProfilePhoto)
        ├── UI rendering (header, cards, dialog)
        └── UI event handling (tap, form submit)
```

**Masalah dengan arsitektur saat ini:**

1. **Ketergantungan tinggi**: File besar yang melakukan terlalu banyak
2. **Pengujian sulit**: Sulit untuk menguji fungsi tertentu secara terpisah
3. **Reuse rendah**: Komponen sulit digunakan kembali
4. **Pengembangan lambat**: Mengubah satu bagian berisiko memengaruhi bagian lain
5. **Kinerja buruk**: Widget rebuild yang tidak perlu

## Arsitektur Modular yang Diusulkan

### 1. ProfileProvider.dart - State Management

```dart
// lib/features/profile/providers/ProfileProvider.dart
import 'package:flutter/material.dart';
import '../services/ProfileService.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  
  String _username = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _profilePhotoUrl = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Constructor dengan dependency injection
  ProfileProvider({ProfileService? profileService}) 
      : _profileService = profileService ?? ProfileService();
  
  // Getters
  String get username => _username;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get profilePhotoUrl => _profilePhotoUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Metode bisnis
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _profileService.getProfile();
      _username = user['username'] ?? '';
      _fullName = user['nama_user'] ?? '';
      _phoneNumber = user['no_telp'] ?? '';
      _profilePhotoUrl = user['foto'] ?? '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateProfileData(String fullName, String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _profileService.updateProfile(fullName, phoneNumber);
      _fullName = fullName;
      _phoneNumber = phoneNumber;
    } catch (e) {
      _errorMessage = e.toString();
      throw e; // Propagate error to UI layer
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateProfilePhoto(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _profileService.updateProfilePhoto(imagePath);
      _profilePhotoUrl = user['foto'] ?? _profilePhotoUrl;
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

### 2. ProfileService.dart - Business Logic

```dart
// lib/features/profile/services/ProfileService.dart
import '../../auth/services/auth_service.dart'; // Reusing existing service

class ProfileService {
  final AuthService _authService;
  
  // Constructor dengan dependency injection
  ProfileService({AuthService? authService}) 
      : _authService = authService ?? AuthService();
  
  // Metode profil khusus
  Future<Map<String, dynamic>> getProfile() async {
    return await _authService.getProfile();
  }
  
  Future<Map<String, dynamic>> updateProfile(String fullName, String phoneNumber) async {
    return await _authService.updateProfile(fullName, phoneNumber);
  }
  
  Future<Map<String, dynamic>> updateProfilePhoto(String imagePath) async {
    return await _authService.updateProfilePhoto(imagePath);
  }
}
```

### 3. ProfileHeader.dart - UI Header

```dart
// lib/features/profile/screens/ProfileHeader.dart
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String fullName;
  final String phoneNumber;
  final String profilePhotoUrl;
  final VoidCallback onEditPressed;
  
  const ProfileHeader({
    Key? key,
    required this.username,
    required this.fullName,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    required this.onEditPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF2563EB),
            child: profilePhotoUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profilePhotoUrl,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 44, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.person, size: 44, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Info pengguna
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      phoneNumber.isNotEmpty ? phoneNumber : 'No phone number',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tombol edit
          IconButton(
            onPressed: onEditPressed,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: const Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. ProfileInfoCard.dart - Kartu Info

```dart
// lib/features/profile/screens/ProfileInfoCard.dart
import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String username;
  final String phoneNumber;
  
  const ProfileInfoCard({
    Key? key,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);
  
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
                // Aksi edit telepon akan ditangani oleh parent
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5. ProfileEditDialog.dart - Dialog Edit Profil

```dart
// lib/features/profile/screens/ProfileEditDialog.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditDialog extends StatefulWidget {
  final String currentFullName;
  final String currentPhoneNumber;
  final String currentPhotoUrl;
  final Future<void> Function(String fullName, String phoneNumber) onProfileUpdated;
  final Future<void> Function(String imagePath) onPhotoUpdated;
  
  const ProfileEditDialog({
    Key? key,
    required this.currentFullName,
    required this.currentPhoneNumber,
    required this.currentPhotoUrl,
    required this.onProfileUpdated,
    required this.onPhotoUpdated,
  }) : super(key: key);
  
  @override
  _ProfileEditDialogState createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedImagePath;
  
  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.currentFullName;
    _phoneController.text = widget.currentPhoneNumber;
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await widget.onProfileUpdated(
        _fullNameController.text.trim(),
        _phoneController.text.trim(),
      );
      
      if (_selectedImagePath != null) {
        await widget.onPhotoUpdated(_selectedImagePath!);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profil & Kontak'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon (08xxx / +62xxx)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final phoneRegex = RegExp(r'^(\+62|0)[0-9]{9,12}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Format HP salah (contoh: 08123456789 / +628123456789)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (_selectedImagePath != null
                          ? Image.file(File(_selectedImagePath!))
                          : (widget.currentPhotoUrl.isNotEmpty
                              ? NetworkImage(widget.currentPhotoUrl)
                              : null)) as ImageProvider?,
                      child: _selectedImagePath == null && widget.currentPhotoUrl.isEmpty
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
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
```

### 6. ProfileScreen.dart - Root Widget

```dart
// lib/features/profile/screens/ProfileScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ProfileProvider.dart';
import 'ProfileHeader.dart';
import 'ProfileInfoCard.dart';

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
      body: Consumer<ProfileProvider>(
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
                // Header dengan foto profil
                ProfileHeader(
                  username: provider.username,
                  fullName: provider.fullName,
                  phoneNumber: provider.phoneNumber,
                  profilePhotoUrl: provider.profilePhotoUrl,
                  onEditPressed: _showEditDialog,
                ),
                const SizedBox(height: 16),
                // Kartu info
                ProfileInfoCard(
                  username: provider.username,
                  phoneNumber: provider.phoneNumber,
                ),
                const SizedBox(height: 16),
                // Tombol logout
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Keluar (Logout)',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Logout akan ditangani oleh auth service
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
    );
  }
}
```

### 7. main.dart - Register Provider

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_shell.dart';
import 'features/profile/screens/ProfileScreen.dart';
import 'features/profile/providers/ProfileProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MedixApp());
}

class MedixApp extends StatelessWidget {
  const MedixApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medix Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainHomeScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
```

## Keuntungan Arsitektur Modular

### 1. Kemudahan pengujian
- Setiap bagian dapat diuji secara unit
- Mock dependencies dengan mudah
- Uji kasus edge dengan fokus

### 2. Reuse
- Header profil dapat digunakan di mana saja
- Kartu info dapat digunakan di halaman lain
- Logika profil dapat digunakan di bagian UI lain

### 3. Pengembangan paralel
- Tim dapat bekerja pada UI dan logika bisnis secara bersamaan
- Pengembang frontend dapat bekerja tanpa backend
- Pengembang backend dapat bekerja tanpa UI

### 4. Kinerja
- Provider dapat menghindari rebuild yang tidak perlu
- Lazy loading komponen
- Optimasi build

### 5. Pemeliharaan
- Perubahan pada satu bagian tidak memengaruhi bagian lain
- Kesalahan mudah dilacak
- Kode lebih mudah dipahami

### 6. Skalabilitas
- Mudah menambahkan fitur baru
- Dapat menambahkan lebih banyak provider
- Dapat menambahkan lebih banyak screens

## Checklist Implementasi

### Tahap 1: Refactor
- [ ] Buat folder providers, services
- [ ] Pisahkan profil_tab.dart menjadi file-file yang lebih kecil
- [ ] Hapus fungsi _updateProfilePhoto yang tidak digunakan
- [ ] Buat ProfileProvider.dart
- [ ] Buat ProfileService.dart
- [ ] Buat ProfileHeader.dart
- [ ] Buat ProfileInfoCard.dart
- [ ] Buat ProfileEditDialog.dart
- [ ] Buat ProfileScreen.dart sebagai entry point

### Tahap 2: Integrasi
- [ ] Daftarkan Provider di MultiProvider
- [ ] Perbarui main.dart untuk menambahkan routing profil
- [ ] Perbarui pubspec.yaml jika diperlukan
- [ ] Uji semua fitur

### Tahap 3: Verifikasi
- [ ] Jalankan flutter analyze
- [ ] Jalankan flutter test
- [ ] Uji manual semua layar
- [ ] Verifikasi upload foto profil
- [ ] Verifikasi edit profil
- [ ] Verifikasi error handling

## Strategi Penulisan Ulang

Mengingat codebase Flutter ini memiliki ketergantungan antar fitur yang sudah mapan, saya menyarankan strategi penulisan ulang bertahap:

### Bulan 1-2: Refactor Bertahap
- Buat ProfileProvider.dart terlebih dahulu
- Buat ProfileHeader.dart
- Perbarui profil_tab.dart untuk menggunakan Provider

### Bulan 2-3: Layanan Bisnis
- Buat ProfileService.dart
- Pisahkan logika layanan

### Bulan 3-4: Dialog dan Kartu Info
- Buat ProfileEditDialog.dart
- Buat ProfileInfoCard.dart

### Bulan 4-5: Selesai dan Verifikasi
- Buat ProfileScreen.dart
- Uji semua fitur

### Rekomendasi Diperbarui
- Gunakan `Provider` package untuk state management (sudah digunakan di auth_service.dart melalui Storage)
- Gunakan dependency injection untuk service
- Pertahankan kebergantungan pada AuthService yang sudah ada untuk profil dan update foto

## Template Skor Kemunduran Ponytail

```dart
// ProfileScreen.dart - ponytail: hindari state management yang tidak perlu
// ponytail: gunakan provider yang sudah ada, jangan buat baru untuk fitur kecil
// ponytail: pisahkan concern yang berbeda dalam widget terpisah
```

## Kebutuhan Dependency

Tergantung pada package yang sudah ada:
- `provider` - untuk state management
- `image_picker` - sudah ada
- `flutter/material.dart` - sudah ada

Tidak diperlukan package baru.

## Catatan Tambahan

1. **Penanganan Token**: Server saat ini menggunakan 1 jam. Menurut persyaratan, harusnya 8 jam. Tergantung pada backend, mungkin perlu memperbarui server.

2. **Penanganan Token Expired**: Saat ini, listener token expired di main.dart menggunakan navigator global. Ini berfungsi untuk redirect otomatis ke login.

3. **Upload Foto**: Implementasi upload foto sudah hampir lengkap. Perlu memastikan `image_picker` package diinstal.

4. **Verifikasi Nomor Telepon**: Validasi format sudah ada di ProfileEditDialog.

5. **Compatibility**: Periksa bahwa provider package digunakan secara konsisten di seluruh codebase.

## Contoh Dokumentasi Developer

```dart
// Menggunakan ProfileProvider di halaman lain
class OtherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Text('Hello, ${provider.username}');
        },
      ),
    );
  }
}
```

## Pengamatan Terakhir

Arsitektur modular ini mengikuti pola yang sudah ada di seluruh codebase (menggunakan Provider dan dependency injection), membuatnya konsisten dengan kode yang sudah ada. Ini membuat onboarding menjadi lebih mudah dan sejalan dengan konvensi proyek.