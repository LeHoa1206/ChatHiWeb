import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user online status
      await updateUserOnlineStatus(result.user!.uid, true);
      
      return result;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await createUserDocument(result.user!, name);
      
      return result;
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument(User user, String name) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      name: name,
      role: 'employee',
      online: true,
      status: 'online',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  // Get user document
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  // Update user online status
  Future<void> updateUserOnlineStatus(String uid, bool online) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'online': online,
        'lastActive': FieldValue.serverTimestamp(),
        'status': online ? 'online' : 'offline',
      });
    } catch (e) {
      print('Lỗi cập nhật trạng thái online: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarUrl,
    String? status,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (status != null) updates['status'] = status;
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật profile: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await updateUserOnlineStatus(currentUser!.uid, false);
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Gửi email reset mật khẩu thất bại: ${e.toString()}');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm người dùng: ${e.toString()}');
    }
  }

  // Get all users (for admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách người dùng: ${e.toString()}');
    }
  }
}