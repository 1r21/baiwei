import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseURI = '${dotenv.env['API_URL']!}/api';

class Api {
  final int code;
  final dynamic data;
  final String message;

  Api({required this.code, required this.data, required this.message});

  factory Api.fromJson(Map<String, dynamic> json) {
    return Api(
        code: json['code'], data: json['data'], message: json['message']);
  }
}

class Article {
  final int id;
  final String cover;
  final String date;
  final String title;
  final String transcript;
  final String src;

  Article(
      {required this.id,
      required this.cover,
      required this.date,
      required this.title,
      this.transcript = '',
      this.src = ''});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      cover: json['cover'],
      date: json['date'],
      title: json['title'],
      src: json['src'] ?? '',
      transcript: json['transcript'] ?? '',
    );
  }
}

Future<List> fetchArticle() async {
  final response = await http.get(Uri.parse('$baseURI/news'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Api api = Api.fromJson(jsonDecode(response.body));
    return api.data['list'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load article');
  }
}

Future<Article> fetchArticleById(int id) async {
  var uri = Uri.parse('$baseURI/news/detail');
  try {
    final response =
        await http.post(uri, body: jsonEncode({"id": id.toString()}));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Api api = Api.fromJson(jsonDecode(response.body));
      return Article.fromJson({...api.data, "id": id});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load article');
    }
  } catch (e) {
    throw Exception(e);
  }
}
