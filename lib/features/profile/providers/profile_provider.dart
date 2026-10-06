import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  
  String _username = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _profilePhotoUrl = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  ProfileProvider({ProfileService? profileService}) 
      : _profileService = profileService ?? ProfileService();
  
  String get username => _username;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get profilePhotoUrl => _profilePhotoUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
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
      rethrow;
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
      rethrow;
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