import '../../auth/services/auth_service.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    return await AuthService.getProfile();
  }
  
  Future<Map<String, dynamic>> updateProfile(String fullName, String phoneNumber) async {
    return await AuthService.updateProfile(fullName, phoneNumber);
  }
  
  Future<Map<String, dynamic>> updateProfilePhoto(String imagePath) async {
    return await AuthService.updateProfilePhoto(imagePath);
  }
}