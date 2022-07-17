class NoInternetException<T> implements Exception {
  final String message;
  final T? data;

  NoInternetException({
    this.message = "NO_INTERNET_EXCEPTION",
    this.data,
  });

  @override
  String toString() {
    return message;
  }
}
