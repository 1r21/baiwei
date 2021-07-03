import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'player/player.dart';

import 'util/index.dart';
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
                var data = snapshot.data!;
                var formatTexts = parseText(data.transcript).toList();
                return Stack(
                  children: [
                    textList(formatTexts),
                    actionBtn(data, context),
                  ],
                );
              }

              if (snapshot.hasError) {
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

Widget textList(formatTexts) {
  return ListView.builder(
    padding: const EdgeInsets.all(10),
    itemCount: formatTexts.length,
    itemBuilder: (_, int index) {
      var text = formatTexts[index];
      if (text['type'] == 'title') {
        return Text(text['value'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
      }
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(text['value'], style: const TextStyle(fontSize: 18)),
      );
    },
  );
}

Widget actionBtn(Article data, context) {
  return Positioned(
    bottom: 35,
    right: 35,
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(data.cover),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.play_circle_outlined,
              color: Colors.white,
              size: 30.0,
            ),
            onTap: () async {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return playView(data);
                },
              ));
            },
          ),
          GestureDetector(
            child: Icon(
              Icons.home_outlined,
              color: Colors.orange,
              size: 30.0,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          )
        ],
      ),
    ),
  );
}

Widget playView(data) {
  return Scaffold(
    appBar: AppBar(title: Text(data.date)),
    body: Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(data.cover),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          child: Container(
            padding: EdgeInsetsDirectional.all(20),
            child: Column(
              children: [
                Container(
                    width: 200,
                    height: 200,
                    margin: EdgeInsets.only(top: 60),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(data.cover),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 20),
                  child: Text(
                    data.title,
                    style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Text(
                    data.date,
                    style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
                  ),
                ),
                MyPlayer(data)
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
