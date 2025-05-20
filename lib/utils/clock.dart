/// clock.dart
///
/// 시간 관련 유틸리티를 제공하는 파일입니다.
/// 테스트 가능한 시간 처리와 시간 의존성 주입을 위한 기능을 제공합니다.
///
/// 주요 기능:
/// - 현재 시간 조회
/// - 테스트를 위한 시간 모킹
/// - 시간 의존성 주입
library;

/// 현재 시간을 반환하는 함수 타입을 정의합니다.
/// DateTime을 반환하는 함수를 나타내는 typedef입니다.
typedef CurrentDateTimeResolver = DateTime Function();

// ignore: prefer_function_declarations_over_variables
/// 기본 시간 처리 함수입니다.
/// 실제 시스템의 현재 시간을 반환합니다.
// ignore: prefer_function_declarations_over_variables
final defaultDateTimeResolver = () => DateTime.now();

/// 시간 처리를 위한 유틸리티 클래스입니다.
///
/// 이 클래스는 애플리케이션에서 사용되는 시간 처리를 중앙화하고,
/// 테스트 시에 시간을 모킹할 수 있도록 지원합니다.
///
/// 사용 예시:
/// ```dart
/// // 기본 사용
/// DateTime now = Clock.now();
///
/// // 테스트에서 시간 모킹
/// Clock.dateTimeResolver = () => DateTime(2024, 1, 1);
/// ```
class Clock {
  /// 현재 시간을 반환하는 함수입니다.
  /// 기본값은 실제 시스템 시간을 반환하지만,
  /// 테스트나 특수한 상황에서 다른 시간을 반환하도록 변경할 수 있습니다.
  static CurrentDateTimeResolver dateTimeResolver = defaultDateTimeResolver;

  /// 현재 시간을 반환합니다.
  /// 설정된 dateTimeResolver를 사용하여 현재 시간을 가져옵니다.
  ///
  /// 반환값:
  /// - 기본적으로 실제 시스템의 현재 시간
  /// - 테스트 시에는 모킹된 시간
  static DateTime now() => dateTimeResolver();
}
