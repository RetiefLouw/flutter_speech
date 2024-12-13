import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'utils.dart';
import 'dart:typed_data';
import 'dart:io';
import "features.dart";
import 'dist_calc_temp.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Template matching demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AudioRecorder _audioRecorder;
  File? _currentAudioFile;
  IOSink? _currentAudioSink;

  bool _isRecording = false;
  bool _isPlaying = false;
  String _filePath = '';

  // FeatureExtractor? _featureExtractor;

  // final AudioPlayer _audioPlayer = AudioPlayer();
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  String _statusLabel = "Ready"; // Default status label

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  Future<void> _initializeNewFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Use internal storage
    final audioDir = Directory(directory.path);

    _filePath = '${audioDir.path}/audio.pcm';
    print(_filePath);
    _currentAudioFile = File(_filePath);
    _currentAudioSink = await _currentAudioFile!.openWrite();
  }

  Future<void> _stopCurrentFileWrite() async {
    await _currentAudioSink?.flush();
    await _currentAudioSink?.close();
    _currentAudioSink = null;
    _currentAudioFile = null;
  }

  Future<void> _startRecording() async {
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

        stream.listen((data) async {
          final samplesFloat32 =
              convertBytesToFloat32(Uint8List.fromList(data));
          print(samplesFloat32);

          if (_currentAudioSink == null) {
            await _initializeNewFile();
          }
          _currentAudioSink?.add(data);
        }, onDone: () async {
          await _stopCurrentFileWrite();
          // setState(() => _isRecording = false);
        });
      }
    } catch (e) {
      debugPrint('Error in _start: $e');
    }
  }

  Future<void> _stopRecording() async {
    // if (_currentAudioSink != null) {
    //   await _stopCurrentFileWrite();
    // }
    await _audioRecorder.stop();
    // _detector.reset();
  }

  // Start or stop recording when button is pressed
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      setState(() {
        _isRecording = false;
      });
    } else {
      // _filePath = await _audioRecorder.startRecorder(toFile: 'audio.pcm');
      _startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  // // Start or stop playback of the recorded audio
  // Future<void> _togglePlayback() async {
  //   if (_isPlaying) {
  //     // await _audioPlayer.stopPlayer();
  //     setState(() {
  //       _isPlaying = false;
  //     });
  //   } else {
  //     // await _audioPlayer.startPlayer(fromURI: _filePath);
  //     setState(() {
  //       _isPlaying = true;
  //     });
  //   }
  // }

  Future<void> _playAudio() async {
    // Verify that the WAV file exists before playing
    final dir =
        await getApplicationDocumentsDirectory(); // Use internal storage
    final audioDir = Directory(dir.path);

    final filePath = '${audioDir.path}/audio.pcm';
    // // final file = File(filePath);
    if (!File(filePath).existsSync()) {
      print("File does not exist: $filePath");
      return; // Exit if the file doesn't exist
    }
    print("File exists");

    // await _audioPlayer.stop();
    // try {
    //   await _audioPlayer.play(DeviceFileSource(filePath));
    // } catch (e) {
    //   print("Error playing audio: $e");
    // }
    await _audioPlayer.openPlayer();

    await _audioPlayer.startPlayer(
      fromURI: filePath,
      codec: Codec.pcm16, // Specify the codec for your PCM file
      numChannels: 1,
      sampleRate: 16000,
    );
  }

  _matchRecordingToTemplates() async {
    List<List<double>> referenceEmbeddings = [];
    List<double> targetEmbedding = [];
    // FeatureExtractor? _featureExtractor;
    final _featureExtractor = FeatureExtractor();
    setState(() {
      _statusLabel = "Loading model";
    });
    try {
      await _featureExtractor.initModel();
      // print("MODEL LOADED");
      setState(() {
       _statusLabel = "Model loaded";
      });
    } catch (e) {
      print("Error loading feature extractor");
    }

    // Load references from assets
    final templates = [
      'assets/audio/references/dog.pcm',
      'assets/audio/references/cat.pcm',
      'assets/audio/references/mouse.pcm'
    ];
    // final templates = [
    //     await copyAssetFile('assets/audio/references/dog.pcm'),
    //     await copyAssetFile('assets/audio/references/cat.pcm'),
    //     await copyAssetFile('assets/audio/references/mouse.pcm')
    // ];
    

    List<String> templateLabels = templates.map((filePath) {
      // Use `basename` to get the filename from the file path (e.g., "dog.pcm")
      return filePath.split('/').last.split('.').first;
    }).toList(); // Extract templates, calculate mean and add to referenceSet list.

    // for (String fileName in templates) {
    for (int i = 0; i < templates.length; i++) {
      setState(() {
        _statusLabel = "Extracting references (${i + 1}/${templates.length})";
      });
      // Load the asset as raw bytes
      try {
        final byteData = await rootBundle.load(templates[i]);
        final byteList = byteData.buffer.asUint8List();
        print(byteList);
        // Now, byteList contains the raw PCM data for processing.
        if (byteList.isNotEmpty) {
          // Pass the byteList to your feature extractor.
          final output = await _featureExtractor?.predict(byteList);
          if (output != null) {
            final outputMean = meanAlongFirstAxis(output);
            referenceEmbeddings.add(outputMean);
            // print(outputMean);
            print(outputMean.length);
          } else {
            print("Prediction failed for ${templates[i]}");
          }
        } else {
          print("No data in the file: ${templates[i]}");
        }
      } catch (e) {
        print("Error loading file: ${templates[i]} - $e");
      }
    }
    setState(() {
      _statusLabel = "Extracting target";
    });
    // Extract target recording, calculate mean.
    final dir =
        await getApplicationDocumentsDirectory(); // Use internal storage
    final audioDir = Directory(dir.path);

    final targetFilePath = '${audioDir.path}/audio.pcm';
    // // final file = File(filePath);

    try {
      final file = File(targetFilePath);
      if (await file.exists()) {
        final byteList = await file.readAsBytes();
        print(byteList);
        if (byteList.isNotEmpty) {
          // Pass the byteList to your feature extractor.
          final output = await _featureExtractor?.predict(byteList);
          if (output != null) {
            targetEmbedding = meanAlongFirstAxis(output);
            // print(outputMean);
            print(targetEmbedding.length);
          } else {
            print("Prediction failed for $targetFilePath");
          }
        } else {
          print("No data in the file: $targetFilePath");
        }
      }
    } catch (e) {
      print("Error loading file: $targetFilePath - $e");
    }

    setState(() {
      _statusLabel = "Distance calculation";
    });
    // Calculate closeset
    final int closestIndex =
        findClosestListIndex(referenceEmbeddings, targetEmbedding);

    print(closestIndex);
    final String match = templateLabels[closestIndex];

    setState(() {
      _statusLabel = 'Prediction: $match';
    });

    await _featureExtractor.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 30.0), // Added padding for better layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onLongPress: _toggleRecording, // Start or stop recording
                onLongPressEnd: (details) => _toggleRecording(),
                child: CircleAvatar(
                  radius: 80, // Increase the size of the recording button
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 80, // Bigger icon
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  height:
                      30), // Space between the recording button and the next button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: _playAudio, // Play the recorded audio
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 60), // Bigger button size
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    foregroundColor: Colors.blue, // Button color
                    elevation: 5, // Shadow effect
                  ),
                  child: Text(
                    'Play Recording',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold), // Larger text
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed:
                      _matchRecordingToTemplates, // Match the recorded audio
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 60), // Bigger button size
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    foregroundColor: Colors.green, // Button color
                    elevation: 5, // Shadow effect
                  ),
                  child: Text(
                    "Predict",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold), // Larger text
                  ),
                ),
              ),
              SizedBox(
                  height: 30), // Space between the buttons and the status label
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _statusLabel, // Display the dynamic status text
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    // letterSpacing:
                    //     1, // Slightly increased letter spacing for readability
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
