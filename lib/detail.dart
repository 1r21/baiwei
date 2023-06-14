import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:baiwei/player/background_player.dart';
import 'package:baiwei/service/article.dart';
import 'package:flutter/material.dart';

import 'model/article.dart';
import 'util/util.dart';

class Detail extends StatefulWidget {
  static const routeName = '/detail';
  final AudioPlayerHandler audioPlayerHandler;

  const Detail(this.audioPlayerHandler, {super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late Future<Article> futureArticle;

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
                var article = snapshot.data!;
                var formatTexts = parseText(article.transcript).toList();
                if (formatTexts.isNotEmpty) {
                  var item = MediaItem(
                      id: article.src,
                      title: article.title,
                      artUri: Uri.parse(article.cover),
                      album: article.date,
                      duration: Duration.zero);

                  widget.audioPlayerHandler.init(item);

                  return Stack(
                    children: [
                      textList(formatTexts),
                      playButton(article, context, widget.audioPlayerHandler),
                    ],
                  );
                }
                return const Text("Not prepare yet.");
              }

              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return const Center(
                child: SizedBox(
                  height: 60.0,
                  width: 60.0,
                  child: CircularProgressIndicator(),
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

  Positioned playButton(
          Article data, context, AudioPlayerHandler audioHandler) =>
      Positioned(
        bottom: 35,
        right: 35,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(data.cover),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            children: [
              GestureDetector(
                child: const Icon(
                  Icons.play_circle_outlined,
                  color: Colors.white,
                  size: 30.0,
                ),
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return Material(
                        child: playView(data, context, audioHandler),
                      );
                    },
                  ));
                },
              ),
              GestureDetector(
                child: const Icon(
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

  Widget playView(
      Article data, BuildContext context, AudioPlayerHandler audioHandler) {
    double pOffset = Platform.isAndroid || Platform.isMacOS ? 20 : 50;
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
          top: Platform.isAndroid || Platform.isMacOS ? 30 : 50,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_downward_outlined),
                    color: Colors.white,
                    iconSize: 30.0,
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
                Text(
                  data.date,
                  style: const TextStyle(color: Colors.white),
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
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: pOffset),
                ),
                BackgroundPlayer(audioHandler)
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
