import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String fullName;
  final String phoneNumber;
  final String profilePhotoUrl;
  final VoidCallback onEditPressed;
  
  const ProfileHeader({
    super.key,
    required this.username,
    required this.fullName,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    required this.onEditPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
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