import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:dart_piper_tts/src/ffi.g.dart' as g;
import 'package:ffi/ffi.dart';

class PiperTTS {
  static final Map<int, Completer<void>> _completers = {};

  static RawReceivePort? _receivePort;

  static NativeCallable<Void Function(Int64)>? _nativeCompletionCallback;

  static int _nextId = 0;

  final int _fd;

  PiperTTS._(this._fd);

  static void _onNativeComplete(int port) {
    _receivePort!.sendPort.send(port);
  }

  static void init(({String dataDir}) args) {
    final dataDirPointer = args.dataDir.toNativeUtf8();

    _receivePort ??= RawReceivePort((dynamic port) {
      _completers.remove(port as int)?.complete();
    });

    _nativeCompletionCallback ??= NativeCallable<Void Function(Int64)>.listener(
      _onNativeComplete,
    );

    try {
      final result = g.init(
        dataDirPointer.cast<Char>(),
        _nativeCompletionCallback!.nativeFunction,
      );
      final g.FFIInitResponse(:error_message) = result;
      if (error_message.isNotEmpty) {
        throw Exception(error_message.toDartString());
      }
    } finally {
      calloc.free(dataDirPointer);
    }
  }

  static PiperTTS create(({String modelPath, String configPath}) args) {
    final modelPathPointer = args.modelPath.toNativeUtf8();
    final configPathPointer = args.configPath.toNativeUtf8();

    try {
      final result = g.create_instance(
        modelPathPointer.cast<Char>(),
        configPathPointer.cast<Char>(),
      );
      final g.FFICreateInstanceResponse(:fd, :error_message) = result;
      if (error_message.isNotEmpty) {
        throw Exception(error_message.toDartString());
      }
      return PiperTTS._(fd);
    } finally {
      calloc.free(modelPathPointer);
      calloc.free(configPathPointer);
    }
  }

  Future<void> speak(String text, {bool waitForCompletion = true}) async {
    final textPointer = text.toNativeUtf8();
    final id = _nextId++;
    final completer = Completer<void>();
    _completers[id] = completer;
    try {
      final result = g.speak(_fd, textPointer.cast<Char>(), id);
      final g.FFISpeakResponse(:error_message) = result;
      if (error_message.isNotEmpty) {
        throw Exception(error_message.toDartString());
      }
    } finally {
      calloc.free(textPointer);
    }
    if (waitForCompletion) return completer.future;
  }

  void pause([dynamic _]) {
    final result = g.pause(_fd);
    final g.FFIPauseResponse(:error_message) = result;
    if (error_message.isNotEmpty) {
      throw Exception(error_message.toDartString());
    }
  }

  void resume([dynamic _]) {
    final result = g.resume(_fd);
    final g.FFIResumeResponse(:error_message) = result;
    if (error_message.isNotEmpty) {
      throw Exception(error_message.toDartString());
    }
  }

  void stop([dynamic _]) {
    final result = g.stop(_fd);
    final g.FFIStopResponse(:error_message) = result;
    if (error_message.isNotEmpty) {
      throw Exception(error_message.toDartString());
    }
  }

  /// Sets the speech rate for this instance.
  ///
  /// `rate` is a multiplier where `1.0` is the model's default speed.
  /// Values greater than `1.0` speak faster; values below `1.0` speak slower.
  /// Pitch is preserved (the model resynthesizes at the new rate).
  /// Takes effect on the next clause sent to the synthesizer; audio already
  /// queued in the playback buffer is unaffected.
  /// `rate` is clamped to a minimum of `0.1`.
  void setSpeechRate(double rate) {
    final result = g.set_speech_rate(_fd, rate);
    final g.FFISetSpeechRateResponse(:error_message) = result;
    if (error_message.isNotEmpty) {
      throw Exception(error_message.toDartString());
    }
  }

  /// Sets the global output volume.
  ///
  /// `volume` is linear in the range `[0.0, 1.0]` and is clamped to that range.
  /// This is a process-global setting because the audio player is shared
  /// across all `PiperTTS` instances; calling it on one instance affects all.
  static void setVolume(double volume) {
    final result = g.set_volume(volume);
    final g.FFISetVolumeResponse(:error_message) = result;
    if (error_message.isNotEmpty) {
      throw Exception(error_message.toDartString());
    }
  }

  void dispose() {
    final result = g.dispose(_fd);
    final g.FFIDisposeResponse(:error_message) = result;
    if (error_message.isNotEmpty) {
      throw Exception(error_message.toDartString());
    }
  }
}

extension on Pointer<Char> {
  bool get isEmpty => this == nullptr || cast<Utf8>().toDartString().isEmpty;

  bool get isNotEmpty => !isEmpty;

  String toDartString() => cast<Utf8>().toDartString();
}
