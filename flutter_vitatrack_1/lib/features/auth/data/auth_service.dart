import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vitatrack_1/features/auth/data/models/user_model.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserEntity?> get luongNguoiDung {
    return _auth.authStateChanges().map((user) =>
        user != null ? UserModel.fromFirebaseUser(user) : null);
  }

  UserEntity? get nguoiDungHienTai {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  Future<UserEntity?> dangNhapEmail(String email, String matKhau) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: matKhau,
      );
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email không tồn tại');
        case 'wrong-password':
          throw Exception('Mật khẩu không đúng');
        case 'invalid-credential':
          throw Exception('Email hoặc mật khẩu không đúng');
        default:
          throw Exception('Đăng nhập thất bại: ${e.message}');
      }
    }
  }

  Future<UserEntity?> dangKyEmail(
      String email, String matKhau, String tenHienThi) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: matKhau,
      );
      await result.user!.updateDisplayName(tenHienThi);
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email đã được sử dụng');
        case 'weak-password':
          throw Exception('Mật khẩu quá yếu (tối thiểu 6 ký tự)');
        default:
          throw Exception('Đăng ký thất bại: ${e.message}');
      }
    }
  }

  Future<void> dangXuat() async {
    await _auth.signOut();
  }

  Future<void> quenMatKhau(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email không tồn tại');
        case 'invalid-email':
          throw Exception('Email không hợp lệ');
        default:
          throw Exception('Gửi email đặt lại mật khẩu thất bại: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi gửi email: $e');
    }
  }

  Future<bool> daHoanThanhOnboarding(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['onboardingDone'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteAccount(String uid) async {
    try {
      // 1. Delete all Firestore data for this user
      final firestore = FirebaseFirestore.instance;
      
      // Delete subcollections first (Firestore doesn't auto-delete subcollections)
      final collections = ['profile', 'nutrition', 'workouts'];
      for (final col in collections) {
        final snapshot = await firestore
            .collection('users').doc(uid)
            .collection(col).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      
      // Delete the user document itself
      await firestore.collection('users').doc(uid).delete();
      
      // 2. Delete Firebase Auth account
      final user = _auth.currentUser;
      if (user == null) throw Exception('Không tìm thấy tài khoản');
      await user.delete();
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Vui lòng đăng xuất và đăng nhập lại trước khi xóa tài khoản'
        );
      }
      throw Exception('Lỗi xóa tài khoản: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi xóa tài khoản: $e');
    }
  }
}