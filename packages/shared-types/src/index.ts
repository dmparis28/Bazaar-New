// This is the central export file for shared types.

/**
 * A standard wrapper for all API responses.
 * This ensures a consistent response format from all microservices.
 */
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T | null;
  error?: {
    code: string;
    message: string;
  };
}

/**
 * Basic User type.
 * This will be expanded as we build the user-service.
 */
export interface User {
  id: string;
  email: string;
  username: string;
  createdAt: string;
}

// We can add more types here as we build other services
// e.g., Product, Order, PaymentToken, etc.

