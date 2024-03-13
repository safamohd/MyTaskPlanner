import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_task_planner/models/user.dart';
import 'package:my_task_planner/services/database_service.dart';

class AuthService with ChangeNotifier {
  static const TAG = "AuthService:";

  final _auth = FirebaseAuth.instance;
  final _dbService = new DBService();

  MyUser _myUser;

  bool _isLoading = false;
  bool _isLoggedIn = false;

  AuthService() {
    init();
  }

  void init() async {
    isLoading = false;
    isLoggedIn = _auth?.currentUser != null;
    if (_isLoggedIn) myUser = await _dbService.getUserData(_auth?.currentUser);
  }

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _isLoggedIn;

  MyUser get myUser => _myUser;

  Stream<User> get authStateChanges {
    return _auth.authStateChanges();
  }

  set isLoading(bool isLoading) {
    this._isLoading = isLoading;
    notifyListeners();
  }

  set isLoggedIn(bool isLoggedIn) {
    this._isLoggedIn = isLoggedIn;
    notifyListeners();
  }

  set myUser(MyUser user) {
    print('$TAG myUser: assigning new user ${user.toJson()}');
    this._myUser = user;
    notifyListeners();
  }

  Future<MyUser> signUpWithEmailAndPassword(String name, String email, String gender, String password) async {
    isLoading = true;
    try {
      print('$TAG creating account for $email $name ...');
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        print('$TAG created account successfully');

        //create new user to push their data to the server
        final _myUser = MyUser(id: _auth.currentUser.uid, name: name, email: email, gender: gender);
        // myUser = _myUser;

        //open new session using the credentials above
        print('$TAG opening new session with user ${_auth.currentUser?.uid} ..');
        await _auth.signInWithEmailAndPassword(email: email, password: password);

        print('$TAG adding user to db ${_myUser.toJson()}');
        await _dbService.createNewUser(_myUser);

        print('$TAG getting user data from db for ${_auth.currentUser?.uid}');
        myUser = await _dbService.getUserData(userCredential.user) ?? _myUser;
        isLoggedIn = _auth.currentUser != null;
        return myUser;
      }
      return Future.value(null);
    } on FirebaseAuthException catch (e) {
      print('$TAG $e');
      return Future.error(e.message);
    } catch (e) {
      print('$TAG $e');
      return Future.error(e);
    } finally {
      isLoading = false;
      isLoggedIn = _auth.currentUser != null;
    }
  }

  Future<MyUser> signInWithEmailAndPassword(String email, String password) async {
    isLoading = true;
    try {
      print('$TAG signing in as $email ...');
      // create new user credential to request new login session
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // if the returned credential has user data thus the login session started successfully
        print('$TAG logged in successfully');
        final user = await _dbService.getUserData(userCredential.user);
        if (user != null) myUser = user;
        isLoggedIn = _auth.currentUser != null;
        return myUser;
      }
      // the credential returned null login session failed
      print('$TAG login failed');
      return Future.value(null);
      // handle any possible exception
    } on FirebaseAuthException catch (e) {
      print('$TAG $e');
      return Future.error(e.message);
    } catch (e) {
      print('$TAG $e');
      return Future.error(e);
    } finally {
      isLoading = false;
      isLoggedIn = _auth.currentUser != null;
    }
  }

  Future<void> resetPassword(String email) {
    try {
      print("$TAG sending password reset email to $email");
      return _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("$TAG $e");
      return Future.error(e.message);
    } catch (e) {
      print("$TAG $e");
      return Future.error(e);
    }
  }

  Future<void> logout() async {
    try {
      print('$TAG logging out..');
      await _auth.signOut();
      _myUser = null;
      isLoggedIn = false;
      notifyListeners();
      print('$TAG logged out successfully');
    } catch (e) {
      print('$TAG $e');
      throw Future.error(e);
    }
  }
}
