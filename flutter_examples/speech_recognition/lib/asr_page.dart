import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'package:record/record.dart';
// import 'vad.dart';
import 'utils.dart';
// import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:audioplayers/audioplayers.dart';

import 'asr.dart';

class ASRHomePage extends StatefulWidget {
  const ASRHomePage({super.key});
  @override
  State<ASRHomePage> createState() => _ASRHomePageState();
}

class _ASRHomePageState extends State<ASRHomePage> {
  final List<String> audioFiles = ['audio/audio1.wav', 'audio/audio2.wav', 'audio/audio3.wav'];
  String? selectedFile;

  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _text;

  @override
  void initState() {
    super.initState();
  }

  void playAudio() async {
    if (selectedFile != null) {
      await _audioPlayer.play(AssetSource(selectedFile!));
    } else {
      _showMessage('Please select an audio file first!');
    }
  }

  Future<String?> transcribeAudio() async {
    String? transcription;
    if (selectedFile != null) {
      _showMessage('Transcription for $selectedFile started...');

      RecognizeWhisper recognizer = RecognizeWhisper(); // Instantiate once

      // String inputWavFile =
          // await copyAssetFile("assets/audio/adult_id_afr.wav");
      String inputWavFile =
          await copyAssetFile("assets/${selectedFile!}");
      transcription = await recognizer.transcribe(inputWavFile);
      // print(transcription);
      _updateText(transcription!);
    } else {
      _showMessage('Please select an audio file first!');
    }
    return transcription;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _updateText(String value) {
    setState(() {
      _text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16), // Added padding
                child: DropdownButton<String>(
                  value: selectedFile,
                  hint: const Text(
                    'Select an audio file',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black), // Custom font and color
                  ),
                  items: audioFiles.map((file) {
                    return DropdownMenuItem(
                      value: file,
                      child: Text(
                        file,
                        style: const TextStyle(
                          fontSize: 20, // Larger font size for dropdown items
                          color: Colors.black, // Black text color
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFile = value;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.black, // Text color for the selected item
                    fontSize: 20, // Larger font size for selected item
                  ),
                  underline: Container(
                    height: 2, // Set the underline height
                    color: Colors.grey, // Set the underline color
                  ),
                ),
              ),
              const SizedBox(height: 40), // Space between elements
              ElevatedButton(
                onPressed: playAudio,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(), // Makes the button round
                  padding: const EdgeInsets.all(
                      16), // Larger padding for a bigger button
                  minimumSize: const Size(
                      60, 60), // Ensures the button is square and larger
                  foregroundColor: Colors.blue, // Button color
                ),
                child: const Icon(
                  Icons.play_arrow, // Play icon
                  size: 30, // Larger icon
                  color: Colors.lightBlue, // Icon color
                ),
              ),

              const SizedBox(height: 40), // Space between elements
              ElevatedButton(
                onPressed: transcribeAudio,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24), // Larger padding for button
                  foregroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  // Button color
                ),
                child: const Text(
                  "Transcribe Audio",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold), // Increased font size
                ),
              ),
              const SizedBox(height: 40), // Space between elements
              Container(
                height: 60, // Slightly larger height for better readability
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _text != null ? '$_text' : '',
                  style: const TextStyle(
                    fontSize: 20, // Larger font size for text
                    fontWeight: FontWeight.bold, // Bold text for emphasis
                    color: Colors.black87, // Darker text for contrast
                  ),
                  overflow: TextOverflow
                      .visible, // Prevent overflow if text is too long
                  textAlign: TextAlign.center, // Center the text for alignment
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
