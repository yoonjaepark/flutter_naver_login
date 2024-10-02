typedef CurrentDateTimeResolver = DateTime Function();

// ignore: prefer_function_declarations_over_variables
final defaultDateTimeResolver = () => DateTime.now();

class Clock {
  static CurrentDateTimeResolver dateTimeResolver = defaultDateTimeResolver;

  static DateTime now() => dateTimeResolver();
}
