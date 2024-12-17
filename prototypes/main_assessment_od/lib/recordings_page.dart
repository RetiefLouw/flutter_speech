import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'recognize_whisper.dart';

class RecordedFilesPage extends StatefulWidget {
  @override
  _RecordedFilesPageState createState() => _RecordedFilesPageState();
}

class _RecordedFilesPageState extends State<RecordedFilesPage> {
  List<FileSystemEntity> _audioFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, String?> _transcriptions = {}; // To hold transcriptions

  Future<void> _loadAudioFiles() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Load from internal storage
    final audioDir = Directory(directory.path);

    // Load .wav files to convert
    final files = audioDir.listSync().where((file) {
      return file.path.endsWith('.wav');
    }).toList();

    setState(() {
      _audioFiles = files;
    });
  }

  Future<void> _playAudio(String filePath) async {
    // String wavFilePath = filePath.endsWith('.pcm')
    //     ? filePath.replaceAll('.pcm', '.wav')
    //     : filePath;

    // // Check if the WAV file exists, if not, convert the PCM file to WAV
    // if (!File(wavFilePath).existsSync()) {
    //   await convertPcmToWav(filePath, wavFilePath);
    // }

    // Verify that the WAV file exists before playing
    if (!File(filePath).existsSync()) {
      print("File does not exist: $filePath");
      return; // Exit if the file doesn't exist
    }

    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      print("Error playing audio: $e");
    }




    
  }

  Future<void> _convertPcmToWav() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory(directory.path);

    // Load .pcm files to convert
    final pcmFiles = audioDir.listSync().where((file) {
      return file.path.endsWith('.pcm');
    }).toList();

    // Check if pcmFiles is not empty and not null
    if (pcmFiles.isNotEmpty) {
      for (var filePath in pcmFiles) {
        String pcmFilePath =
            filePath.path; // Use .path for the correct file path
        String wavFilePath = pcmFilePath.endsWith('.pcm')
            ? pcmFilePath.replaceAll('.pcm', '.wav')
            : pcmFilePath;

        print('PCM File: $pcmFilePath');
        print('WAV File: $wavFilePath');

        // Ensure PCM file exists
        if (await File(pcmFilePath).exists()) {
          final String command =
              '-f s16le -ar 16000 -ac 1 -i "$pcmFilePath" "$wavFilePath"';
          final session = await FFmpegKit.execute(command);

          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            print("Conversion successful: $wavFilePath");
            // After successful conversion, remove the PCM file
            try {
              await File(pcmFilePath).delete();
              print("PCM file deleted: $pcmFilePath");
            } catch (e) {
              print("Failed to delete PCM file: $pcmFilePath, Error: $e");
            }
          } else {
            print("Conversion failed with return code: $returnCode");
          }
        } else {
          print("PCM file does not exist: $pcmFilePath");
        }
      }
    } else {
      print("No .pcm files found for conversion.");
    }
  }

  Future<void> _removeAllFiles() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Use internal storage
    final audioDir = Directory(directory.path);

    final files = audioDir.listSync();
    for (var file in files) {
      if (file.path.endsWith('.wav') || file.path.endsWith('.pcm')) {
        await file.delete();
      }
    }

    _loadAudioFiles(); // Refresh the list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All audio files deleted.')),
    );
  }

Future<void> _transcribeAll() async {
  RecognizeWhisper recognizer = RecognizeWhisper(); // Instantiate once
  Duration timeoutDuration = Duration(seconds: 5); // Set timeout duration as needed

  for (var file in _audioFiles) {
    if (file.path.endsWith('.wav')) {
      try {
        // Race between the transcription and the timeout
        String? transcription = await Future.any([
          recognizer.transcribe(file.path),
          Future.delayed(timeoutDuration, () => throw TimeoutException('Transcription timed out'))
        ]);

        // Handle the transcription (if completed successfully)
        setState(() {
          _transcriptions[file.path] = transcription ?? "Transcription failed";
        });

      } catch (e) {
        if (e is TimeoutException) {
          print('Timeout while transcribing ${file.path}: ${e.message}');
          // Handle timeout scenario (e.g., log, retry, or inform the user)
        } else {
          print('Error while transcribing ${file.path}: $e');
        }
      }
    }
  }
}


  @override
  void initState() {
    super.initState();
    // Ensure that _convertPcmToWav() finishes before calling _loadAudioFiles
    _convertPcmToWav().then((_) {
      // Once conversion is complete, proceed to load audio files
      _loadAudioFiles();
    }).catchError((error) {
      // Handle any errors that might occur during conversion
      print('Error during conversion: $error');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorded Audio Files'),
      ),
      body: _audioFiles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _audioFiles.length,
              itemBuilder: (context, index) {
                final file = _audioFiles[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  subtitle: Text(_transcriptions[file.path] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () => _playAudio(file.path),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'transcribe_button', // Unique tag
            onPressed: _transcribeAll,
            child: Icon(Icons.transcribe),
            tooltip: 'Transcribe All Files',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'delete_button', // Unique tag
            onPressed: _removeAllFiles,
            child: Icon(Icons.delete),
            tooltip: 'Delete All Files',
          ),
        ],
      ),
    );
  }
}
