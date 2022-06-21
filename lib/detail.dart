import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:baiwei/player/background_player.dart';
import 'package:flutter/material.dart';

import 'util/index.dart';
import 'util/request.dart';

class Detail extends StatefulWidget {
  static const routeName = '/detail';
  final AudioPlayerHandler _audioHandler;
  Detail(this._audioHandler);

  @override
  _Detail createState() {
    return _Detail(_audioHandler);
  }
}

class _Detail extends State<Detail> {
  late Future<Article> _futureArticle;
  late AudioPlayerHandler _audioHandler;

  _Detail(this._audioHandler);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as DetailArguments;
    _futureArticle = fetchArticleById(args.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(args.date),
      ),
      body: Center(
        child: FutureBuilder<Article>(
            future: _futureArticle,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;
                var formatTexts = parseText(data.transcript).toList();
                if (formatTexts.length > 0) {
                  var _item = MediaItem(
                      id: data.src,
                      title: data.title,
                      artUri: Uri.parse(data.cover),
                      album: data.date,
                      duration: Duration.zero);

                  _audioHandler.init(_item);

                  return Stack(
                    children: [
                      textList(formatTexts),
                      playButton(data, context, _audioHandler),
                    ],
                  );
                }
                return Text("Not prepare yet.");
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

  Positioned playButton(
          Article data, context, AudioPlayerHandler _audioHandler) =>
      Positioned(
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
                  Navigator.of(context).push(MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return Material(
                        child: playView(data, context, _audioHandler),
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

  Widget playView(
      Article data, BuildContext context, AudioPlayerHandler _audioHandler) {
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
                Text(
                  data.date,
                  style: TextStyle(color: Colors.white),
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
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: pOffset),
                ),
                BackgroundPlayer(_audioHandler)
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
