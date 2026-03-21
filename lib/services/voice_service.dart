import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> init() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('STT status: $status'),
      onError: (error) => print('STT error: $error'),
    );
    return available;
  }

  void startListening(Function(String) onResult) {
    _isListening = true;
    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: 'en_US',
    );
  }

  void stopListening() {
    _isListening = false;
    _speech.stop();
  }
}
