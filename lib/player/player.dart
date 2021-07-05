import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import 'seekbar.dart';
import '../util/request.dart';
import '../player/playerTask.dart';

class MyPlayer extends StatefulWidget {
  MyPlayer(this.article);

  final Article article;

  @override
  _MyPlayerState createState() {
    return _MyPlayerState(article);
  }
}

class _MyPlayerState extends State<MyPlayer> {
  final Article article;

  _MyPlayerState(this.article);

  @override
  void initState() {
    super.initState();
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => MediaState(
              mediaItem, position, mediaItem?.duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Display seek bar. Using StreamBuilder, this widget rebuilds
        /// each time the position, buffered position or duration changes.
        StreamBuilder<MediaState>(
          stream: _mediaStateStream,
          builder: (context, snapshot) {
            final mediaState = snapshot.data;
            return SeekBar(
              duration: mediaState?.duration ?? Duration.zero,
              position: mediaState?.position ?? Duration.zero,
              // bufferedPosition: mediaState?.bufferedPosition ?? Duration.zero,
              onChangeEnd: (newPosition) {
                AudioService.seekTo(newPosition);
              },
            );
          },
        ),
        // Display play/pause button and volume/speed sliders.
        ControlButtons(article)
      ],
    );
  }
}

class ControlButtons extends StatelessWidget {
  final Article article;
  ControlButtons(this.article);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (processingState == AudioProcessingState.connecting ||
            processingState == AudioProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 56.0,
            height: 56.0,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: Icon(Icons.play_arrow),
            color: Colors.white,
            iconSize: 56.0,
            onPressed: () {
              if (AudioService.running) {
                AudioService.play();
              } else {
                // AudioService.stop();
                AudioService.start(params: {
                  "id": article.src,
                  "cover": article.cover,
                  "title": article.title,
                  "date": article.date,
                }, backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint);
              }
            },
          );
        }

        return IconButton(
          icon: Icon(Icons.pause),
          color: Colors.white,
          iconSize: 56.0,
          onPressed: AudioService.pause,
        );
      },
    );
  }
}

/// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
