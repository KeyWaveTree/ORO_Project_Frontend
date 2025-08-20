import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const PronounceRightApp());
}

class PronounceRightApp extends StatelessWidget {
  const PronounceRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PronounceRight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  String currentWord = '';
  AppStatus status = AppStatus.idle;
  String feedback = '';
  bool isRecording = false;
  
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> sampleWords = [
    'pronunciation',
    'beautiful', 
    'wonderful',
    'communication',
    'international',
    'education'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleStartRecording() async {
    if (currentWord.isEmpty || isRecording) return;
    
    HapticFeedback.lightImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());
    
    setState(() {
      isRecording = true;
      status = AppStatus.listening;
      feedback = 'Listening...';
    });
    
    _pulseController.repeat(reverse: true);
    
    // Simulate recording process
    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() {
      status = AppStatus.processing;
      feedback = 'Analyzing pronunciation...';
    });
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Simulate AI feedback with 70% success rate
    final isCorrect = Random().nextDouble() > 0.3;
    
    setState(() {
      if (isCorrect) {
        status = AppStatus.success;
        feedback = 'Great pronunciation!';
      } else {
        status = AppStatus.error;
        feedback = 'Try again - focus on the vowel sounds';
      }
      isRecording = false;
    });
    
    _pulseController.stop();
    _pulseController.reset();
    
    // Reset after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          status = AppStatus.idle;
          feedback = '';
        });
      }
    });
  }

  void _handleReset() {
    setState(() {
      currentWord = '';
      status = AppStatus.idle;
      feedback = '';
      isRecording = false;
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  Color _getStatusColor() {
    switch (status) {
      case AppStatus.listening:
        return Colors.blue.shade50;
      case AppStatus.processing:
        return Colors.orange.shade50;
      case AppStatus.success:
        return Colors.green.shade50;
      case AppStatus.error:
        return Colors.red.shade50;
      default:
        return Colors.white;
    }
  }

  Color _getStatusBorderColor() {
    switch (status) {
      case AppStatus.listening:
        return Colors.blue.shade300;
      case AppStatus.processing:
        return Colors.orange.shade300;
      case AppStatus.success:
        return Colors.green.shade300;
      case AppStatus.error:
        return Colors.red.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  Widget _getStatusIcon() {
    switch (status) {
      case AppStatus.listening:
        return Icon(Icons.mic, color: Colors.blue.shade600, size: 16);
      case AppStatus.processing:
        return Icon(Icons.refresh, color: Colors.orange.shade600, size: 16);
      case AppStatus.success:
        return Icon(Icons.check_circle, color: Colors.green.shade600, size: 16);
      case AppStatus.error:
        return Icon(Icons.error, color: Colors.red.shade600, size: 16);
      default:
        return Icon(Icons.volume_up, color: Colors.grey.shade400, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              SlateColors.slate.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    const SizedBox(height: 32),
                    Text(
                      'PronounceRight',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perfect your pronunciation with AI-powered feedback',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Word Selection
                    if (currentWord.isEmpty) ...[
                      Text(
                        'Choose a word to practice:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: sampleWords.map((word) => 
                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => currentWord = word),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 12
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  word,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 48),
                    ],
                    
                    // Central Recording Area
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (currentWord.isNotEmpty) ...[
                              Text(
                                'Practice:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentWord,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap the microphone to record your pronunciation',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              Text(
                                'Ready to Practice?',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select a word above to get started',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 40),
                            
                            // Recording Button
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentWord.isNotEmpty && !isRecording
                                        ? Colors.blue.shade500
                                        : isRecording
                                            ? Colors.red.shade500
                                            : Colors.grey.shade300,
                                    boxShadow: currentWord.isNotEmpty
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.mic,
                                    size: 48,
                                    color: currentWord.isNotEmpty
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isRecording ? _pulseAnimation.value : 1.0,
                                    child: child,
                                  );
                                },
                              ),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(60),
                                      onTap: _handleStartRecording,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            Text(
                              isRecording
                                  ? 'Recording... speak clearly'
                                  : currentWord.isNotEmpty
                                      ? 'Tap to record'
                                      : 'Select a word first',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How it works:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionStep(
                            '1',
                            'Select a word you\'d like to practice pronouncing',
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            '2',
                            'Tap the microphone button and speak the word clearly',
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            '3',
                            'Receive instant feedback and suggestions for improvement',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Status Window - Top Left
            Positioned(
              top: 24,
              left: 16,
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusBorderColor(),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _getStatusIcon(),
                        const SizedBox(width: 8),
                        Text(
                          'Status Window',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    
                    if (currentWord.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Current Word:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentWord,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                    
                    if (feedback.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Feedback:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feedback,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    
                    if (status == AppStatus.idle && currentWord.isEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Select a word and start practicing!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    
                    if (currentWord.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _handleReset,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 12,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reset',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

enum AppStatus {
  idle,
  listening,
  processing,
  success,
  error,
}

// Extension to add slate colors to Flutter's Colors class
extension SlateColors on Colors {
  static const MaterialColor slate = MaterialColor(
    0xFFF8FAFC,
    <int, Color>{
      50: Color(0xFFF8FAFC),
      100: Color(0xFFF1F5F9),
      200: Color(0xFFE2E8F0),
      300: Color(0xFFCBD5E1),
      400: Color(0xFF94A3B8),
      500: Color(0xFF64748B),
      600: Color(0xFF475569),
      700: Color(0xFF334155),
      800: Color(0xFF1E293B),
      900: Color(0xFF0F172A),
    },
  );
}