import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';

class MemberMomentsRepository {
  static const _localCommentsKey = 'echelon_member_moments_local';

  final FirebaseFirestore _firestore;

  MemberMomentsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Post>> loadPosts(List<Post> seedPosts) async {
    final cloud = await _loadCloudPosts();
    if (cloud != null) {
      final merged = [...cloud, ...seedPosts];
      _sortPosts(merged);
      return _dedupe(merged);
    }

    final local = await _loadLocalPosts();
    final merged = [...local, ...seedPosts];
    _sortPosts(merged);
    return _dedupe(merged);
  }

  Future<Post> addComment({
    required String comment,
    required String profileImageUrl,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();

    final post = Post(
      id,
      profileImageUrl,
      comment,
      '0',
      createdAtEpochMs: now.millisecondsSinceEpoch,
    );

    final savedCloud = await _saveCloudPost(post);
    if (!savedCloud) {
      await _saveLocalPost(post);
    }

    return post;
  }

  Future<List<Post>?> _loadCloudPosts() async {
    try {
      final snapshot = await _firestore
          .collection('member_moments')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final millis = (data['createdAtEpochMs'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch;
        return Post(
          doc.id,
          data['profileImageUrl'] as String? ??
              'assets/profile_pics/person_kevin.jpeg',
          data['comment'] as String? ?? '',
          _minutesAgoLabel(millis),
          createdAtEpochMs: millis,
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<bool> _saveCloudPost(Post post) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await _firestore.collection('member_moments').add({
        'comment': post.comment,
        'profileImageUrl': post.profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtEpochMs': post.createdAtEpochMs,
        'authorUid': uid,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Post>> _loadLocalPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localCommentsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final posts = decoded
          .whereType<Map>()
          .map((entry) => Post.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
      for (final post in posts) {
        final millis = post.createdAtEpochMs;
        if (millis != null) {
          post.timestamp = _minutesAgoLabel(millis);
        }
      }
      return posts;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalPost(Post post) async {
    final existing = await _loadLocalPosts();
    existing.insert(0, post);
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(existing.map((p) => p.toJson()).toList());
    await prefs.setString(_localCommentsKey, payload);
  }

  static String _minutesAgoLabel(int epochMs) {
    final diffMinutes =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(epochMs));
    final minutes = diffMinutes.inMinutes;
    return minutes <= 0 ? '0' : minutes.toString();
  }

  static void _sortPosts(List<Post> posts) {
    posts.sort((a, b) {
      final aMs = a.createdAtEpochMs ?? 0;
      final bMs = b.createdAtEpochMs ?? 0;
      return bMs.compareTo(aMs);
    });
  }

  static List<Post> _dedupe(List<Post> posts) {
    final seen = <String>{};
    final out = <Post>[];
    for (final post in posts) {
      if (seen.add(post.id)) {
        out.add(post);
      }
    }
    return out;
  }
}

class MemberMomentsManager extends ChangeNotifier {
  MemberMomentsManager({MemberMomentsRepository? repository})
      : _repository = repository ?? MemberMomentsRepository();

  final MemberMomentsRepository _repository;

  final List<Post> _posts = [];
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  List<Post> get posts => List.unmodifiable(_posts);
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  Future<void> load(List<Post> seedPosts) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _repository.loadPosts(seedPosts);
      _posts
        ..clear()
        ..addAll(loaded);
    } catch (_) {
      _error = 'Could not load member comments.';
      _posts
        ..clear()
        ..addAll(seedPosts);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String comment,
    required String profileImageUrl,
  }) async {
    final normalized = comment.trim();
    if (normalized.isEmpty) return;

    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _repository.addComment(
        comment: normalized,
        profileImageUrl: profileImageUrl,
      );
      _posts.insert(0, created);
    } catch (_) {
      _error = 'Could not save comment. Please try again.';
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
