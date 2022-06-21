import 'package:baiwei/thumb.dart';
import 'package:flutter/material.dart';
import 'package:baiwei/util/request.dart';

import 'detail.dart';

class Home extends StatefulWidget {
  static const routeName = '/';

  @override
  _Home createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  late Future<List> _futureArticles;

  @override
  void initState() {
    super.initState();
    _futureArticles = fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: FutureBuilder<List>(
          future: _futureArticles,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, int index) {
                  var article = Article.fromJson(snapshot.data![index]);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Detail.routeName,
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
        ));
  }
}
