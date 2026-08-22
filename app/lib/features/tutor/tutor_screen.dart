import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../voice/services/voice_service.dart';
import 'services/onnx_tutor_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final String timestamp;
  final Duration? latency;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.latency,
  });
}

class TutorScreen extends StatefulWidget {
  final String? initialPrompt;

  const TutorScreen({super.key, this.initialPrompt});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OnnxTutorService _tutorService = OnnxTutorService();
  final VoiceService _voiceService = VoiceService();

  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  bool _isListening = false;
  String? _currentlySpeakingMessageId;

  @override
  void initState() {
    super.initState();
    _tutorService.initialize();
    _voiceService.initialize();

    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        text: 'Hello! I am your offline AI tutor. Ask me any question using text or voice.',
        isUser: false,
        timestamp: 'Just now',
      ),
    );

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _controller.text = widget.initialPrompt!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _voiceService.stopSpeaking();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty || _isProcessing) return;

    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isUser: true,
          timestamp: timeString,
        ),
      );
      _isProcessing = true;
    });

    if (customText == null) {
      _controller.clear();
    }
    _scrollToBottom();

    final response = await _tutorService.askQuestion(text);

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            text: response.text,
            isUser: false,
            timestamp: timeString,
            latency: response.inferenceLatency,
          ),
        );
        _isProcessing = false;
      });
      _scrollToBottom();
    }
  }

  void _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening(
        onStateChanged: (state) {
          if (mounted) setState(() => _isListening = state);
        },
      );
    } else {
      await _voiceService.startListening(
        onResult: (spokenText) {
          if (mounted) {
            _controller.text = spokenText;
          }
        },
        onStateChanged: (state) {
          if (mounted) setState(() => _isListening = state);
        },
      );
      // Simulate quick spoken input in environment
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listening... (Speech-to-Text active)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _speakMessage(ChatMessage msg) async {
    if (_currentlySpeakingMessageId == msg.id) {
      await _voiceService.stopSpeaking();
      if (mounted) {
        setState(() => _currentlySpeakingMessageId = null);
      }
    } else {
      setState(() => _currentlySpeakingMessageId = msg.id);
      await _voiceService.speak(
        msg.text,
        onComplete: () {
          if (mounted) {
            setState(() => _currentlySpeakingMessageId = null);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline AI Tutor'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: OfflineStatusIndicator(status: SyncStatus.offline),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                _buildQuickChip('Scientific Method'),
                const SizedBox(width: 8),
                _buildQuickChip('Photosynthesis'),
                const SizedBox(width: 8),
                _buildQuickChip('Solar System'),
                const SizedBox(width: 8),
                _buildQuickChip('Fractions & Math'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI Tutor is generating answer locally...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      onPressed: () => _sendMessage('Explain $label in simple terms'),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isSpeakingThis = _currentlySpeakingMessageId == msg.id;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: msg.isUser
                ? AppColors.primary
                : (isSpeakingThis ? AppColors.primary : AppColors.border),
            width: isSpeakingThis ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: msg.isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.timestamp,
                  style: TextStyle(
                    fontSize: 11,
                    color: msg.isUser ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                if (!msg.isUser) ...[
                  if (msg.latency != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '• ${msg.latency!.inMilliseconds}ms (ONNX)',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _speakMessage(msg),
                    child: Icon(
                      isSpeakingThis ? Icons.volume_up : Icons.volume_up_outlined,
                      size: 18,
                      color: isSpeakingThis ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none_rounded,
                color: _isListening ? AppColors.error : AppColors.primary,
              ),
              tooltip: _isListening ? 'Stop listening' : 'Speak your question',
              onPressed: _toggleVoiceInput,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Type or speak your question...',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              tooltip: 'Send',
              onPressed: () => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}
