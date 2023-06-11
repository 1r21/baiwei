import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:baiwei/player/background_player.dart';
import 'package:baiwei/home.dart';
import 'detail.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  var audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(BaiweiApp(audioHandler));
}

class BaiweiApp extends StatelessWidget {
  final AudioPlayerHandler _audioHandler;

  const BaiweiApp(this._audioHandler, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baiwei',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      initialRoute: Home.routeName,
      routes: {
        Home.routeName: (contet1) => const Home(),
        Detail.routeName: (context) => Detail(_audioHandler)
      },
    );
  }
}
