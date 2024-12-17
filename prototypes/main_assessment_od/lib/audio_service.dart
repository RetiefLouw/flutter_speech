import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import 'utils.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late sherpa_onnx.VoiceActivityDetector _detector;
  bool _isInitialized = false;

  File? _currentAudioFile;
  IOSink? _currentAudioSink;
  int _fileCounter = 0;

  Future<void> initialize() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();
      _detector = await createOnlineDetector();
      _isInitialized = true;
    }
  }

  Future<void> startRecording() async {
    if (!await _audioRecorder.hasPermission()) return;

    const recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );

    final stream = await _audioRecorder.startStream(recordConfig);
    _detector.reset();

    stream.listen((data) async {
      final samples = convertBytesToFloat32(Uint8List.fromList(data));
      _detector.acceptWaveform(samples);

      if (_detector.isDetected()) {
        if (_currentAudioSink == null) await _initializeNewFile();
        _currentAudioSink?.add(data);
      } else if (_currentAudioSink != null) {
        await _stopCurrentFileWrite();
      }
    });
  }

  Future<void> stopRecording() async {
    await _stopCurrentFileWrite();
    await _audioRecorder.stop();
    _detector.reset();
  }

  Future<void> _initializeNewFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recorded_audio_${_fileCounter++}.pcm';
    _currentAudioFile = File(filePath);
    _currentAudioSink = await _currentAudioFile!.openWrite();
  }

  Future<void> _stopCurrentFileWrite() async {
    await _currentAudioSink?.flush();
    await _currentAudioSink?.close();
    _currentAudioSink = null;
    _currentAudioFile = null;
  }
}
