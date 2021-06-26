import 'package:baiwei/util/index.dart';
import 'package:flutter/material.dart';
import 'util/request.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detail';
  @override
  _DetailScreen createState() {
    return _DetailScreen();
  }
}

class _DetailScreen extends State<DetailScreen> {
  late Future<Article> futureArticle;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as DetailArguments;
    futureArticle = fetchArticleById(args.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(args.date),
      ),
      body: Center(
        child: FutureBuilder<Article>(
            future: futureArticle,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var formatTexts = parseText(snapshot.data!.transcript).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: formatTexts.length,
                  itemBuilder: (_, int index) {
                    var text = formatTexts[index];
                    if (text['type'] == 'title') {
                      return Text(text['value'] as String,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold));
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(text['value'] as String,
                          style: const TextStyle(fontSize: 18)),
                    );
                  },
                );
                // return Text(snapshot.data!.date);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return Container(
                child: Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 60.0,
                    width: 60.0,
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class DetailArguments {
  final int id;
  final String date;
  final String title;

  DetailArguments(this.id, this.date, this.title);
}