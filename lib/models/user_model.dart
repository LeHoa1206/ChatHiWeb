import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role;
  final bool online;
  final String status;
  final DateTime? lastActive;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.online,
    required this.status,
    this.lastActive,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'],
      role: data['role'] ?? 'employee',
      online: data['online'] ?? false,
      status: data['status'] ?? 'offline',
      lastActive: data['lastActive']?.toDate(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'online': online,
      'status': status,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    bool? online,
    String? status,
    DateTime? lastActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      online: online ?? this.online,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}