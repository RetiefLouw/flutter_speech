import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'utils.dart';

class RecognizeWhisper {
  late final sherpa_onnx.OfflineRecognizer _recognizer;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();
      _recognizer = await createOfflineRecognizer();
      _isInitialized = true;
      // print("Model initialised");
    }
  }

  Future<sherpa_onnx.OfflineRecognizer> createOfflineRecognizer() async {
    const modelDir = 'assets/models';

    final whisper = sherpa_onnx.OfflineWhisperModelConfig(
      encoder: await copyAssetFile('$modelDir/tiny-encoder.int8.onnx'),
      decoder: await copyAssetFile('$modelDir/tiny-decoder.int8.onnx'),
      language: "af",
      task: "transcribe",
      tailPaddings: 1000, // Default 1000, check this!!
    );

    final modelConfig = sherpa_onnx.OfflineModelConfig(
      whisper: whisper,
      tokens: await copyAssetFile('$modelDir/tiny-tokens.txt'),
      modelType: 'whisper',
      debug: false,
      numThreads: 1,
    );

    final config = sherpa_onnx.OfflineRecognizerConfig(model: modelConfig);
    final recognizer = sherpa_onnx.OfflineRecognizer(config);

    return recognizer;
  }

  Future<String?> transcribe(String wavFilePath) async {
    await init(); // Ensure recognizer is initialized

    final waveData = sherpa_onnx.readWave(wavFilePath);
    final stream = _recognizer.createStream();

    stream.acceptWaveform(
        samples: waveData.samples, sampleRate: waveData.sampleRate);
    _recognizer.decode(stream);

    final result = _recognizer.getResult(stream);
    // print(result);
    stream.free();

    return result.text;
  }
}
