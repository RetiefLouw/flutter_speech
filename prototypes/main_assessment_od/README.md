# MAIN Assessment (On-Device)

This prototype performs the MAIN assessment on the device. The app features an image carousel, and during image display, it activates voice activity detection to record any detected speech. Once the assessment is complete, users can playback the recordings, and the transcription functionality generates text for all recorded speech.

## Getting Started

1. Download Silero-VAD model and add to assets:

        mkdir -p assets/models
        wget https://github.com/snakers4/silero-vad/raw/master/src/silero_vad/data/silero_vad.onnx
        mv silero_vad.onnx assets/models/

2. Export a Hugging Face Whisper model [here](../../scripts/whisper) and link files to `assets/models`.

        ln -s /home/retief/Documents/git-work/flutter_speech/scripts/whisper/out/tiny-decoder.int8.onnx tiny-decoder.int8.onnx
        ln -s /home/retief/Documents/git-work/flutter_speech/scripts/whisper/out/tiny-encoder.int8.onnx tiny-encoder.int8.onnx
        ln -s /home/retief/Documents/git-work/flutter_speech/scripts/whisper/out/tiny-tokens.txt tiny-tokens.txt

3. Change `pubspec.yaml`:

        flutter:
        ...
           assets:
           - assets/models/silero_vad.onnx
           - assets/models/tiny-encoder.int8.onnx # Update accordingly
           - assets/models/tiny-decoder.int8.onnx # Update accordingly
           - assets/models/tiny-tokens.txt # Update accordingly
