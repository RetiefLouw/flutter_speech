// import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

import 'utils.dart';

class FeatureExtractor {
  OrtSessionOptions? _sessionOptions;
  OrtSession? _session;

  FeatureExtractor() {
    OrtEnv.instance.init();
    OrtEnv.instance.availableProviders().forEach((element) {
      print('onnx provider=$element');
    });
  }

  initModel() async {
    _sessionOptions = OrtSessionOptions()
      ..setInterOpNumThreads(1)
      ..setIntraOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    const assetFileName = 'assets/models/model.onnx';
    final rawAssetFile = await rootBundle.load(assetFileName);
    final bytes = rawAssetFile.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, _sessionOptions!);
  }

  Future<List<List<double>>> predict(Uint8List bytes) async {
    print("Predict...");
    final floatBuffer = convertBytesToFloat32(bytes);

    final runOptions = OrtRunOptions();
    final inputOrt = OrtValueTensor.createTensorWithDataList(
        floatBuffer, [1, floatBuffer.length]); // (x, [B x seq_len])
    // print(inputOrt.value);
    final inputs = {'input_values': inputOrt};
    final List<OrtValue?>? outputs;

    try {
      outputs = await _session?.runAsync(runOptions, inputs);
    } catch (e) {
      print('Error during prediction: $e');
      return [];
    }
    final output = (outputs?[0]?.value as List<List<List<double>>>)[0];

    inputOrt.release();
    runOptions.release();
    
    return output;
  }

  release() {
    _sessionOptions?.release();
    _sessionOptions = null;
    _session?.release();
    _session = null;
    OrtEnv.instance.release();
  }
}
