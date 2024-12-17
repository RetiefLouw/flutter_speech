# MAIN Assessment (On-Device)

This prototype performs the MAIN assessment on the device. The app features an image carousel, and during image display, it activates voice activity detection to record any detected speech. Once the assessment is complete, users can playback the recordings, and the transcription functionality generates text for all recorded speech.

## Getting Started

1. Download Silero-VAD model and add to assets:

        mkdir -p assets/models
        wget https://github.com/snakers4/silero-vad/raw/master/src/silero_vad/data/silero_vad.onnx
        mv silero_vad.onnx assets/models/

2. Export a Hugging Face Whisper model [here](../../scripts/whisper) and copy files to `assets/models`.

3. Change `pubspec.yaml`:

        flutter:
        ...
           assets:
           - assets/models/silero_vad.onnx
           - assets/models/tiny-encoder.int8.onnx # Update accordingly
           - assets/models/tiny-decoder.int8.onnx # Update accordingly
           - assets/models/tiny-tokens.txt # Update accordingly
