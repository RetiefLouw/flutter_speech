import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:io';
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

class FixedSizeListOfUint8List {
  final List<Uint8List> _items;
  final int _maxSize;

  FixedSizeListOfUint8List(this._maxSize) : _items = [];

  void add(Uint8List item) {
    if (_items.length >= _maxSize) {
      _items.removeAt(0); // Remove the oldest list
    }
    _items.add(item); // Add the new Uint8List
  }

  void clear() {
    _items.clear(); // Clear all items
  }

  List<Uint8List> get items =>
      List.unmodifiable(_items); // Return a read-only copy

  @override
  String toString() {
    return _items.map((list) => list.toString()).toList().toString();
  }
}

class StreamingVADScreen extends StatefulWidget {
  const StreamingVADScreen({super.key});

  @override
  State<StreamingVADScreen> createState() => _StreamingVADScreenState();
}

class _StreamingVADScreenState extends State<StreamingVADScreen> {
  late final AudioRecorder _audioRecorder;
  late sherpa_onnx.VoiceActivityDetector _detector;

  bool _isVoiceDetected = false;
  RecordState _recordState = RecordState.stop;

  File? _currentAudioFile;
  IOSink? _currentAudioSink;
  int _fileCounter = 0;
  final fixedList = FixedSizeListOfUint8List(10);

  StreamSubscription<RecordState>? _recordSub;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen(_updateRecordState);
  }

  @override
  void dispose() {
    _recordSub?.cancel();
    _stopCurrentFileWrite(); // Ensure the sink is closed
    super.dispose();
  }

  Future<void> _initializeNewFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Use internal storage
    String filePath = '${directory.path}/recorded_audio_${_fileCounter++}.pcm';
    print(filePath);
    _currentAudioFile = File(filePath);
    _currentAudioSink = await _currentAudioFile!.openWrite();
  }

  Future<void> _stopCurrentFileWrite() async {
    await _currentAudioSink?.flush();
    await _currentAudioSink?.close();
    _currentAudioSink = null;
    _currentAudioFile = null;
  }

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
          // bitRate: 256000,
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
            print("Detected !!!");
            print(fixedList.items.length);

            if (_currentAudioSink == null) {
              await _initializeNewFile();
            }

            if (!_isVoiceDetected) {
              for (final item in fixedList.items) {
                _currentAudioSink?.add(item);
              }
            }

            _currentAudioSink?.add(data);

            setState(() => _isVoiceDetected = true);
            fixedList.clear();
            print(fixedList.items.length);
          } else {
            fixedList.add(data); //  clear after used?

            if (_currentAudioSink != null && _isVoiceDetected) {
              print("hello");
              await _stopCurrentFileWrite();
            }

            setState(() => _isVoiceDetected = false);

            // if (_currentAudioSink == null) {
            //   _initializeNewFile();
            // }
          }
        }, onDone: () async {
          await _stopCurrentFileWrite();
          setState(() => _isVoiceDetected = false);
        });
      }
    } catch (e) {
      debugPrint('Error in _start: $e');
    }
  }

  Future<void> _stop() async {
    if (_currentAudioSink != null) {
      await _stopCurrentFileWrite();
    }
    await _audioRecorder.stop();
    _detector.reset();
  }

  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);
  }

  Widget _buildRecordStopControl() {
    final recordIcon = _recordState != RecordState.stop
        ? const Icon(Icons.stop, color: Colors.red, size: 30)
        : Icon(Icons.mic, color: Theme.of(context).primaryColor, size: 30);

    final voiceIcon = Icon(
      _isVoiceDetected ? Icons.volume_up : Icons.volume_off,
      color: _isVoiceDetected ? Colors.green : Colors.red,
      size: 30,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Material(
            color: _recordState != RecordState.stop
                ? Colors.red.withOpacity(0.1)
                : Theme.of(context).primaryColor.withOpacity(0.1),
            child: InkWell(
              child: SizedBox(width: 56, height: 56, child: recordIcon),
              onTap: () {
                _recordState != RecordState.stop ? _stop() : _start();
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: SizedBox(width: 56, height: 56, child: voiceIcon),
              onTap: () {
                // Handle voice detection icon tap if needed
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Voice Activity Detection"),
        ),
        body: Center(
          child: _buildRecordStopControl(),
        ),
      ),
    );
  }
}
