import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_theme.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;
  final bool isRecording;

  const VoiceRecorderWidget({
    super.key,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
    this.isRecording = false,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  Duration _recordingDuration = Duration.zero;
  late Stream<Duration> _durationStream;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    if (widget.isRecording) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(VoiceRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording && !oldWidget.isRecording) {
      _startAnimations();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
    
    // Start duration timer
    _durationStream = Stream.periodic(
      const Duration(seconds: 1),
      (count) => Duration(seconds: count + 1),
    );
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
    _recordingDuration = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return _buildRecordButton();
    }
    
    return _buildRecordingInterface();
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: widget.onStartRecording,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          FontAwesomeIcons.microphone,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          GestureDetector(
            onTap: widget.onCancelRecording,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Recording animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Duration and waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<Duration>(
                  stream: _durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 4),
                
                // Animated waveform
                _buildWaveform(),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Send button
          GestureDetector(
            onTap: widget.onStopRecording,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          children: List.generate(20, (index) {
            final animationOffset = (index * 0.1) % 1.0;
            final waveValue = (_waveAnimation.value + animationOffset) % 1.0;
            final height = 2 + (waveValue * 8);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 2,
              height: height,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}