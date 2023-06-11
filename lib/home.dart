import 'package:baiwei/thumb.dart';
import 'package:flutter/material.dart';
import 'package:baiwei/util/request.dart';

import 'detail.dart';

class Home extends StatefulWidget {
  static const routeName = '/';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Pager> futureArticles;

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
        body: FutureBuilder<Pager>(
          future: futureArticles,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              var list = snapshot.data!.list;
              return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: list.length,
                itemBuilder: (_, int index) {
                  var article = Article.fromJson(list[index]);
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
