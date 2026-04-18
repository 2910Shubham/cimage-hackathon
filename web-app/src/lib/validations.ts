export type AuthFormValues = {
  email: string;
  password: string;
  name?: string;
};

export function isValidEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function validateAuthForm(values: AuthFormValues) {
  const errors: string[] = [];

  if (!isValidEmail(values.email)) {
    errors.push("Please provide a valid email address.");
  }

  if (values.password.trim().length < 8) {
    errors.push("Password must be at least 8 characters long.");
  }

  if (values.name !== undefined && values.name.trim().length === 0) {
    errors.push("Name cannot be empty.");
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}
