import 'package:flutter/foundation.dart';

@immutable
class NaverAccountResult {
  final String nickname;
  final String id;
  final String name;
  final String email;
  final String gender;
  final String age;
  final String birthday;
  final String birthyear;
  final String profileImage;
  final String mobile;
  final String mobileE164;

  const NaverAccountResult({
    required this.nickname,
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.birthday,
    required this.birthyear,
    required this.profileImage,
    required this.mobile,
    required this.mobileE164,
  });

  factory NaverAccountResult.fromMap(Map<String, dynamic> map) =>
      NaverAccountResult(
        nickname: map['nickname'] ?? '',
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        gender: map['gender'] ?? '',
        age: map['age'] ?? '',
        birthday: map['birthday'] ?? '',
        birthyear: map['birthyear'] ?? '',
        profileImage: map['profile_image'] ?? '',
        mobile: map['mobile'] ?? '',
        mobileE164: map['mobileE164'] ?? '',
      );

  @override
  String toString() {
    return '{ '
        'nickname: $nickname, '
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'gender: $gender, '
        'age: $age, '
        'birthday: $birthday, '
        'birthyear: $birthyear, '
        'profileImage: $profileImage, '
        'mobile: $mobile, '
        'mobileE164: $mobileE164'
        ' }';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NaverAccountResult &&
          runtimeType == other.runtimeType &&
          nickname == other.nickname &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          gender == other.gender &&
          age == other.age &&
          birthday == other.birthday &&
          birthyear == other.birthyear &&
          profileImage == other.profileImage &&
          mobile == other.mobile &&
          mobileE164 == other.mobileE164;

  @override
  int get hashCode => Object.hash(
        nickname,
        id,
        name,
        email,
        gender,
        age,
        birthday,
        birthyear,
        profileImage,
        mobile,
        mobileE164,
      );
}
