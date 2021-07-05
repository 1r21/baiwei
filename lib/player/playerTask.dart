import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// This task defines logic for playing a list of podcast episodes.
class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _player = AudioPlayer();
  AudioProcessingState? _skipState;
  late StreamSubscription<PlaybackEvent> _eventSubscription;

  // void _loadBufferedPosition(MediaItem mediaItem) {
  //   _player.bufferedPositionStream.listen((bufferedPosition) {
  //     final extras = {"bufferedPosition": bufferedPosition};
  //     final modifiedMediaItem = mediaItem.copyWith(extras: extras);
  //     AudioServiceBackground.setMediaItem(modifiedMediaItem);
  //   });
  // }

  void _loadDuration(MediaItem mediaItem) {
    _player.durationStream.listen((duration) {
      final modifiedMediaItem =
          mediaItem.copyWith(duration: duration ?? Duration.zero);
      AudioServiceBackground.setMediaItem(modifiedMediaItem);
    });
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    MediaItem media = MediaItem(
      id: params!["id"],
      album: params["date"],
      title: params['title'],
      artUri: Uri.parse(params["cover"]),
    );

    AudioServiceBackground.setMediaItem(media);

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    ///  Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    /// Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    try {
      _loadDuration(AudioServiceBackground.mediaItem!);
      // _loadBufferedPosition(AudioServiceBackground.mediaItem!);

      await _player.setUrl(media.id);
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onStop() async {
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState!;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}
