import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/account_service.dart';

/// The signed-in user, or null when nobody is signed in.
final accountUserProvider = StreamProvider<User?>(
  (ref) => AccountService.instance.userChanges,
);
