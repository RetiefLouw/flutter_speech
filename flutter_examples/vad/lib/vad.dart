import 'dart:async';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'utils.dart';

Future<sherpa_onnx.VoiceActivityDetector> createOnlineDetector() async {
  const modelDir = 'assets/models/silero_vad.onnx';
  final sileroConfig = sherpa_onnx.SileroVadModelConfig(
    model: await copyAssetFile(modelDir),
    threshold: 0.5,
    minSilenceDuration: 0.5,
    minSpeechDuration: 0.15,
    windowSize: 512,
    maxSpeechDuration: 5.0,
  );

  final vadConfig = sherpa_onnx.VadModelConfig(
    sileroVad: sileroConfig,
    debug: false,
  );

  return sherpa_onnx.VoiceActivityDetector(
    config: vadConfig,
    bufferSizeInSeconds: 0.4,
  );
}