import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String baseURI = '${dotenv.env['API_URL']!}/api';

class Api {
  final int code;
  final Map<String, dynamic>? data;
  final String message;

  Api({required this.code, required this.data, required this.message});

  factory Api.fromJson(Map<String, dynamic> json) {
    if (json case {'code': int code, "message": String message}) {
      return Api(code: code, data: json["data"], message: message);
    }
    log(jsonEncode(json));
    throw const FormatException('Unexpected JSON format for Api');
  }
}

class BWClient extends http.BaseClient {
  final _client = http.Client();

  Future fetch(String url,
      {String method = 'get', Map<String, String>? body}) async {
    try {
      var request = http.Request(method, Uri.parse('$baseURI$url'));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      var streamedResponse = await send(request);
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var map = jsonDecode(response.body);
        var Api(:code, :data, :message) = Api.fromJson(map);

        if (code == 0) {
          return data;
        }
        throw Exception(message);
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      throw Exception('send request failed.');
    } finally {
      _client.close();
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _client.send(request);
  }
}
