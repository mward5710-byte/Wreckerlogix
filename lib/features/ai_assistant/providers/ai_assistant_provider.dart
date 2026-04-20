import 'package:flutter/foundation.dart';
import '../models/ai_message.dart';

/// State management for the AI Assistant — intelligent chat for dispatch ops.
class AiAssistantProvider extends ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isProcessing = false;
  final List<AssistantCapability> _activeCapabilities =
      List.of(AssistantCapability.values);

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;
  List<AssistantCapability> get activeCapabilities =>
      List.unmodifiable(_activeCapabilities);

  AiAssistantProvider() {
    _loadWelcomeMessages();
  }

  /// Send a user message and generate an AI response.
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = AiMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isProcessing = true;
    notifyListeners();

    // Simulate AI processing delay
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _generateResponse(text.trim());
      _messages.add(response);
      _isProcessing = false;
      notifyListeners();
    });
  }

  /// Clear all chat messages and reload welcome messages.
  void clearChat() {
    _messages.clear();
    _loadWelcomeMessages();
    notifyListeners();
  }

  /// Toggle a capability on or off.
  void toggleCapability(AssistantCapability capability) {
    if (_activeCapabilities.contains(capability)) {
      _activeCapabilities.remove(capability);
    } else {
      _activeCapabilities.add(capability);
    }
    notifyListeners();
  }

  /// Generate a contextual AI response based on keyword matching.
  AiMessage _generateResponse(String userText) {
    final lowerText = userText.toLowerCase();

    // Route-related keywords
    if (_containsAny(lowerText, ['route', 'direction', 'navigate', 'fastest', 'shortest', 'optimize route'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '🗺️ I\'ve analyzed current traffic conditions for your active jobs. '
            'Taking I-55 South to Mile Marker 42 will save approximately 12 minutes '
            'compared to the US-66 alternate. Want me to send this route to your GPS?',
        timestamp: DateTime.now(),
        capability: AssistantCapability.routeOptimization,
        metadata: {'suggestedRoute': 'I-55 South', 'estimatedSavings': '12 min'},
      );
    }

    // HOS / hours-of-service keywords
    if (_containsAny(lowerText, ['hours', 'hos', 'drive time', 'log', 'eld', 'break', 'rest'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '⏱️ Based on your current ELD data, you have 4 hours 23 minutes of '
            'available drive time remaining today. You\'ll need a mandatory 30-minute '
            'break by 3:45 PM. I\'ll remind you 15 minutes before.',
        timestamp: DateTime.now(),
        capability: AssistantCapability.hosWarning,
        metadata: {'remainingDriveTime': '4h 23m', 'breakDueBy': '3:45 PM'},
      );
    }

    // Maintenance keywords
    if (_containsAny(lowerText, ['maintenance', 'repair', 'oil', 'tire', 'brake', 'inspection', 'service'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '🔧 Upcoming maintenance for Truck #127:\n'
            '• Oil change — due in 340 miles\n'
            '• Tire rotation — due next week\n'
            '• Annual DOT inspection — due in 18 days\n\n'
            'Would you like me to schedule any of these with the shop?',
        timestamp: DateTime.now(),
        capability: AssistantCapability.maintenanceReminder,
        metadata: {'truckId': 'truck-127', 'nextServiceMiles': '340'},
      );
    }

    // Weather keywords
    if (_containsAny(lowerText, ['weather', 'rain', 'storm', 'snow', 'ice', 'wind', 'forecast'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '🌧️ Weather alert for your area:\n'
            '• Current: 45°F, light rain\n'
            '• Next 2 hours: Heavy rain expected, 15–20 mph winds\n'
            '• Advisory: Reduced visibility on I-55 corridor\n\n'
            'Consider adding extra time for your next dispatch.',
        timestamp: DateTime.now(),
        capability: AssistantCapability.weatherAlert,
        metadata: {'temperature': '45°F', 'condition': 'rain'},
      );
    }

    // Traffic keywords
    if (_containsAny(lowerText, ['traffic', 'accident', 'congestion', 'delay', 'road', 'closure'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '🚦 Current traffic conditions:\n'
            '• I-55 South: 15 min delay near Exit 98 (accident cleared, residual)\n'
            '• US-66 West: Clear, normal flow\n'
            '• Downtown Springfield: Moderate congestion on 6th Street\n\n'
            'I\'ll update you if conditions change on your active routes.',
        timestamp: DateTime.now(),
        capability: AssistantCapability.trafficUpdate,
        metadata: {'majorDelay': 'I-55 South, 15 min'},
      );
    }

    // Job / dispatch keywords
    if (_containsAny(lowerText, ['job', 'dispatch', 'tow', 'call', 'pickup', 'assignment', 'recommend'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '📋 Here are your current job recommendations:\n'
            '• HIGH: Flatbed request — 1234 Oak Street (2.3 mi away)\n'
            '• MEDIUM: Light-duty tow — I-72 Mile Marker 15 (8.1 mi)\n'
            '• LOW: Vehicle lockout — 567 Elm Ave (0.8 mi)\n\n'
            'The Oak Street job matches your current equipment and proximity.',
        timestamp: DateTime.now(),
        capability: AssistantCapability.jobRecommendation,
        metadata: {'topJobId': 'job-pending-042', 'distance': '2.3 mi'},
      );
    }

    // Compliance keywords
    if (_containsAny(lowerText, ['compliance', 'regulation', 'dot', 'legal', 'permit', 'license', 'violation'])) {
      return AiMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content:
            '✅ Compliance status overview:\n'
            '• CDL: Valid through 08/2026\n'
            '• DOT medical card: Valid through 03/2025\n'
            '• Vehicle registration: Current\n'
            '• Insurance: Active, next renewal 01/2025\n\n'
            'All items are in good standing. I\'ll alert you 30 days before any expiration.',
        timestamp: DateTime.now(),
        capability: AssistantCapability.complianceCheck,
        metadata: {'nextExpiry': 'DOT medical 03/2025'},
      );
    }

    // Fallback — general help
    return AiMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.assistant,
      content:
          '👋 I can help you with several things:\n\n'
          '🗺️ **Route Optimization** — find the fastest route\n'
          '📋 **Job Recommendations** — prioritize nearby jobs\n'
          '✅ **Compliance Checks** — verify DOT/CDL status\n'
          '🌧️ **Weather Alerts** — conditions along your route\n'
          '🚦 **Traffic Updates** — delays and road closures\n'
          '🔧 **Maintenance Reminders** — upcoming service items\n'
          '⏱️ **HOS Warnings** — drive time and break alerts\n\n'
          'Just ask about any of these topics and I\'ll get you the latest info!',
      timestamp: DateTime.now(),
      capability: AssistantCapability.generalHelp,
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  void _loadWelcomeMessages() {
    _messages.addAll([
      AiMessage(
        id: 'msg-welcome-1',
        role: MessageRole.system,
        content: 'AI Assistant initialized — all capabilities active.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      AiMessage(
        id: 'msg-welcome-2',
        role: MessageRole.assistant,
        content:
            '👋 Hey there! I\'m your WreckerLogix AI Assistant. I can help with '
            'route optimization, job recommendations, HOS tracking, weather alerts, '
            'and more. What can I help you with today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        capability: AssistantCapability.generalHelp,
      ),
      AiMessage(
        id: 'msg-welcome-3',
        role: MessageRole.assistant,
        content:
            '💡 Tip: Try asking "Optimize my route", "Check my hours", or '
            '"Any maintenance due?" to get started quickly.',
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
        capability: AssistantCapability.generalHelp,
      ),
    ]);
  }
}
