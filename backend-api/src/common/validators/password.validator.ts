import {
  registerDecorator,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';

@ValidatorConstraint({ name: 'isStrongPassword', async: false })
class IsStrongPasswordConstraint implements ValidatorConstraintInterface {
  validate(value: unknown): boolean {
    if (typeof value !== 'string') return false;

    // At least 8 characters, one letter and one number.
    return value.length >= 8 && /[A-Za-z]/.test(value) && /\d/.test(value);
  }

  defaultMessage(): string {
    return 'password must be at least 8 characters and include at least one letter and one number';
  }
}

/**
 * Password-strength validator. Stricter than a bare `@MinLength(6)` — the
 * app previously accepted any 6-character password (e.g. "aaaaaa").
 */
export function IsStrongPassword(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName,
      options: validationOptions,
      constraints: [],
      validator: IsStrongPasswordConstraint,
    });
  };
}
