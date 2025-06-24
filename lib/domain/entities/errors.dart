sealed class DomainError {
  const DomainError();

  factory DomainError.fromStatusCode(int statusCode) {
    if (statusCode == 401) return const SessionExpiredError();
    return const UnexpectedError();
  }
}

final class UnexpectedError extends DomainError {
  const UnexpectedError();
}

final class SessionExpiredError extends DomainError {
  const SessionExpiredError();
}
