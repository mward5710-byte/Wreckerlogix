/// Role of a message in the AI assistant conversation.
enum MessageRole { user, assistant, system }

/// Capability areas the AI assistant can help with.
enum AssistantCapability {
  routeOptimization,
  jobRecommendation,
  complianceCheck,
  weatherAlert,
  trafficUpdate,
  maintenanceReminder,
  hosWarning,
  generalHelp,
}

/// Represents a single message in the AI assistant chat.
class AiMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final AssistantCapability? capability;
  final Map<String, String> metadata;
  final bool isLoading;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.capability,
    this.metadata = const {},
    this.isLoading = false,
  });

  AiMessage copyWith({
    String? content,
    bool? isLoading,
  }) {
    return AiMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      capability: capability,
      metadata: metadata,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Human-readable label for the capability area.
  String get capabilityLabel {
    if (capability == null) return '';
    switch (capability!) {
      case AssistantCapability.routeOptimization:
        return 'Route Optimization';
      case AssistantCapability.jobRecommendation:
        return 'Job Recommendation';
      case AssistantCapability.complianceCheck:
        return 'Compliance Check';
      case AssistantCapability.weatherAlert:
        return 'Weather Alert';
      case AssistantCapability.trafficUpdate:
        return 'Traffic Update';
      case AssistantCapability.maintenanceReminder:
        return 'Maintenance Reminder';
      case AssistantCapability.hosWarning:
        return 'HOS Warning';
      case AssistantCapability.generalHelp:
        return 'General Help';
    }
  }

  /// Time ago label for display.
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year % 100}';
  }
}
