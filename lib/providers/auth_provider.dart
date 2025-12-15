import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        try {
          _userModel = await _authService.getUserDocument(user.uid);
        } catch (e) {
          _error = e.toString();
        }
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(email, password, name);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _error = null;
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    String? status,
  }) async {
    try {
      if (_user == null) return false;
      
      _error = null;
      await _authService.updateUserProfile(
        uid: _user!.uid,
        name: name,
        avatarUrl: avatarUrl,
        status: status,
      );

      // Refresh user model
      _userModel = await _authService.getUserDocument(_user!.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _authService.searchUsers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}