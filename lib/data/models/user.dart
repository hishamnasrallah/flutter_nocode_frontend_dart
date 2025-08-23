// lib/data/models/user.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final int id;
  final String username;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  const User({
    required this.id,
    required this.username,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    required this.dateJoined,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, dateJoined, isActive];
}