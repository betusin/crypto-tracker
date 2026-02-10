sealed class FailableResult<TData, TError> {
  const FailableResult();

  _maybeSubtype<TCast>() => this is TCast ? this as TCast : null;

  TError? get error => _maybeSubtype<FailureResult<TData, TError>>()?.error;
  TData? get data => _maybeSubtype<SuccessResult<TData, TError>>()?.data;

  bool get isFailure => error != null;
  bool get isSuccess => !isFailure;

  factory FailableResult.success(TData data) => SuccessResult(data);
  factory FailableResult.failure(TError error) => FailureResult(error);
}

class SuccessResult<TData, TError> extends FailableResult<TData, TError> {
  @override
  final TData data;

  const SuccessResult(this.data);
}

class FailureResult<TData, TError> extends FailableResult<TData, TError> {
  @override
  final TError error;

  const FailureResult(this.error);
}
