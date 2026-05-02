class ApiConstants {
  static const String baseUrl =
      'https://backend-node-js-xqas.onrender.com/api/v1';

  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String refreshTokenPath = '/auth/refresh-token';
  static const String logoutPath = '/auth/logout';
  static const String forgotPasswordPath = '/auth/forgot-password';

  static const String extractMedicinesPath = '/scan/extract-medicines';
  static const String nearbyPharmaciesPath = '/pharmacies/nearby';

  static const String prescriptionsByUserPath = '/prescriptions/user';
}
