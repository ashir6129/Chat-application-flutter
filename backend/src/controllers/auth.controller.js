import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as authService from '../services/auth.service.js';
import * as authValidator from '../validators/auth.validator.js';

export const register = asyncHandler(async (req, res) => {
  const error = authValidator.validateRegister(req.body);
  if (error) throw new AppError(error, 400);

  const result = await authService.register({
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
  });

  res.status(201).json(result);
});

export const login = asyncHandler(async (req, res) => {
  const error = authValidator.validateLogin(req.body);
  if (error) throw new AppError(error, 400);

  const result = await authService.login({
    email: req.body.email,
    password: req.body.password,
  });

  res.json(result);
});

export const refreshAccessToken = asyncHandler(async (req, res) => {
  const refreshToken = req.body.refresh_token;
  if (!refreshToken) throw new AppError('Refresh token is required', 400);

  const result = await authService.refreshAccessToken(refreshToken);
  res.json(result);
});

export const forgotPassword = asyncHandler(async (req, res) => {
  const error = authValidator.validateForgotPassword(req.body);
  if (error) throw new AppError(error, 400);

  const result = await authService.forgotPassword({ email: req.body.email });
  res.json(result);
});

export const resendOtp = asyncHandler(async (req, res) => {
  const error = authValidator.validateResendOtp(req.body);
  if (error) throw new AppError(error, 400);

  const result = await authService.resendOtp({
    email: req.body.email,
    resetToken: req.body.reset_token,
  });

  res.json(result);
});

export const verifyRegistration = asyncHandler(async (req, res) => {
  const error = authValidator.validateResendOtp(req.body);
  if (error) throw new AppError(error, 400);
  if (!req.body.otp) throw new AppError('OTP is required', 400);

  const result = await authService.verifyRegistration({
    email: req.body.email,
    otp: req.body.otp,
    resetToken: req.body.reset_token,
  });

  res.json(result);
});

export const verifyOtp = asyncHandler(async (req, res) => {
  const error = authValidator.validateResendOtp(req.body);
  if (error) throw new AppError(error, 400);
  if (!req.body.otp) throw new AppError('OTP is required', 400);

  const result = await authService.verifyOtpOnly({
    email: req.body.email,
    otp: req.body.otp,
    resetToken: req.body.reset_token,
  });

  res.json(result);
});

export const resetPassword = asyncHandler(async (req, res) => {
  const error = authValidator.validateResetPassword(req.body);
  if (error) throw new AppError(error, 400);

  const result = await authService.resetPassword({
    email: req.body.email,
    otp: req.body.otp,
    resetToken: req.body.reset_token,
    newPassword: req.body.new_password,
  });

  res.json(result);
});

export const logout = asyncHandler(async (req, res) => {
  const result = await authService.logout(req.user.sub, req.body.refresh_token);
  res.json(result);
});

export const loginGoogle = asyncHandler(async (req, res) => {
  const result = await authService.loginWithGoogle({ idToken: req.body.id_token });
  res.json(result);
});

export const loginApple = asyncHandler(async (req, res) => {
  const result = await authService.loginWithApple({
    idToken: req.body.id_token,
    name: req.body.name,
  });
  res.json(result);
});
