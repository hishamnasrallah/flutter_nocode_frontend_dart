// lib/presentation/build/build_status_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/application_provider.dart';
import '../../data/models/build_history.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';

class BuildStatusScreen extends StatefulWidget {
  final String applicationId;
  final String buildId;

  const BuildStatusScreen({
    super.key,
    required this.applicationId,
    required this.buildId,
  });

  @override
  State<BuildStatusScreen> createState() => _BuildStatusScreenState();
}

class _BuildStatusScreenState extends State<BuildStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  Timer? _statusTimer;
  BuildHistory? _currentBuild;
  final List<String> _logs = [];
  double _progress = 0.0;
  String _currentStep = 'Initializing...';

  final Map<String, double> _stepProgress = {
    'started': 0.1,
    'generating_code': 0.3,
    'code_generated': 0.5,
    'building_apk': 0.7,
    'success': 1.0,
    'failed': -1.0,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
    _startStatusPolling();
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkBuildStatus();
    });
    _checkBuildStatus(); // Initial check
  }

  Future<void> _checkBuildStatus() async {
    final provider = context.read<ApplicationProvider>();
    // TODO: Implement actual status check API call
    // For now, simulating build progress

    setState(() {
      if (_progress < 1.0) {
        _progress += 0.1;
        _updateCurrentStep(_progress);
        _addLog(_currentStep);
      } else {
        _statusTimer?.cancel();
        _animationController.stop();
      }
    });
  }

  void _updateCurrentStep(double progress) {
    if (progress < 0.2) {
      _currentStep = 'Initializing build environment...';
    } else if (progress < 0.4) {
      _currentStep = 'Generating Flutter code...';
    } else if (progress < 0.6) {
      _currentStep = 'Resolving dependencies...';
    } else if (progress < 0.8) {
      _currentStep = 'Building APK...';
    } else if (progress < 1.0) {
      _currentStep = 'Finalizing build...';
    } else {
      _currentStep = 'Build completed successfully!';
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logs.add('[$timestamp] $message');
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _progress >= 1.0;
    final isFailed = _progress < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Status'),
        actions: [
          if (isComplete)
            TextButton(
              onPressed: () {
                // Download APK
              },
              child: const Text(
                'Download APK',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Build progress card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Status icon
                    _buildStatusIcon(isComplete, isFailed),
                    const SizedBox(height: 24),

                    // Progress indicator
                    if (!isComplete && !isFailed) ...[
                      Stack(
                        children: [
                          SizedBox(
                            height: 8,
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    // Current step
                    const SizedBox(height: 16),
                    Text(
                      _currentStep,
                      style: TextStyle(
                        fontSize: 16,
                        color: isComplete
                            ? AppColors.success
                            : isFailed
                                ? AppColors.error
                                : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Build info
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoItem('Build ID', widget.buildId.substring(0, 8)),
                        _buildInfoItem('Duration', _getFormattedDuration()),
                        _buildInfoItem(
                          'Status',
                          isComplete ? 'Success' : isFailed ? 'Failed' : 'Building',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Build logs
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Build Logs',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.clear_all, size: 20),
                            onPressed: () {
                              setState(() {
                                _logs.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            if (isComplete || isFailed) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  if (isComplete)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Download APK
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download APK'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (isComplete) const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // View source code
                      },
                      icon: const Icon(Icons.code),
                      label: const Text('View Source'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (isFailed) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Retry build
                          setState(() {
                            _progress = 0.0;
                            _logs.clear();
                            _startStatusPolling();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Build'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isComplete, bool isFailed) {
    if (isComplete) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          size: 48,
          color: AppColors.success,
        ),
      );
    } else if (isFailed) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error,
          size: 48,
          color: AppColors.error,
        ),
      );
    } else {
      return AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _progressAnimation.value * 2 * 3.14159,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.build,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getFormattedDuration() {
    // Calculate duration based on start time
    final duration = Duration(seconds: (_progress * 180).toInt());
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}