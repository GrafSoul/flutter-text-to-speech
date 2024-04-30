// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts _flutterTts = FlutterTts();

  // ignore: non_constant_identifier_names
  String TTS_INPUT =
      "In the first law, an object will not change its motion unless a force acts on it. In the second law, the force on an object is equal to its mass times its acceleration. In the third law, when two objects interact, they apply forces to each other of equal magnitude and opposite direction.";

  List<Map> _voices = [];
  Map? _currentVoice;
  bool _isSpeaking = false;
  double _speechRate = 1.0;
  double _pitch = 1.0;
  double _volume = 0.5;

  final List<Map<String, String>> _locales = [
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
  ];
  String? _currentLocaleCode;

  int? _currentWordStart, _currentWordEnd;

  @override
  void initState() {
    super.initState();
    _currentLocaleCode = _locales.first['code'];
    initTTS();
  }

  void _toggleSpeaking() {
    if (_isSpeaking) {
      _flutterTts.stop().then((_) {
        setState(() {
          _isSpeaking = false;
        });
      });
    } else {
      _flutterTts.speak(TTS_INPUT).then((_) {
        setState(() {
          _isSpeaking = true;
        });
      }).catchError((error) {
        print("Error speaking: $error");
      });
    }
  }

  void initTTS() {
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _flutterTts.stop();
      });
      print("TTS Completion");
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
      print("TTS Error: $msg");
    });

    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    });
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);

        setState(() {
          _voices = voices.where((voice) => voice["locale"].contains("en")).toList();
          _currentVoice = _voices.first;

          setVoice(_currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    if (voice["name"] != null && voice["locale"] != null) {
      print("Setting voice to: Name = ${voice['name']}, Locale = ${voice['locale']}");
      _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
    } else {
      print("Invalid voice data: $voice");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSpeaking,
        child: Icon(
          _isSpeaking ? Icons.stop : Icons.speaker_phone,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLanguageSelector(),
          _speakerSelector(),
          _buildSpeechRateSlider(),
          _buildPitchSlider(),
          _buildVolumeSlider(),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 20,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: TTS_INPUT.substring(0, _currentWordStart),
                ),
                if (_currentWordStart != null)
                  TextSpan(
                    text: TTS_INPUT.substring(_currentWordStart!, _currentWordEnd),
                    style: const TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.purpleAccent,
                    ),
                  ),
                if (_currentWordEnd != null)
                  TextSpan(
                    text: TTS_INPUT.substring(_currentWordEnd!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _speakerSelector() {
    return DropdownButton(
      value: _currentVoice,
      items: _voices
          .map(
            (voice) => DropdownMenuItem(
              value: voice,
              child: Text(
                voice["name"],
              ),
            ),
          )
          .toList(),
      onChanged: (Map? newValue) {
        setState(() {
          _currentVoice = newValue;
          setVoice(_currentVoice!);
        });
      },
    );
  }

  Widget _buildSpeechRateSlider() {
    return Column(
      children: [
        Text("Speech Rate: ${_speechRate.toStringAsFixed(2)}"),
        Slider(
          value: _speechRate,
          min: 0.1,
          max: 1.0,
          divisions: 15,
          label: _speechRate.toStringAsFixed(2),
          onChanged: (double value) {
            setState(() {
              _speechRate = value;
            });
            _flutterTts.setSpeechRate(value);
          },
        ),
      ],
    );
  }

  Widget _buildPitchSlider() {
    return Column(
      children: [
        Text("Pitch: ${_pitch.toStringAsFixed(2)}"),
        Slider(
          value: _pitch,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: _pitch.toStringAsFixed(2),
          onChanged: (double value) {
            setState(() {
              _pitch = value;
            });
            _flutterTts.setPitch(value);
          },
        ),
      ],
    );
  }

  Widget _buildVolumeSlider() {
    return Column(
      children: [
        Text("Volume: ${_volume.toStringAsFixed(2)}"),
        Slider(
          value: _volume,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: _volume.toStringAsFixed(2),
          onChanged: (double value) {
            setState(() {
              _volume = value;
              _flutterTts.setVolume(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButton<String>(
      value: _currentLocaleCode,
      onChanged: (String? newValue) {
        setState(() {
          _currentLocaleCode = newValue;
          _updateVoicesForSelectedLocale(newValue);
        });
      },
      items: _locales.map<DropdownMenuItem<String>>((Map<String, String> locale) {
        return DropdownMenuItem<String>(
          value: locale['code'],
          child: Text(locale['name']!),
        );
      }).toList(),
    );
  }

  void _updateVoicesForSelectedLocale(String? localeCode) {
    _flutterTts.getVoices.then((voices) {
      List<Map> filteredVoices =
          List<Map>.from(voices).where((Map voice) => voice['locale'].toString().toLowerCase() == localeCode).toList();
      setState(() {
        _voices = filteredVoices;
        if (_voices.isNotEmpty) {
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        } else {
          _currentVoice = null;
        }
      });
    }).catchError((error) {
      print("Error retrieving voices: $error");
    });
  }
}
