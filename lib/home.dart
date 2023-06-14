import 'package:baiwei/service/article.dart';
import 'package:baiwei/thumb.dart';
import 'package:baiwei/util/util.dart';
import 'package:flutter/material.dart';

import 'detail.dart';
import 'model/article.dart';

class Home extends StatefulWidget {
  static const routeName = '/';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Pager<Article>> futureArticles;

  @override
  void initState() {
    super.initState();
    futureArticles = fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: FutureBuilder<Pager<Article>>(
          future: futureArticles,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              var list = snapshot.data!.list;
              return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: list.length,
                itemBuilder: (_, int index) {
                  var article = list[index];
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
            return const Center(
              child: SizedBox(
                height: 60.0,
                width: 60.0,
                child: CircularProgressIndicator(),
              ),
            );
          },
        ));
  }
}
