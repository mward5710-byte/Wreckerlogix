import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voice_command.dart';
import '../providers/voice_command_provider.dart';

/// Voice command screen — hands-free operation for drivers.
class VoiceCommandScreen extends StatelessWidget {
  const VoiceCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Commands'),
        actions: [
          Consumer<VoiceCommandProvider>(
            builder: (context, vc, _) {
              if (vc.commandHistory.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => vc.clearHistory(),
                  tooltip: 'Clear History',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<VoiceCommandProvider>(
        builder: (context, vc, _) {
          return Column(
            children: [
              // Big mic button area
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withAlpha(20),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Feedback text
                      if (vc.feedbackMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            vc.feedbackMessage!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),

                      // Last heard text
                      if (vc.lastHeardText.isNotEmpty && !vc.isListening)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            '"${vc.lastHeardText}"',
                            style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Mic button
                      GestureDetector(
                        onTap: () {
                          if (vc.isListening) {
                            vc.stopListening();
                          } else {
                            vc.startListening();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: vc.isListening ? 140 : 120,
                          height: vc.isListening ? 140 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: vc.isListening ? Colors.red : const Color(0xFF6A1B9A),
                            boxShadow: [
                              BoxShadow(
                                color: (vc.isListening ? Colors.red : const Color(0xFF6A1B9A))
                                    .withAlpha(100),
                                blurRadius: vc.isListening ? 30 : 15,
                                spreadRadius: vc.isListening ? 5 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            vc.isListening ? Icons.mic : Icons.mic_none,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vc.isListening ? 'Tap to stop' : 'Tap to speak',
                        style: TextStyle(color: Colors.grey[600]),
                      ),

                      // Quick demo input for development
                      const SizedBox(height: 20),
                      _QuickCommandBar(vc: vc),
                    ],
                  ),
                ),
              ),

              // Available commands reference
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text('Available Commands',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                  ],
                ),
              ),

              // Command reference list
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ...VoiceCommandTemplate.availableCommands.map((cmd) =>
                        _CommandRefTile(template: cmd)),
                    const SizedBox(height: 8),
                    if (vc.commandHistory.isNotEmpty) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('Recent Commands',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700])),
                      ),
                      ...vc.commandHistory.take(5).map((cmd) =>
                          _CommandHistoryTile(command: cmd)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickCommandBar extends StatelessWidget {
  final VoiceCommandProvider vc;

  const _QuickCommandBar({required this.vc});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _QuickChip(label: 'En route', onTap: () => vc.processCommand('en route')),
        _QuickChip(label: 'On scene', onTap: () => vc.processCommand('on scene')),
        _QuickChip(label: 'Completed', onTap: () => vc.processCommand('completed')),
        _QuickChip(label: 'Take photo', onTap: () => vc.processCommand('take photo')),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      avatar: const Icon(Icons.play_arrow, size: 16),
    );
  }
}

class _CommandRefTile extends StatelessWidget {
  final VoiceCommandTemplate template;

  const _CommandRefTile({required this.template});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.record_voice_over, size: 20),
        title: Text(template.description, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          'Say: "${template.triggerPhrases.join('", "')}"',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ),
    );
  }
}

class _CommandHistoryTile extends StatelessWidget {
  final VoiceCommand command;

  const _CommandHistoryTile({required this.command});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        command.executed ? Icons.check_circle : Icons.help_outline,
        color: command.executed ? Colors.green : Colors.orange,
        size: 20,
      ),
      title: Text('"${command.rawText}"', style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        command.interpretedAction ?? 'Unrecognized',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
      trailing: Text(
        '${command.confidence * 100}%',
        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
      ),
    );
  }
}
