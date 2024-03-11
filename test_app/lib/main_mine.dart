// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sound Classification',
      home: SoundClassification(),
    );
  }
}

class SoundClassification extends StatefulWidget {
  const SoundClassification({super.key});

  @override
  State<SoundClassification> createState() => _SoundClassificationState();
}

class _SoundClassificationState extends State<SoundClassification> {
  Stream<Map<dynamic, dynamic>>? result;
  final String model = 'assets/decoded_wav_model.tflite';
  final String label = 'assets/decoded_wav_label.txt';
  final String audioDirectory = 'assets/sample_audio_16k_mono.wav';
  final int sampleRate = 16000;
  final int bufferSize = 11016;
  final bool outputRawScores = false;
  final int numOfInferences = 5;
  final int numThreads = 1;
  final bool isAsset = true;
  final String inputType = 'decodedWav';
  late Stream<Map<dynamic, dynamic>> recognitionStream;

  final isRecording = ValueNotifier<bool>(false);

  @override
  void initState() {
    print("----------- initState 0 -----------");
    super.initState();
    TfliteAudio.loadModel(
      model: model,
      label: label,
      inputType: inputType,
      numThreads: 5,
    );
    print("----------- initState 1 -----------");
    TfliteAudio.setSpectrogramParameters(
      nMFCC: 40,
      hopLength: 16384,
    );
    print("----------- initState 2 -----------");
  }

  void getResult() {
    recognitionStream = TfliteAudio.startFileRecognition(
      audioDirectory: audioDirectory,
      sampleRate: sampleRate,
    );
    recognitionStream.listen((event) {
      result = event["inferenceTime"];
      var inferenceTime = event["recognitionResult"];
      print(inferenceTime);
    }).onDone(() => isRecording.value = false);

    result
        ?.listen((event) =>
            print("Recognition Result: ${event["recognitionResult"]}"))
        .onDone(() => isRecording.value = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sound Classification'),
        ),
        body: Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ElevatedButton(
          onPressed: () {
            getResult();
          },
          child: const Text('Pick a file'),
        ));
  }
}
