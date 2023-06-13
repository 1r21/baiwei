import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/article.dart';
import '../util/util.dart';
import '../util/request.dart';

String baseURI = '${dotenv.env['API_URL']!}/api';

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
