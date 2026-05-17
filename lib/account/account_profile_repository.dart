import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatarState {
  ProfileAvatarState({
    this.cloudUrl,
    this.localBytes,
  });

  final String? cloudUrl;
  final Uint8List? localBytes;
}

class AccountProfileRepository {
  static const _avatarPathKey = 'echelon_profile_avatar_path';
  static const _avatarBytesKey = 'echelon_profile_avatar_bytes';

  Future<ProfileAvatarState> loadAvatar() async {
    final cloudUrl = await _loadCloudAvatar();
    if (cloudUrl != null && cloudUrl.isNotEmpty) {
      return ProfileAvatarState(cloudUrl: cloudUrl);
    }

    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_avatarPathKey);
    if (path != null && path.isNotEmpty) {
      return ProfileAvatarState(cloudUrl: path);
    }

    final base64Bytes = prefs.getString(_avatarBytesKey);
    if (base64Bytes == null || base64Bytes.isEmpty) {
      return ProfileAvatarState();
    }

    try {
      return ProfileAvatarState(localBytes: base64Decode(base64Bytes));
    } catch (_) {
      return ProfileAvatarState();
    }
  }

  Future<void> saveAvatarPath(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPathKey, avatarPath);
    await prefs.remove(_avatarBytesKey);
    await _saveCloudAvatar(avatarPath);
  }

  Future<void> saveAvatarBytes(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarBytesKey, base64Encode(bytes));

    final uploadedUrl = await _uploadAvatarToCloud(bytes);
    if (uploadedUrl != null) {
      await prefs.setString(_avatarPathKey, uploadedUrl);
      await prefs.remove(_avatarBytesKey);
      await _saveCloudAvatar(uploadedUrl);
    }
  }

  Future<String?> _loadCloudAvatar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('account')
          .get();

      return doc.data()?['avatarPath'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCloudAvatar(String avatarPath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('account')
          .set({
        'avatarPath': avatarPath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Keep local avatar persistence as fallback.
    }
  }

  Future<String?> _uploadAvatarToCloud(Uint8List bytes) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile')
          .child('avatar.jpg');

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

class BillingState {
  BillingState({
    required this.credits,
    required this.paymentMethods,
  });

  final double credits;
  final List<String> paymentMethods;

  factory BillingState.fromJson(Map<String, dynamic> json) {
    final methods = (json['paymentMethods'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList();

    return BillingState(
      credits: (json['credits'] as num?)?.toDouble() ?? 0,
      paymentMethods: methods,
    );
  }

  Map<String, dynamic> toJson() => {
        'credits': credits,
        'paymentMethods': paymentMethods,
      };
}

class BillingRepository {
  static const _billingKey = 'echelon_billing_state';

  Future<BillingState> loadBilling() async {
    final cloud = await _loadCloudBilling();
    if (cloud != null) {
      return cloud;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_billingKey);
    if (raw == null || raw.isEmpty) {
      return BillingState(credits: 0, paymentMethods: const []);
    }

    try {
      return BillingState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return BillingState(credits: 0, paymentMethods: const []);
    }
  }

  Future<void> saveBilling(BillingState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_billingKey, jsonEncode(state.toJson()));
    await _saveCloudBilling(state);
  }

  Future<BillingState?> _loadCloudBilling() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('billing')
          .doc('account')
          .get();

      final data = doc.data();
      if (data == null) return null;
      return BillingState.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCloudBilling(BillingState state) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('billing')
          .doc('account')
          .set({
        ...state.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Keep local billing persistence as fallback.
    }
  }
}
