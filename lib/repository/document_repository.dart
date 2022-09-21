import 'dart:convert';
import 'dart:html';

import 'package:docs_clone/constants.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider = Provider(
  (ref) => documentRepository(
    client: Client(),
  ),
);

class documentRepository {
  final Client _client;
  documentRepository({required Client client}) : _client = client;

  Future<errorModel> createDocument(String token) async {
    errorModel error = errorModel(
      data: null,
      error: 'Some Unexpected Error occured.',
    );

    try {
      var res = await _client.post(Uri.parse('$host/doc/create'),
          headers: {
            'Content-Type': ' application/json; charset=UTF-8',
            'x-auth-token': token,
          },
          body:
              jsonEncode({'createdAt': DateTime.now().millisecondsSinceEpoch}));
      print(res.statusCode);
      switch (res.statusCode) {
        case 200:
          error = errorModel(
            data: documentModel.fromJson(res.body),
            error: null,
          );
          break;
        default:
          error = errorModel(
            data: null,
            error: res.body,
          );
          break;
      }
    } catch (e) {
      error = errorModel(data: null, error: e.toString());
    }
    return error;
  }

  Future<errorModel> getDocument(String token) async {
    errorModel error = errorModel(
      data: null,
      error: 'Some Unexpected Error occured.',
    );

    try {
      var res = await _client.get(
        Uri.parse('$host/doc/me'),
        headers: {
          'Content-Type': ' application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          List<documentModel> documents = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(
                documentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          error = errorModel(
            data: documents,
            error: null,
          );
          break;
        default:
          error = errorModel(
            data: null,
            error: res.body,
          );
          break;
      }
    } catch (e) {
      error = errorModel(data: null, error: e.toString());
    }
    return error;
  }

  void updateDocument({
    required String token,
    required String id,
    required String title,
  }) async {
      await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': ' application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode(
        {
          'title': title,
          'id': id,
        },
      ),
    );
  }

  Future<errorModel> getDocumentById(String token, String id) async {
    errorModel error = errorModel(
      data: null,
      error: 'Some Unexpected Error occured.',
    );

    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': ' application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          error = errorModel(
            data: documentModel.fromJson(res.body),
            error: null,
          );
          break;
        default: throw 'This Document Does Not Exist';
          error = errorModel(
            data: null,
            error: res.body,
          );
          break;
      }
    } catch (e) {
      error = errorModel(data: null, error: e.toString());
    }
    return error;
  }
}
