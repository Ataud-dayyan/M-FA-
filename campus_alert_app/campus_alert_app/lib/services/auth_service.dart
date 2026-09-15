import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

/// Holds the current session in memory and mirrors it to disk so the
/// student stays signed in between app launches.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  AppUser? currentUser;

  Future<void> persistSession(AppUser user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('matricNumber', user.matricNumber);
    await prefs.setString('fullName', user.fullName);
  }

  Future<void> signOut() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    currentUser = AppUser(
      matricNumber: prefs.getString('matricNumber') ?? '',
      fullName: prefs.getString('fullName') ?? '',
      token: token,
    );
    return true;
  }
}
