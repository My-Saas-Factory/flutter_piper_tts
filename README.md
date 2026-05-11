# flutter_piper_tts

TTS in Dart (or Flutter) using Piper TTS models + audio player in one package.

## Usage

`Disclaimer: examples below are using the Flutter package`

- Download Piper TTS model of your choice, make sure to also prepare the `*.onnx.json` file
- Make them available to the device file system, eg. copying from your asset bundle to device application support directory
```dart
  final directory = await getApplicationSupportDirectory();
  final modelPath = join(directory.path, 'en_US-hfc_female-medium.onnx');
  final configPath = join(directory.path, 'en_US-hfc_female-medium.onnx.json');

  final exists = await File(modelPath).exists();

  if (!exists) {
    final modelData = await rootBundle.load(
      'assets/en_US-hfc_female-medium.onnx',
    );
    List<int> bytes = modelData.buffer.asUint8List(
      modelData.offsetInBytes,
      modelData.lengthInBytes,
    );

    await File(modelPath).writeAsBytes(bytes, flush: true);

    final configData = await rootBundle.load(
      'assets/en_US-hfc_female-medium.onnx.json',
    );
    bytes = configData.buffer.asUint8List(
      configData.offsetInBytes,
      configData.lengthInBytes,
    );
    await File(configPath).writeAsBytes(bytes, flush: true);
  }
```
- Initialize the package
```dart
  await PiperTTS.init();
  final tts = await PiperTTS.create(modelPath, configPath);
```
- Call `speak`
```dart
  await tts.speak("Hello world");
  tts.pause();
  tts.resume();
  await tts.speak("Bye", waitForCompletion: false)
  tts.stop();
```
- Adjust speech rate and volume
```dart
  // Per-instance speech rate: 1.0 = model default, >1.0 faster, <1.0 slower.
  // Pitch is preserved (the model resynthesizes at the new rate).
  // Takes effect on the next clause; queued audio is unaffected.
  tts.setSpeechRate(1.25);

  // Global linear volume in [0.0, 1.0]. The audio player is process-global,
  // so this affects all PiperTTS instances.
  PiperTTS.setVolume(0.8);
```

## Supported platforms
- Android
- iOS
- MacOS
- Windows and Linux (not tested)

## TODO
- Revisit phonemization
- Allow custom phoneme mapping