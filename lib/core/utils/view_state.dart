sealed class ViewState<T> {
  const ViewState();

  bool get isLoading => this is Loading<T>;
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  bool get isEmpty => this is Empty<T>;
  bool get isInitial => this is Initial<T>;

  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }
}

final class Initial<T> extends ViewState<T> {
  const Initial();
}

final class Loading<T> extends ViewState<T> {
  final String? message;
  const Loading([this.message]);
}

final class Success<T> extends ViewState<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends ViewState<T> {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

final class Empty<T> extends ViewState<T> {
  final String message;
  const Empty([this.message = 'No data found']);
}
