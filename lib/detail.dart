import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

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
                    playButton(data, context),
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

  ListView textList(formatTexts) => ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: formatTexts.length,
        itemBuilder: (_, int index) {
          var text = formatTexts[index];
          if (text['type'] == 'title') {
            return Text(text['value'] as String,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
          }
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(text['value'], style: const TextStyle(fontSize: 18)),
          );
        },
      );

  Positioned playButton(Article data, context) => Positioned(
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
                onTap: () {
                  if (AudioService.currentMediaItem?.id != data.src) {
                    AudioService.stop();
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return Material(
                        child: playView(data, context),
                      );
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

  Widget playView(Article data, BuildContext context) {
    double pOffset = Platform.isAndroid ? 20 : 50;
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
          top: Platform.isAndroid ? 30 : 50,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_downward_outlined),
                    color: Colors.white,
                    iconSize: 30.0,
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
                Container(
                    width: 200,
                    height: 200,
                    margin: EdgeInsets.only(
                        top: 10, bottom: Platform.isAndroid ? 40 : 60),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(data.cover),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    )),
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, bottom: pOffset),
                    child: Text(
                      data.date,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    )),
                MyPlayer(data)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DetailArguments {
  final int id;
  final String date;
  final String title;

  DetailArguments(this.id, this.date, this.title);
}
