/// Model representing a user's profile data from the `profiles` table.
class UserProfileModel {
  final String id;
  final String? username;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final String? profileImage;
  final bool isProfileComplete;
  final String? role;

  const UserProfileModel({
    required this.id,
    this.username,
    this.phone,
    this.whatsapp,
    this.address,
    this.profileImage,
    this.isProfileComplete = false,
    this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      address: json['address'] as String?,
      profileImage: json['profile_image'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'whatsapp': whatsapp,
      'address': address,
      'profile_image': profileImage,
      'is_profile_complete': isProfileComplete,
      'role': role,
    };
  }

  /// Returns a copy with selectively updated fields.
  UserProfileModel copyWith({
    String? username,
    String? phone,
    String? whatsapp,
    String? address,
    String? profileImage,
    bool? isProfileComplete,
  }) {
    return UserProfileModel(
      id: id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      role: role,
    );
  }
}
