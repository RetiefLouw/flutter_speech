import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'vad.dart';
import 'utils.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

class VADHomePage extends StatefulWidget {
  const VADHomePage({super.key});
  @override
  State<VADHomePage> createState() => _VADHomePageState();
}

class _VADHomePageState extends State<VADHomePage> {
  late final AudioRecorder _audioRecorder;

  late sherpa_onnx.VoiceActivityDetector _detector;
  bool _isVoiceDetected = false;
  bool _isInitialized = false;

  Future<void> _start() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();
      _detector = await createOnlineDetector();
      _isInitialized = true;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.pcm16bits;
        const recordConfig = RecordConfig(
          encoder: encoder,
          sampleRate: 16000,
          numChannels: 1,
        );

        final stream = await _audioRecorder.startStream(recordConfig);

        _detector.reset();

        stream.listen((data) async {
          final samplesFloat32 =
              convertBytesToFloat32(Uint8List.fromList(data));

          _detector.acceptWaveform(samplesFloat32);

          if (_detector.isDetected()) {
            // print("Detected !!!");
            setState(() => _isVoiceDetected = true);
          } else {
            setState(() => _isVoiceDetected = false);
          }
        }, onDone: () async {
          setState(() => _isVoiceDetected = false);
        });
      }
    } catch (e) {
      debugPrint('Error in _start: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: GestureDetector(
        child: Container(
          width: 200,
          height:200,
          color: _isVoiceDetected ? Colors.lightBlue : Colors.red,
        ),
      ),
    ));
  }
}
