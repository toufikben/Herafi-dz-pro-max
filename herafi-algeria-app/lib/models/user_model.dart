import 'package:equatable/equatable.dart';

enum UserRole { customer, craftsman, company, group, admin }

enum CraftsmanType { personal, company, group }

class UserModel extends Equatable {
  final String uid;
  final String phone;
  final String? fullName;
  final String? photoUrl;
  final UserRole role;
  final CraftsmanType? craftsmanType;
  final String? wilaya;
  final String? commune;
  final String? address;
  final List<String> specialties; // category ids
  final int? yearsOfExperience;
  final String? bio;
  final String? priceNote;
  final List<String> workPhotos;
  final double rating;
  final int ratingCount;
  final bool isVerified;
  final bool isActive;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.phone,
    this.fullName,
    this.photoUrl,
    required this.role,
    this.craftsmanType,
    this.wilaya,
    this.commune,
    this.address,
    this.specialties = const [],
    this.yearsOfExperience,
    this.bio,
    this.priceNote,
    this.workPhotos = const [],
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isVerified = false,
    this.isActive = true,
    this.isBlocked = false,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCraftsman =>
      role == UserRole.craftsman ||
      role == UserRole.company ||
      role == UserRole.group;

  bool get isProfileComplete =>
      fullName != null &&
      fullName!.isNotEmpty &&
      wilaya != null &&
      commune != null;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      phone: map['phone'] ?? '',
      fullName: map['fullName'],
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      craftsmanType: map['craftsmanType'] != null
          ? CraftsmanType.values.firstWhere(
              (e) => e.name == map['craftsmanType'],
              orElse: () => CraftsmanType.personal,
            )
          : null,
      wilaya: map['wilaya'],
      commune: map['commune'],
      address: map['address'],
      specialties: List<String>.from(map['specialties'] ?? []),
      yearsOfExperience: map['yearsOfExperience'],
      bio: map['bio'],
      priceNote: map['priceNote'],
      workPhotos: List<String>.from(map['workPhotos'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      isBlocked: map['isBlocked'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'role': role.name,
      'craftsmanType': craftsmanType?.name,
      'wilaya': wilaya,
      'commune': commune,
      'address': address,
      'specialties': specialties,
      'yearsOfExperience': yearsOfExperience,
      'bio': bio,
      'priceNote': priceNote,
      'workPhotos': workPhotos,
      'rating': rating,
      'ratingCount': ratingCount,
      'isVerified': isVerified,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? photoUrl,
    UserRole? role,
    CraftsmanType? craftsmanType,
    String? wilaya,
    String? commune,
    String? address,
    List<String>? specialties,
    int? yearsOfExperience,
    String? bio,
    String? priceNote,
    List<String>? workPhotos,
    double? rating,
    int? ratingCount,
    bool? isVerified,
    bool? isActive,
    bool? isBlocked,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      phone: phone,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      craftsmanType: craftsmanType ?? this.craftsmanType,
      wilaya: wilaya ?? this.wilaya,
      commune: commune ?? this.commune,
      address: address ?? this.address,
      specialties: specialties ?? this.specialties,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      priceNote: priceNote ?? this.priceNote,
      workPhotos: workPhotos ?? this.workPhotos,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        phone,
        fullName,
        role,
        wilaya,
        commune,
        rating,
        isVerified,
      ];
}
