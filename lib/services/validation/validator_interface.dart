/// Validation result object encapsulation.
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({required this.isValid, this.errors = const []});

  factory ValidationResult.success() => const ValidationResult(isValid: true);
  factory ValidationResult.failure(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);
}

/// Generic Validator Interface following Single Responsibility Principle.
abstract class IValidator<T> {
  ValidationResult validate(T entity);
}
