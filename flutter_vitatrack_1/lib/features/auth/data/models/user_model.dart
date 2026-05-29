import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.tenHienThi,
    super.anhDaiDien,
    required super.ngayTao,
    super.caloMucTieu = 2000,
    super.nuocMucTieu = 8,
    super.canNang,
    super.chieuCao,
  });

  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      tenHienThi: firebaseUser.displayName ?? 'Người dùng',
      anhDaiDien: firebaseUser.photoURL,
      ngayTao: DateTime.now(),
      caloMucTieu: 2000,
      nuocMucTieu: 8,
      canNang: null,
      chieuCao: null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      tenHienThi: data['tenHienThi'] ?? 'Người dùng',
      anhDaiDien: data['anhDaiDien'],
      ngayTao: (data['ngayTao'] as Timestamp).toDate(),
      caloMucTieu: data['caloMucTieu'] ?? 2000,
      nuocMucTieu: data['nuocMucTieu'] ?? 8,
      canNang: data['canNang']?.toDouble(),
      chieuCao: data['chieuCao']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'tenHienThi': tenHienThi,
      'anhDaiDien': anhDaiDien,
      'ngayTao': Timestamp.fromDate(ngayTao),
      'caloMucTieu': caloMucTieu,
      'nuocMucTieu': nuocMucTieu,
      'canNang': canNang,
      'chieuCao': chieuCao,
    };
  }
}
