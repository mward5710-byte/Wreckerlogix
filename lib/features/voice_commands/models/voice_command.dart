/// Represents a voice command recognized by the voice engine.
class VoiceCommand {
  final String id;
  final String rawText;
  final String? interpretedAction; // e.g., 'update_status', 'navigate_to', 'call_dispatch'
  final Map<String, String> parameters; // e.g., {'status': 'on_scene', 'jobId': '123'}
  final double confidence;
  final DateTime timestamp;
  final bool executed;

  const VoiceCommand({
    required this.id,
    required this.rawText,
    this.interpretedAction,
    this.parameters = const {},
    this.confidence = 0.0,
    required this.timestamp,
    this.executed = false,
  });

  VoiceCommand copyWith({bool? executed}) {
    return VoiceCommand(
      id: id,
      rawText: rawText,
      interpretedAction: interpretedAction,
      parameters: parameters,
      confidence: confidence,
      timestamp: timestamp,
      executed: executed ?? this.executed,
    );
  }
}

/// Available voice commands and their trigger phrases.
class VoiceCommandTemplate {
  final String action;
  final String description;
  final List<String> triggerPhrases;

  const VoiceCommandTemplate({
    required this.action,
    required this.description,
    required this.triggerPhrases,
  });

  static const List<VoiceCommandTemplate> availableCommands = [
    VoiceCommandTemplate(
      action: 'update_status_en_route',
      description: 'Mark yourself as en route to a job',
      triggerPhrases: ['en route', 'on my way', 'heading out', 'rolling'],
    ),
    VoiceCommandTemplate(
      action: 'update_status_on_scene',
      description: 'Mark yourself as arrived on scene',
      triggerPhrases: ['on scene', 'arrived', 'I\'m here', 'at location'],
    ),
    VoiceCommandTemplate(
      action: 'update_status_in_progress',
      description: 'Mark the job as in progress',
      triggerPhrases: ['in progress', 'hooking up', 'loading', 'starting tow'],
    ),
    VoiceCommandTemplate(
      action: 'update_status_completed',
      description: 'Mark the job as completed',
      triggerPhrases: ['completed', 'done', 'finished', 'delivered', 'dropped off'],
    ),
    VoiceCommandTemplate(
      action: 'call_dispatch',
      description: 'Call the dispatch office',
      triggerPhrases: ['call dispatch', 'call office', 'contact dispatch'],
    ),
    VoiceCommandTemplate(
      action: 'take_photo',
      description: 'Open camera for documentation',
      triggerPhrases: ['take photo', 'take picture', 'open camera', 'snap photo'],
    ),
    VoiceCommandTemplate(
      action: 'read_job',
      description: 'Read current job details aloud',
      triggerPhrases: ['read job', 'job details', 'what\'s the job', 'current job'],
    ),
  ];
}
