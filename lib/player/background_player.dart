import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'common.dart';

class BackgroundPlayer extends StatelessWidget {
  final AudioHandler _audioHandler;
  const BackgroundPlayer(this._audioHandler, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Show media item title
        StreamBuilder<MediaItem?>(
          stream: _audioHandler.mediaItem,
          builder: (context, snapshot) {
            final mediaItem = snapshot.data;
            return Text(mediaItem?.title ?? '',
                style: const TextStyle(color: Colors.white));
          },
        ),
        // Play/pause/stop buttons.
        StreamBuilder<bool>(
          stream: _audioHandler.playbackState
              .map((state) => state.playing)
              .distinct(),
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _button(Icons.fast_rewind, _audioHandler.rewind),
                if (playing)
                  _button(Icons.pause, _audioHandler.pause)
                else
                  _button(Icons.play_arrow, _audioHandler.play),
                _button(Icons.stop, _audioHandler.stop),
                _button(Icons.fast_forward, _audioHandler.fastForward),
              ],
            );
          },
        ),
        // A seek bar.
        StreamBuilder<MediaState>(
          stream: _mediaStateStream,
          builder: (context, snapshot) {
            final mediaState = snapshot.data;
            return SeekBar(
              duration: mediaState?.mediaItem?.duration ?? Duration.zero,
              position: mediaState?.position ?? Duration.zero,
              bufferedPosition: Duration.zero,
              onChangeEnd: (newPosition) {
                _audioHandler.seek(newPosition);
              },
            );
          },
        ),
        // Display the processing state.
        StreamBuilder<AudioProcessingState>(
          stream: _audioHandler.playbackState
              .map((state) => state.processingState)
              .distinct(),
          builder: (context, snapshot) {
            final processingState = snapshot.data ?? AudioProcessingState.idle;
            return Text("Processing state: ${describeEnum(processingState)}",
                style: const TextStyle(color: Colors.white));
          },
        ),
      ],
    );
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          _audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
        icon: Icon(iconData),
        color: Colors.white,
        iconSize: 64.0,
        onPressed: onPressed,
      );
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    // update player state
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  /// Initialise our audio handler.
  void init(MediaItem item) {
    _player.stop();
    // Load the player.
    _player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));

    // update duration
    _player.durationStream.listen((duration) {
      final modifiedMediaItem = item.copyWith(duration: duration);
      mediaItem.add(modifiedMediaItem);
    });
    // }
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
