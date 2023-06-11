import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseURI = '${dotenv.env['API_URL']!}/api';

class Pager<T> {
  final int total;
  final int page;
  final int pageSize;
  final List<T> list;

  Pager(this.list, this.total, this.page, this.pageSize);

  Pager.fromJson(Map<String, dynamic> json)
      : this(json["list"] as List<T>, json['total'], json['page'],
            json['pageSize']);
}

class Api<T> {
  final int code;
  final T data;
  final String message;

  Api({required this.code, required this.data, required this.message});

  Api.fromJson(Map<String, dynamic> json)
      : this(code: json['code'], data: json['data'], message: json['message']);
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

  Article.fromJson(Map<String, dynamic> json)
      : this(
            id: json['id'],
            cover: json['cover'],
            date: json['date'],
            title: json['title'],
            src: json['src'] ?? "",
            transcript: json['transcript'] ?? "");

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "cover": cover,
      "date": date,
      "title": title,
      "src": src,
      "transcript": transcript
    };
  }
}

Future<Pager> fetchArticles() async {
  var uri = Uri.parse('$baseURI/news');
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    var map = jsonDecode(response.body);
    var Api(:code, :data, :message) = Api.fromJson(map);

    if (code == 0) {
      return Pager.fromJson(data);
    }
    throw Exception(message);
  } else {
    throw Exception('Failed to load article');
  }
}

Future<Article> fetchArticleById(int id) async {
  var uri = Uri.parse('$baseURI/news/detail');
  try {
    final response =
        await http.post(uri, body: jsonEncode({"id": id.toString()}));

    if (response.statusCode == 200) {
      var api = Api.fromJson(jsonDecode(response.body));
      log(api.message);
      return Article.fromJson({...api.data, "id": id});
    } else {
      throw Exception('Failed to load article');
    }
  } catch (e) {
    throw Exception(e);
  }
}
