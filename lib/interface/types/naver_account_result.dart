import 'package:flutter/foundation.dart';

@immutable
class NaverAccountResult {
  final String? id;
  final String? email;
  final String? name;
  final String? nickname;
  final String? profileImage;
  final String? gender;
  final String? age;
  final String? birthday;
  final String? birthYear;
  final String? mobile;
  final String? mobileE164;

  /// 네이버 계정 결과를 생성하는 생성자입니다.
  ///
  /// 이 생성자는 네이버 계정 결과의 각 속성을 초기화합니다.
  ///
  /// 매개변수:
  /// - id: 계정 ID
  /// - email: 이메일 주소
  /// - name: 이름
  /// - nickname: 닉네임
  /// - profileImage: 프로필 이미지 URL
  /// - gender: 성별
  /// - age: 연령대
  /// - birthday: 생일
  /// - birthYear: 출생연도
  /// - mobile: 휴대폰 번호
  const NaverAccountResult({
    this.id,
    this.email,
    this.name,
    this.nickname,
    this.profileImage,
    this.gender,
    this.age,
    this.birthday,
    this.birthYear,
    this.mobile,
    this.mobileE164,
  });

  /// 맵에서 네이버 계정 결과를 생성하는 팩토리 메서드입니다.
  ///
  /// 이 메서드는 맵에서 네이버 계정 결과의 각 속성을 추출하고,
  /// 해당 속성을 사용하여 NaverAccountResult 객체를 생성합니다.
  ///
  factory NaverAccountResult.fromMap(Map map) {
    return NaverAccountResult(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      nickname: map['nickname'],
      profileImage: map['profile_image'],
      gender: map['gender'],
      age: map['age'],
      birthday: map['birthday'],
      birthYear: map['birthyear'],
      mobile: map['mobile'],
      mobileE164: map['mobile_e164'],
    );
  }

  /// 네이버 계정 결과를 맵으로 변환하는 메서드입니다.
  ///
  /// 이 메서드는 NaverAccountResult 객체의 각 속성을 맵으로 변환하고,
  /// 해당 맵을 반환합니다.
  ///
  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'name': name,
    'nickname': nickname,
    'profileImage': profileImage,
    'gender': gender,
    'age': age,
    'birthday': birthday,
    'birthYear': birthYear,
    'mobile': mobile,
    'mobileE164': mobileE164,
  };

  /// 네이버 계정 결과를 비교하는 메서드입니다.
  ///
  /// 이 메서드는 네이버 계정 결과를 비교하고,
  /// 같은 경우 true를 반환하고, 다른 경우 false를 반환합니다.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NaverAccountResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          nickname == other.nickname &&
          profileImage == other.profileImage &&
          gender == other.gender &&
          age == other.age &&
          birthday == other.birthday &&
          birthYear == other.birthYear &&
          mobile == other.mobile &&
          mobileE164 == other.mobileE164;

  /// 네이버 계정 결과의 해시 코드를 반환하는 메서드입니다.
  ///
  /// 이 메서드는 네이버 계정 결과의 각 속성을 해시 코드로 변환하고,
  /// 해당 해시 코드를 반환합니다.
  @override
  int get hashCode => Object.hash(
    id,
    email,
    name,
    nickname,
    profileImage,
    gender,
    age,
    birthday,
    birthYear,
    mobile,
    mobileE164,
  );
}
