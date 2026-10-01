class AppFailure {
  final String message;
  @override
  String toString() {
    return 'Appfailure(message:$message)';
  }
  AppFailure([this.message='Sorry an unexpected error occured']);
}