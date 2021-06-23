import 'package:flutter/material.dart';
import 'package:baiwei/util/request.dart';

import 'detail.dart';

class Articles extends StatefulWidget {
  @override
  _ArticlesState createState() {
    return _ArticlesState();
  }
}

class _ArticlesState extends State<Articles> {
  late Future<List> futureArticle;

  @override
  void initState() {
    super.initState();
    futureArticle = fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: futureArticle,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (_, int index) {
              var article = Article.fromJson(snapshot.data![index]);
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, DetailScreen.routeName,
                      arguments: DetailArguments(
                          article.id, article.date, article.title));
                },
                child: articleOverview(article),
              );
            },
            separatorBuilder: (_, int index) => const Divider(
              height: 30,
              thickness: 1,
              color: Colors.grey,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container(
          child: Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              height: 60.0,
              width: 60.0,
            ),
          ),
        );
      },
    );
  }
}

Widget articleOverview(Article article) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FadeInImage(
        width: 400,
        height: 200,
        fit: BoxFit.cover,
        placeholder: AssetImage("assets/102.jpeg"),
        image: NetworkImage(article.cover, scale: 1.0),
      ),
      Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Text(
          article.date,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      Text(
        article.title,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
