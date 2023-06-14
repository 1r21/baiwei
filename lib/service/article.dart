import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/article.dart';
import '../util/util.dart';
import '../util/request.dart';

String baseURI = '${dotenv.env['API_URL']!}/api';

Future<Pager<Article>> fetchArticles() async {
  var bwClient = BWClient();
  var data = await bwClient.fetch('/news');
  return Pager.fromJson({
    ...data,
    "list": [for (var item in data["list"]) Article.fromJson(item)]
  });
}

Future<Article> fetchArticleById(int id) async {
  var bwClient = BWClient();
  var data = await bwClient
      .fetch('/news/detail', method: 'post', body: {"id": id.toString()});
  return Article.fromJson({...data, "id": id});
}
