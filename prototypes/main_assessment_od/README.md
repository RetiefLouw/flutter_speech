# MAIN Assessment (On-Device)

This prototype performs the MAIN assessment on the device. The app features an image carousel, and during image display, it activates voice activity detection to record any detected speech. Once the assessment is complete, users can playback the recordings, and the transcription functionality generates text for all recorded speech.

## Getting Started

Download Silero-VAD model and add to assets:

  mkdir -p assets/models
  wget https://github.com/snakers4/silero-vad/raw/master/src/silero_vad/data/silero_vad.onnx
  mv silero_vad.onnx assets/models/

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
