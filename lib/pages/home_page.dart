// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/tts_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final controller = Get.put(TtsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            controller.buildLanguageSelector(),
            controller.speakerSelector(),
            controller.buildSpeechRateSlider(),
            controller.buildPitchSlider(),
            controller.buildVolumeSlider(),
            Obx(() => controller.buildTextSpan()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.toggleSpeaking,
        child: Obx(() => Icon(
              controller.isSpeaking.value ? Icons.stop : Icons.speaker_phone,
            )),
      ),
    );
  }
}
