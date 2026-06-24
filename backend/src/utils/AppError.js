export class AppError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'AppError';
  }
}

export function assertValid(condition, message, statusCode = 400) {
  if (!condition) {
    throw new AppError(message, statusCode);
  }
}
