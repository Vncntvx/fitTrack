/// Use Case 基类
/// T: 返回类型, P: 参数类型
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

/// 无参数 Use Case 基类
abstract class NoParamUseCase<T> {
  Future<T> call();
}