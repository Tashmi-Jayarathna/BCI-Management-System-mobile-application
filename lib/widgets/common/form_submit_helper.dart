import 'package:flutter/material.dart';
import '../../services/validation/validator_interface.dart';
import 'app_snackbar.dart';

/// Shared validate-then-save control flow for Add/Edit form dialogs:
/// validate the Form, build the model, run it through the domain
/// [IValidator], surface errors via [AppSnackBar], or save and close.
void submitValidatedForm<T>(
  BuildContext context, {
  required GlobalKey<FormState> formKey,
  required T Function() buildModel,
  required IValidator<T> validator,
  required ValueChanged<T> onSave,
}) {
  if (!formKey.currentState!.validate()) return;

  final model = buildModel();
  final result = validator.validate(model);

  if (!result.isValid) {
    AppSnackBar.error(context, result.errors.join('\n'));
    return;
  }

  onSave(model);
  Navigator.of(context).pop();
}
