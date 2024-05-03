// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();

  String ttsInput =
      "In the first law, an object will not change its motion unless a force acts on it. In the second law, the force on an object is equal to its mass times its acceleration. In the third law, when two objects interact, they apply forces to each other of equal magnitude and opposite direction.";

  RxList<Map> voices = <Map>[].obs;

  Map? currentVoice;

  final isSpeaking = false.obs;
  final speechRate = 1.0.obs;
  final pitch = 1.0.obs;
  final volume = 0.5.obs;

  RxList<Map<String, String>> locales = [
    {'name': 'English (US)', 'code': 'en-us'},
    {'name': 'English (UK)', 'code': 'en-gb'},
    {'name': 'Russian', 'code': 'ru-ru'},
    {'name': 'Spanish (Spain)', 'code': 'es-es'},
    {'name': 'Spanish (Mexico)', 'code': 'es-mx'},
    {'name': 'French', 'code': 'fr-fr'},
    {'name': 'German', 'code': 'de-de'},
    {'name': 'Italian', 'code': 'it-it'},
    {'name': 'Japanese', 'code': 'ja-jp'},
    {'name': 'Chinese', 'code': 'zh-cn'},
    {'name': 'Korean', 'code': 'ko-kr'},
    {'name': 'Portuguese (Brazil)', 'code': 'pt-br'}
  ].obs;

  final currentLocaleCode = 'en-us'.obs;

  RxInt? currentWordStart = RxInt(0);
  RxInt? currentWordEnd = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    currentLocaleCode.value = locales.first['code']!;
    initTTS();
  }

  void toggleSpeaking() {
    if (isSpeaking.value) {
      flutterTts.stop().then((_) {
        isSpeaking.value = false;
        update();
      });
    } else {
      flutterTts.speak(ttsInput).then((_) {
        isSpeaking.value = true;
        update();
      }).catchError((error) {
        print("Error speaking: $error");
      });
    }
  }

  void initTTS() {
    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
      flutterTts.stop();
      update();
      print("TTS Completion");
    });

    flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      update();
      print("TTS Error: $msg");
    });

    flutterTts.setProgressHandler((text, start, end, word) {
      print("Progress: text=$text, start=$start, end=$end, word=$word");
      currentWordStart!.value = start;
      currentWordEnd!.value = end;
      update();
    });

    flutterTts.getVoices.then((data) {
      try {
        List<Map> dataVoices = List<Map>.from(data);
        voices.value = dataVoices.where((voice) => voice["locale"].contains("en")).toList();
        if (voices.isNotEmpty) {
          currentVoice = voices.first;
          setVoice(currentVoice!);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    if (voice["name"] != null && voice["locale"] != null) {
      print("Setting voice to: Name = ${voice['name']}, Locale = ${voice['locale']}");
      flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
    } else {
      print("Invalid voice data: $voice");
    }
    update();
  }

  Widget buildLanguageSelector() {
    return Obx(() => DropdownButton<String>(
          value: currentLocaleCode.value,
          onChanged: (String? newValue) {
            if (newValue != null && newValue != currentLocaleCode.value) {
              currentLocaleCode.value = newValue;
              updateVoicesForSelectedLocale(newValue);
              flutterTts.setLanguage(newValue);
              update();
            }
          },
          items: locales.map<DropdownMenuItem<String>>((Map<String, String> locale) {
            return DropdownMenuItem<String>(
              value: locale['code'],
              child: Text(locale['name']!),
            );
          }).toList(),
        ));
  }

  Widget speakerSelector() {
    return Obx(() => DropdownButton(
          value: currentVoice,
          onChanged: (Map? newValue) {
            if (newValue != null) {
              currentVoice = newValue;
              setVoice(currentVoice!);
              update();
            }
          },
          items: voices.map((voice) {
            return DropdownMenuItem(
              value: voice,
              child: Text(voice["name"]),
            );
          }).toList(),
        ));
  }

  Widget buildSpeechRateSlider() {
    return Column(
      children: [
        Text("Speech Rate: ${speechRate.value.toStringAsFixed(2)}"),
        Obx(() => Slider(
              value: speechRate.value,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: speechRate.value.toStringAsFixed(2),
              onChanged: (double value) {
                speechRate.value = value;
                flutterTts.setSpeechRate(value);
                update();
              },
            )),
      ],
    );
  }

  Widget buildPitchSlider() {
    return Column(
      children: [
        Text("Pitch: ${pitch.value.toStringAsFixed(2)}"),
        Obx(() => Slider(
              value: pitch.value,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: pitch.value.toStringAsFixed(2),
              onChanged: (double value) {
                pitch.value = value;
                flutterTts.setPitch(value);
                update();
              },
            )),
      ],
    );
  }

  Widget buildVolumeSlider() {
    return Column(
      children: [
        Text("Volume: ${volume.value.toStringAsFixed(2)}"),
        Obx(() => Slider(
              value: volume.value,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: volume.value.toStringAsFixed(2),
              onChanged: (double value) {
                volume.value = value;
                flutterTts.setVolume(value);
                update();
              },
            )),
      ],
    );
  }

  Widget buildTextSpan() {
    int start = currentWordStart!.value;
    int end = currentWordEnd!.value;

    print(start);
    print(end);
    print(ttsInput.length);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 20,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: ttsInput.substring(0, start),
          ),
          TextSpan(
            text: ttsInput.substring(start, end),
            style: const TextStyle(
              color: Colors.white,
              backgroundColor: Colors.purpleAccent,
            ),
          ),
          TextSpan(
            text: ttsInput.substring(end),
          ),
        ],
      ),
    );
  }

  void updateVoicesForSelectedLocale(String? localeCode) {
    flutterTts.getVoices.then((voicesData) {
      try {
        List<Map<String, dynamic>> filteredVoices = [];
        for (var voice in voicesData) {
          if (voice['locale'].toString().toLowerCase().contains(localeCode!.toLowerCase())) {
            filteredVoices.add(Map<String, dynamic>.from(voice));
          }
        }
        if (filteredVoices.isNotEmpty) {
          voices.value = filteredVoices;
          currentVoice = voices.first;
          setVoice(currentVoice!);
        } else {
          voices.clear();
          currentVoice = null;
          print("No voices available for this locale: $localeCode");
        }
        update();
      } catch (e) {
        print("Error processing voices: $e");
      }
    }).catchError((error) {
      print("Error retrieving voices: $error");
    });
  }
}
