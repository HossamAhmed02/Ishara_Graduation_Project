class ApiConstants {
  static const String baseUrl = 'http://ishara-api.runasp.net';
  static const String register = '/api/Auth/Register';
  static const String verifyRegisterOtp = '/api/Auth/VerifyRegisterOtp';
  static const String login = '/api/Auth/Login';
  static const String forgotPassword = '/api/Auth/ForgotPassword';
  static const String verifyResetPasswordOtp =
      '/api/Auth/VerifyResetPasswordOTP';
  static const String resetPassword = '/api/Auth/ResetPassword';
  static const String refreshToken = '/api/Auth/RefreshToken';
  static const String logout = '/api/Auth/logout';

  static const String getMyContacts = '/api/Contacts/GetMyContacts';
  static const String searchContacts = '/api/Contacts/search';
  static const String addContact = '/api/Contacts/AddContact';
  static const String deleteContact = '/api/Contacts/DeleteContact';

  static const String getProfile = '/api/Auth/Profile';
  static const String updateProfile = '/api/Auth/UpdateProfile';
}
