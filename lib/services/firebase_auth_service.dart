import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/models/enums.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Firestore
        final userData = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userData.exists) {
          return User.fromJson({
            'id': credential.user!.uid,
            ...userData.data()!,
          });
        }
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat login';
    }
  }

  // Register with email and password only (simplified)
  Future<User?> registerSimple({
    required String email,
    required String password,
  }) async {
    firebase_auth.UserCredential? credential;
    try {
      // Create Firebase Auth user
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create basic user document in Firestore (without name/role)
        final user = User(
          id: credential.user!.uid,
          name: 'User', // Default name, will be updated in profile
          email: email,
          role: UserRole.mahasiswa, // Default role, will be updated in profile
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());

        return user;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Delete user if Firestore creation fails
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      throw _handleAuthException(e);
    } catch (e) {
      // Delete user if Firestore creation fails
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      throw 'Terjadi kesalahan saat registrasi';
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? nim,
    String? nip,
    String? phone,
  }) async {
    firebase_auth.UserCredential? credential;
    try {
      // Create Firebase Auth user
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user document in Firestore
        final user = User(
          id: credential.user!.uid,
          name: name,
          email: email,
          role: role,
          nim: nim,
          nip: nip,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());

        return user;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Delete user if Firestore creation fails
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      throw _handleAuthException(e);
    } catch (e) {
      // Delete user if Firestore creation fails
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      throw 'Terjadi kesalahan saat registrasi';
    }
  }

  // Get current user data
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userData = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userData.exists) {
        return User.fromJson({
          'id': firebaseUser.uid,
          ...userData.data()!,
        });
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatarUrl,
    String? nip,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (nip != null) updates['nip'] = nip;

      if (updates.isEmpty) {
        return;
      }

      await _firestore.collection('users').doc(userId).update(updates);

      // Update Firebase Auth display name if name changed
      if (name != null && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(name);
        await _auth.currentUser!.reload();
      }
    } catch (e) {
      throw 'Gagal memperbarui profil: $e';
    }
  }

  // Update user password (Admin only)
  Future<void> updateUserPassword(String email, String newPassword) async {
    try {
      // Find user by email and update their password
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        
        // Note: Firebase Admin SDK would be needed for proper password updates
        // For now, we'll store password in Firestore (should be hashed in production)
        await _firestore.collection('users').doc(userDoc.id).update({
          'password': newPassword,
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        // If this is the current user, update their Firebase Auth password
        if (_auth.currentUser != null && _auth.currentUser!.email == email) {
          await _auth.currentUser!.updatePassword(newPassword);
        }
      } else {
        throw 'User dengan email $email tidak ditemukan';
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal memperbarui password: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal mengirim email reset password';
    }
  }

  // Delete account
  Future<void> deleteAccount(String userId) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete Firebase Auth user
      await _auth.currentUser?.delete();
    } catch (e) {
      throw 'Gagal menghapus akun';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  // Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Gagal mengirim email verifikasi';
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
