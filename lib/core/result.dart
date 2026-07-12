/// 统一的 Result 类型 — Errors-as-values 模式
sealed class Result<T> {
  const Result();
  T getOrElse(T Function(AppError error) orElse);
  R fold<R>(R Function(T value) onSuccess, R Function(AppError error) onFailure);
  Result<R> map<R>(R Function(T value) transform);
  bool get isSuccess;
  bool get isFailure;
  T get value;
  AppError get error;
}

class Success<T> extends Result<T> {
  final T _value;
  const Success(this._value);
  @override T getOrElse(T Function(AppError error) orElse) => _value;
  @override R fold<R>(R Function(T value) onSuccess, R Function(AppError error) onFailure) => onSuccess(_value);
  @override Result<R> map<R>(R Function(T value) transform) => Success(transform(_value));
  @override bool get isSuccess => true;
  @override bool get isFailure => false;
  @override T get value => _value;
  @override AppError get error => throw StateError('Cannot get error from Success');
}

class Failure<T> extends Result<T> {
  final AppError _error;
  const Failure(this._error);
  @override T getOrElse(T Function(AppError error) orElse) => orElse(_error);
  @override R fold<R>(R Function(T value) onSuccess, R Function(AppError error) onFailure) => onFailure(_error);
  @override Result<R> map<R>(R Function(T value) transform) => Failure(_error);
  @override bool get isSuccess => false;
  @override bool get isFailure => true;
  @override T get value => throw StateError('Cannot get value from Failure: ${_error.message}');
  @override AppError get error => _error;
}

class AppError {
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;
  const AppError({required this.message, this.code, this.cause, this.stackTrace});

  factory AppError.unknown([Object? cause, StackTrace? stack]) =>
      AppError(message: 'An unexpected error occurred', code: 'UNKNOWN', cause: cause, stackTrace: stack);

  factory AppError.fromException(Object e, [StackTrace? stack]) =>
      AppError(message: e.toString(), code: 'EXCEPTION', cause: e, stackTrace: stack);

  @override String toString() => 'AppError($code, $message)';

  String get userMessage => switch (code) {
    'NETWORK_ERROR' => '网络连接失败，请检查网络',
    'UNKNOWN' => '发生未知错误，请重试',
    'EXCEPTION' => '发生异常，请重试',
    _ => message,
  };
}

typedef AsyncResult<T> = Future<Result<T>>;
