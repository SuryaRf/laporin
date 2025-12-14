import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporin/models/enums.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? nim; // For Mahasiswa
  final String? nip; // For Dosen
  final String? phone;
  final String? avatarUrl;
  final String? fcmToken; // For push notifications
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim,
    this.nip,
    this.phone,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle created_at which can be Timestamp, String, or null
    DateTime createdAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
    } else {
      createdAt = DateTime.now();
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user, // Default role jika tidak ditemukan
      ),
      nim: json['nim'] as String?,
      nip: json['nip'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'nim': nim,
      'nip': nip,
      'phone': phone,
      'avatar_url': avatarUrl,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? nim,
    String? nip,
    String? phone,
    String? avatarUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      nim: nim ?? this.nim,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get identifier {
    if (role == UserRole.mahasiswa && nim != null) {
      return nim!;
    } else if (role == UserRole.dosen && nip != null) {
      return nip!;
    }
    return email;
  }
}
