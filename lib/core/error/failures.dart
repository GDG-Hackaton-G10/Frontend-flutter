class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server Error Occurred']) : super(message);
}
