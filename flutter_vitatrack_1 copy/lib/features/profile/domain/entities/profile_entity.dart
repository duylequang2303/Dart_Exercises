import 'package:flutter/foundation.dart';

@immutable
class ProfileEntity {
  final String uid;
  final String ten;
  final String email;
  final int? tuoi;
  final double? chieuCao;
  final double? canNang;
  final String? gioiTinh;
  final String? mucTieu;
  final String? cuongDo;
  final bool? onboardingDone;

  const ProfileEntity({
    required this.uid,
    required this.ten,
    required this.email,
    this.tuoi,
    this.chieuCao,
    this.canNang,
    this.gioiTinh,
    this.mucTieu,
    this.cuongDo,
    this.onboardingDone,
  });

  ProfileEntity copyWith({
    String? uid,
    String? ten,
    String? email,
    int? tuoi,
    double? chieuCao,
    double? canNang,
    String? gioiTinh,
    String? mucTieu,
    String? cuongDo,
    bool? onboardingDone,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      ten: ten ?? this.ten,
      email: email ?? this.email,
      tuoi: tuoi ?? this.tuoi,
      chieuCao: chieuCao ?? this.chieuCao,
      canNang: canNang ?? this.canNang,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      mucTieu: mucTieu ?? this.mucTieu,
      cuongDo: cuongDo ?? this.cuongDo,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  factory ProfileEntity.fromMap(String uid, String email, Map<String, dynamic> map) {
    return ProfileEntity(
      uid: uid,
      email: email,
      ten: map['ten'] ?? '',
      tuoi: map['tuoi']?.toInt(),
      chieuCao: map['chieuCao']?.toDouble(),
      canNang: map['canNang']?.toDouble(),
      gioiTinh: map['gioiTinh'],
      mucTieu: map['mucTieu'],
      cuongDo: map['cuongDo'],
      onboardingDone: map['onboardingDone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ten': ten,
      'tuoi': tuoi,
      'chieuCao': chieuCao,
      'canNang': canNang,
      'gioiTinh': gioiTinh,
      'mucTieu': mucTieu,
      'cuongDo': cuongDo,
      'onboardingDone': onboardingDone,
    };
  }
}
