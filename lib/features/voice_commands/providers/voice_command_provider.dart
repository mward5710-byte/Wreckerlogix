import 'package:flutter/foundation.dart';
import '../models/voice_command.dart';

/// State management for voice commands — hands-free driver operation.
class VoiceCommandProvider extends ChangeNotifier {
  final List<VoiceCommand> _commandHistory = [];
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastHeardText = '';
  String? _feedbackMessage;

  List<VoiceCommand> get commandHistory => List.unmodifiable(_commandHistory);
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastHeardText => _lastHeardText;
  String? get feedbackMessage => _feedbackMessage;
  List<VoiceCommandTemplate> get availableCommands =>
      VoiceCommandTemplate.availableCommands;

  /// Start listening for voice input.
  void startListening() {
    _isListening = true;
    _feedbackMessage = 'Listening...';
    notifyListeners();

    // TODO: Replace with actual speech_to_text integration
    // _speechToText.listen(onResult: _onSpeechResult);
  }

  /// Stop listening.
  void stopListening() {
    _isListening = false;
    _feedbackMessage = null;
    notifyListeners();
  }

  /// Process recognized speech text.
  void processCommand(String text) {
    _lastHeardText = text;
    final lowerText = text.toLowerCase();

    String? matchedAction;
    double confidence = 0.0;

    // Match against known command templates
    for (final template in VoiceCommandTemplate.availableCommands) {
      for (final phrase in template.triggerPhrases) {
        if (lowerText.contains(phrase.toLowerCase())) {
          matchedAction = template.action;
          confidence = 0.9;
          break;
        }
      }
      if (matchedAction != null) break;
    }

    final command = VoiceCommand(
      id: 'vc-${DateTime.now().millisecondsSinceEpoch}',
      rawText: text,
      interpretedAction: matchedAction,
      confidence: confidence,
      timestamp: DateTime.now(),
      executed: matchedAction != null,
    );

    _commandHistory.insert(0, command);

    if (matchedAction != null) {
      _feedbackMessage = 'Executing: ${_describeAction(matchedAction)}';
    } else {
      _feedbackMessage = 'Command not recognized: "$text"';
    }

    notifyListeners();
  }

  /// Speak text aloud using TTS.
  void speak(String text) {
    _isSpeaking = true;
    _feedbackMessage = 'Speaking: $text';
    notifyListeners();

    // TODO: Replace with actual flutter_tts integration
    // _tts.speak(text);

    // Simulate TTS completion
    Future.delayed(const Duration(seconds: 2), () {
      _isSpeaking = false;
      _feedbackMessage = null;
      notifyListeners();
    });
  }

  void clearHistory() {
    _commandHistory.clear();
    notifyListeners();
  }

  String _describeAction(String action) {
    switch (action) {
      case 'update_status_en_route':
        return 'Marking you as En Route';
      case 'update_status_on_scene':
        return 'Marking you as On Scene';
      case 'update_status_in_progress':
        return 'Marking job as In Progress';
      case 'update_status_completed':
        return 'Marking job as Completed';
      case 'call_dispatch':
        return 'Calling Dispatch...';
      case 'take_photo':
        return 'Opening Camera...';
      case 'read_job':
        return 'Reading job details...';
      default:
        return action;
    }
  }
}
