import 'dart:convert';
import 'dart:developer';
import 'package:docs_clone/constants.dart';
import 'package:docs_clone/models/user_models.dart';
import 'package:docs_clone/repository/local_storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../models/error_models.dart';

final AuthRepositoryProvider = Provider((ref) => AuthRepository(
      googleSignIn: GoogleSignIn(),
      client: Client(),
      localStorage: LocalStorage(),
    ));

final userProvider = StateProvider<userModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorage _localStorage;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorage localStorage,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorage = localStorage;

  Future<errorModel> signWithGoogle() async {
    errorModel error = errorModel(
      data: null,
      error: 'Some Unexpected Error Occured',
    );
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final useracc = userModel(
          name: user.displayName ?? '',
          email: user.email,
          uid: '',
          token: '',
        );
        var res = await _client.post(Uri.parse('$host/api/signup'),
            body: useracc.toJson(),
            headers: {'Content-Type': 'application/json; charset=UTF-8'});
        // print(res.statusCode);
        switch (res.statusCode) {
          case 200:
            final newUser = useracc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            error = errorModel(
              data: newUser,
              error: null,
            );
            _localStorage.setToken(newUser.token);
          break;  
        }
        log('$user.displayName');
        print('$user.email');
      }
    } catch (e) {
      error = errorModel(
        data: null,
        error: e.toString(),
      );
      print('$e');
    }
    return error;
  }

  Future<errorModel> getUserData() async {
    errorModel error = errorModel(
      data: null,
      error: 'Some Unexpected Error Occured',
    );
    try {
      String? token = await _localStorage.getToken();
      print(token);
      if (token != null) {
        var res = await _client.get(
          Uri.parse('$host/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        print(res.statusCode);
        switch (res.statusCode) {
          case 200:
            final newUser = userModel
                    .fromJson(
                      jsonEncode(
                        jsonDecode(res.body)['user'],
                      ),
                    ).copyWith(token: token);
                error = errorModel(
                  data: newUser,
                  error: null,
                );
            _localStorage.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = errorModel(
        data: null,
        error: e.toString(),
      );
      print(e);
    }
    return error;
  }
  void siqnedOut() async {
    
    _localStorage.setToken('');
  }
}
