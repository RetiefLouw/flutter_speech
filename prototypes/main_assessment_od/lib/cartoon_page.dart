import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import 'utils.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  // Cartoon stuff
  final PageController _pageController = PageController();
  final List<String> _images = [
    'assets/images/dog1.png',
    'assets/images/dog2.png',
    'assets/images/dog3.png',
    'assets/images/dog4.png',
    'assets/images/dog5.png',
    'assets/images/dog6.png',
  ];

  int _currentIndex = 0;

  // VAD stuff
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

  // Next cartoon
  void _nextPage() {
    if (_currentIndex < _images.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  // Prev cartoon
  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  // New file instance for when VAD detected
  Future<void> _initializeNewFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Use internal storage
    String filePath = '${directory.path}/recorded_audio_${_fileCounter++}.pcm';
    print(filePath);
    _currentAudioFile = File(filePath);
    _currentAudioSink = await _currentAudioFile!.openWrite();
  }

  // Stop file wrtiting after VAD session
  Future<void> _stopCurrentFileWrite() async {
    await _currentAudioSink?.flush();
    await _currentAudioSink?.close();
    _currentAudioSink = null;
    _currentAudioFile = null;
  }

  // Stop or start recording
  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);
  }

  // Initialise VAD session. Starts when assessment begins
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

  // Stop listening. At the end of assessment
  Future<void> _stop() async {
    if (_currentAudioSink != null) {
      await _stopCurrentFileWrite();
    }
    await _audioRecorder.stop();
    _detector.reset();
  }

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen(_updateRecordState);
    _start();
  }

  @override
  void dispose() {
    _stop();
    _recordSub?.cancel();
    _stopCurrentFileWrite(); // Ensure the sink is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Carousel'),
        backgroundColor: Colors.lightGreen,
      ),
      backgroundColor: Colors.white, // Set your desired background color here

      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  width: 200, // 2 cm in pixels
                  height: 200, // 2 cm in pixels
                  alignment: Alignment.center, // Center the image
                  child: Image.asset(
                    _images[index],
                    fit: BoxFit.contain, // Adjust to fit without stretching
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // BottomAppBar to hold the buttons
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Customize the background color
        child: Row(
          children: [
            // Previous Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // Button color
                  padding: EdgeInsets.zero, // No padding
                  // elevation: 10,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius
                        .zero, // No rounded corners (square corners)
                  ),
                  minimumSize: Size(double.infinity,
                      100), // Set width to fill the space and fixed height
                ),
                onPressed: _previousPage,
                child: Icon(
                  Icons.arrow_back,
                  size: 30, // Icon size
                  color: Colors.black, // Icon color
                ),
              ),
            ),
            // End Session Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // Button color
                  padding: EdgeInsets.zero, // No padding
                  // elevation: 10,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius
                        .zero, // No rounded corners (square corners)
                  ),
                  minimumSize: Size(double.infinity,
                      100), // Set width to fill the space and fixed height
                ),
                onPressed: () {
                  _stop();
                },
                child: Text(
                  "End Session",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            // Next Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // Button color
                  padding: EdgeInsets.zero, // No padding
                  // elevation: 10,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius
                        .zero, // No rounded corners (square corners)
                  ),
                  minimumSize: Size(double.infinity,
                      100), // Set width to fill the space and fixed height
                ),
                onPressed: _nextPage,
                child: Icon(
                  Icons.arrow_forward,
                  size: 30, // Icon size
                  color: Colors.black, // Icon color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
