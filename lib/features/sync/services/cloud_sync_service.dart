import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/sync_snapshot.dart';

/// Reads and writes the user's backup in Firestore.
///
/// One small document per user: `users/{uid}/backup/main`. The snapshot is
/// stored as a single JSON string, so key names and number types are kept
/// exactly and Firestore's field-name rules never get in the way.
class CloudSyncService {
  CloudSyncService([FirebaseFirestore? db])
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// A Firestore document is limited to 1 MiB; stay well under it.
  static const int maxJsonLength = 900 * 1024;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('backup').doc('main');

  /// The saved backup, or null when the account has none yet.
  Future<SyncSnapshot?> download(String uid) async {
    // From the server only: offline, the saved copy on the phone would look
    // like a success and the upload after it would wait for the network.
    final doc = await _doc(uid).get(const GetOptions(source: Source.server));
    final data = doc.data();
    final raw = data?['json'];
    if (raw is! String) return null;
    try {
      return SyncSnapshot.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upload(String uid, SyncSnapshot snapshot) async {
    final encoded = json.encode(snapshot.toJson());
    if (encoded.length > maxJsonLength) {
      throw StateError('Backup is too large to store');
    }
    await _doc(uid).set({
      'json': encoded,
      'schemaVersion': snapshot.schemaVersion,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// A readable summary of the account, kept next to the backup so it can be
  /// browsed in the Firebase console: who the user is, where they are (only
  /// if the app already knew), and which app version they use. Fields the
  /// phone does not have are left out and keep their earlier value.
  Future<void> saveProfile(
    User user, {
    SyncLocation? location,
    String? appVersion,
  }) async {
    final data = <String, Object?>{
      if (user.displayName != null) 'displayName': user.displayName,
      if (user.email != null) 'email': user.email,
      if (user.photoURL != null) 'photoUrl': user.photoURL,
      if (user.metadata.creationTime != null)
        'joinedAt': Timestamp.fromDate(user.metadata.creationTime!),
      if (user.providerData.isNotEmpty)
        'signInProvider': user.providerData.first.providerId,
      'platform': defaultTargetPlatform.name,
      if (appVersion != null) 'appVersion': appVersion,
      if (location != null) ...{
        'latitude': location.latitude,
        'longitude': location.longitude,
        if (location.city != null) 'city': location.city,
        if (location.district != null) 'district': location.district,
      },
      'lastSyncAt': FieldValue.serverTimestamp(),
    };
    await _db
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  /// Removes everything stored for [uid].
  Future<void> deleteAll(String uid) async {
    await _doc(uid).delete();
    await _db.collection('users').doc(uid).delete();
  }
}
