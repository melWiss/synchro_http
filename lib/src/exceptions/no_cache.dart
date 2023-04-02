class NotCachedException implements Exception {
  final String message;

  NotCachedException({
    this.message = "NOT_CACHED_EXCEPTION",
  });

  @override
  String toString() {
    return message;
  }
}
