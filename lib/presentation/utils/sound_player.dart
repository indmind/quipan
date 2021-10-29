import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

abstract class SoundPlayer {
  Future<void> startHomeBGM();
  Future<void> startLobbyBGM();
  Future<void> startGameBGM();
  Future<void> startLeaderboardBGM();
  Future<void> stopBGM();

  Future<void> playWoosh();
  Future<void> playCorrect();
  Future<void> playWrong();
}

class SoundPlayerImpl implements SoundPlayer {
  final _homeBgmPlayer = AudioPlayer();
  final _lobbyBgmPlayer = AudioPlayer();
  final _gameBgmPlayer = AudioPlayer();
  // final _leaderboardBgmPlayer = AudioPlayer();

  final _wooshEffectPlayer = AudioPlayer();
  final _correctEffectPlayer = AudioPlayer();
  final _wrongEffectPlayer = AudioPlayer();

  bool _isLoaded = false;

  SoundPlayerImpl() {
    loadAssets();
  }

  Future<void> loadAssets() async {
    await Future.wait([
      _homeBgmPlayer.setAsset('assets/audio/home.ogg'),
      _lobbyBgmPlayer.setAsset('assets/audio/lobby.ogg'),
      _gameBgmPlayer.setAsset('assets/audio/game.ogg'),
      // _leaderboardBgmPlayer.setAsset('assets/audio/leaderboard.ogg'),
      _wooshEffectPlayer.setAsset('assets/audio/woosh.ogg'),
      _correctEffectPlayer.setAsset('assets/audio/correct.ogg'),
      _wrongEffectPlayer.setAsset('assets/audio/wrong.ogg'),
    ]);

    _isLoaded = true;
  }

  @override
  Future<void> startHomeBGM() async {
    if (!_isLoaded) await loadAssets();

    // skip silent part
    _homeBgmPlayer.seek(1.2.seconds);
    _homeBgmPlayer.play();
    _lobbyBgmPlayer.pause();
    _lobbyBgmPlayer.seek(Duration.zero);
    _gameBgmPlayer.pause();
    _gameBgmPlayer.seek(Duration.zero);
  }

  @override
  Future<void> startLobbyBGM() async {
    if (!_isLoaded) await loadAssets();

    _lobbyBgmPlayer.play();
    _homeBgmPlayer.pause();
    _homeBgmPlayer.seek(Duration.zero);
    _gameBgmPlayer.pause();
    _gameBgmPlayer.seek(Duration.zero);
  }

  @override
  Future<void> startGameBGM() async {
    if (!_isLoaded) await loadAssets();

    _gameBgmPlayer.setVolume(0.5);
    _gameBgmPlayer.play();
    _homeBgmPlayer.pause();
    _homeBgmPlayer.seek(Duration.zero);
    _lobbyBgmPlayer.pause();
    _lobbyBgmPlayer.seek(Duration.zero);
  }

  @override
  Future<void> startLeaderboardBGM() async {
    if (!_isLoaded) await loadAssets();
    // TODO: implement startLeaderboardBGM
    throw UnimplementedError();
  }

  @override
  Future<void> stopBGM() async {
    if (!_isLoaded) await loadAssets();

    _homeBgmPlayer.pause();
    _homeBgmPlayer.seek(Duration.zero);
    _lobbyBgmPlayer.pause();
    _lobbyBgmPlayer.seek(Duration.zero);
    _gameBgmPlayer.pause();
    _gameBgmPlayer.seek(Duration.zero);
  }

  @override
  Future<void> playCorrect() async {
    await _correctEffectPlayer.play();
    await _correctEffectPlayer.seek(Duration.zero);
    await _correctEffectPlayer.pause();
  }

  @override
  Future<void> playWoosh() async {
    await _wooshEffectPlayer.play();
    await _wooshEffectPlayer.seek(Duration.zero);
    await _wooshEffectPlayer.pause();
  }

  @override
  Future<void> playWrong() async {
    await _wrongEffectPlayer.play();
    await _wrongEffectPlayer.seek(Duration.zero);
    await _wrongEffectPlayer.pause();
  }
}
