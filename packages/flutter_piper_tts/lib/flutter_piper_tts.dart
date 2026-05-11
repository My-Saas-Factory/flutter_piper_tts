import "package:dart_piper_tts/dart_piper_tts.dart" as piper_dart;
import "package:path_provider/path_provider.dart";

class PiperTTS {
  final piper_dart.PiperTTS _tts;

  PiperTTS._(this._tts);

  static Future<void> init({String? dataDir}) async {
    piper_dart.PiperTTS.init((
      dataDir: dataDir ?? (await getApplicationDocumentsDirectory()).path,
    ));
  }

  static Future<PiperTTS> create({
    required String modelPath,
    required String configPath,
  }) async {
    return PiperTTS._(
      piper_dart.PiperTTS.create((
        configPath: configPath,
        modelPath: modelPath,
      )),
    );
  }

  Future<void> speak(String text, {bool waitForCompletion = true}) =>
      _tts.speak(text, waitForCompletion: waitForCompletion);

  void pause() => _tts.pause();

  void resume() => _tts.resume();

  void stop() => _tts.stop();

  /// Sets the speech rate for this instance.
  ///
  /// `rate` is a multiplier where `1.0` is the model's default speed.
  /// Values greater than `1.0` speak faster; values below `1.0` speak slower.
  /// Pitch is preserved. Takes effect on the next clause; audio already
  /// queued for playback is unaffected. Clamped to a minimum of `0.1`.
  void setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  /// Sets the global output volume.
  ///
  /// `volume` is linear in `[0.0, 1.0]` and is clamped to that range.
  /// The audio player is process-global, so this affects all `PiperTTS`
  /// instances.
  static void setVolume(double volume) => piper_dart.PiperTTS.setVolume(volume);

  void dispose() => _tts.dispose();
}
