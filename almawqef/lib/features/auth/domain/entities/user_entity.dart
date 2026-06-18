import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String? image;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.image,
    this.isVerified = false,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? image,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      image: image ?? this.image,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, role, image, isVerified];
}
