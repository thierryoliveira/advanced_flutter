enum DomainError {
  unexpected,
  sessionExpired;

  factory DomainError.fromStatusCode(int statusCode) {
    if (statusCode == 401) return DomainError.sessionExpired;
    return DomainError.unexpected;
  }
}
