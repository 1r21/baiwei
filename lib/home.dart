import 'package:baiwei/thumb.dart';
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
