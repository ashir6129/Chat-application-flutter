export function validateEmail(email) {
  if (!email || typeof email !== 'string') {
    return 'Email is required';
  }

  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!pattern.test(email.trim())) {
    return 'Invalid email format';
  }

  return null;
}

export function validatePassword(password, field = 'Password') {
  if (!password || typeof password !== 'string') {
    return `${field} is required`;
  }

  if (password.length < 6) {
    return `${field} must be at least 6 characters`;
  }

  return null;
}

export function validateRegister(body) {
  const nameError = !body.name?.trim() ? 'Name is required' : null;
  const emailError = validateEmail(body.email);
  const passwordError = validatePassword(body.password);

  return nameError || emailError || passwordError;
}

export function validateLogin(body) {
  const emailError = validateEmail(body.email);
  const passwordError = !body.password ? 'Password is required' : null;

  return emailError || passwordError;
}

export function validateForgotPassword(body) {
  return validateEmail(body.email);
}

export function validateResendOtp(body) {
  const emailError = validateEmail(body.email);
  if (emailError) return emailError;
  if (!body.reset_token) return 'Reset token is required';
  return null;
}

export function validateResetPassword(body) {
  const emailError = validateEmail(body.email);
  if (emailError) return emailError;
  if (!body.reset_token) return 'Reset token is required';
  if (!body.otp || String(body.otp).trim().length < 4) return 'Valid OTP is required';

  const passwordError = validatePassword(body.new_password, 'New password');
  if (passwordError) return passwordError;

  if (body.new_password !== body.confirm_password) {
    return 'Passwords do not match';
  }

  return null;
}
