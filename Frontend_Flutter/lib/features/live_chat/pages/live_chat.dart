import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/features/home/pages/home.dart';
import 'package:ishara/features/home/pages/settings.dart';
import 'package:ishara/features/live_chat/cubit/translation_cubit.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  late final TranslationCubit _translationCubit;

  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _videoReady = false;
  XFile? _recordedVideo;
  String _detectedText = '';
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  static const int _maxRecordingSeconds = 5;

  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _translationCubit = TranslationCubit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _setupCamera(_cameras.first);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    final previousController = _controller;
    final newController = CameraController(camera, ResolutionPreset.high);

    try {
      await newController.initialize();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _controller = newController;
        _isCameraInitialized = true;
      });
      if (previousController != null) {
        await previousController.dispose();
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_isRecording) return;
    final cameras = await availableCameras();
    _isFrontCamera = !_isFrontCamera;
    final selectedCamera = cameras.firstWhere(
      (cam) =>
          cam.lensDirection ==
          (_isFrontCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
    );
    await _controller?.dispose();
    _controller = CameraController(selectedCamera, ResolutionPreset.high);
    await _controller!.initialize();
    if (_isFrontCamera) _isFlashOn = false;
    if (mounted) setState(() {});
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isFrontCamera) return;
    setState(() => _isFlashOn = !_isFlashOn);
    try {
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _startTimer() {
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      setState(() => _recordingSeconds++);
      if (_recordingSeconds >= _maxRecordingSeconds) {
        await _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingSeconds = 0;
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final file = await _controller!.stopVideoRecording();
      _stopTimer();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _videoReady = true;
          _recordedVideo = file;
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _stopTimer();
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      await _stopRecording();
    } else {
      setState(() {
        _videoReady = false;
        _recordedVideo = null;
        _detectedText = '';
      });
      _translationCubit.reset();

      try {
        await _controller!.startVideoRecording();
        _startTimer();
        if (mounted) {
          setState(() => _isRecording = true);
        }
      } catch (e) {
        debugPrint('Error starting recording: $e');
      }
    }
  }

  void _sendVideo() {
    if (_recordedVideo == null) return;
    _translationCubit.translateVideo(_recordedVideo!.path);
  }

  void _clearAll() {
    setState(() {
      _detectedText = '';
      _videoReady = false;
      _recordedVideo = null;
    });
    _translationCubit.reset();
  }

  @override
  void dispose() {
    _translationCubit.close();
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCameraOverlay(TranslationState state) {
    if (state is TranslationLoading) {
      return Container(
        color: Colors.black45,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Translating...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isRecording) {
      final progress = _recordingSeconds / _maxRecordingSeconds;
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? Colors.orange : Colors.redAccent,
              ),
              minHeight: 4,
            ),
          ),
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 0.2),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: value),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_formatTime(_recordingSeconds)} / 00:0$_maxRecordingSeconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_videoReady) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 44,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Send the video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap Send to translate your sign',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No sign detected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Move your hand into frame',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBoxContent(TranslationState state, bool isLoading) {
    if (isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Translating your sign...',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.black38,
            ),
          ),
        ],
      );
    }

    if (state is TranslationError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.userMessage,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Record a new video and try again.',
            style: TextStyle(fontSize: 13, color: Colors.black38),
          ),
        ],
      );
    }

    return Text(
      _detectedText,
      style: const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TranslationCubit, TranslationState>(
      bloc: _translationCubit,
      listener: (context, state) {
        if (state is TranslationSuccess) {
          setState(() {
            _detectedText = state.translatedText;
            _videoReady = false;
            _recordedVideo = null;
          });
        } else if (state is TranslationError) {
          setState(() {
            _videoReady = false;
            _recordedVideo = null;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is TranslationLoading;
        final hasError = state is TranslationError;

        return Scaffold(
          backgroundColor: AppColors.cardBackground,
          body: Column(
            children: [
              // Top Header
              Container(
                width: double.infinity,
                decoration: AppTheme.gradientBackground.copyWith(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Live Chat',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontFamily: 'Fraunces',
                                  color: Colors.white,
                                  fontSize: 32,
                                ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Camera Box
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            color: Colors.black,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_isCameraInitialized && _controller != null)
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width:
                                          _controller!
                                              .value
                                              .previewSize
                                              ?.height ??
                                          1,
                                      height:
                                          _controller!
                                              .value
                                              .previewSize
                                              ?.width ??
                                          1,
                                      child: CameraPreview(_controller!),
                                    ),
                                  ),

                                _buildCameraOverlay(state),

                                // Flash
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!_isFrontCamera)
                                        GestureDetector(
                                          onTap: _toggleFlash,
                                          child: Icon(
                                            _isFlashOn
                                                ? Icons.flash_on
                                                : Icons.flash_off,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Record + Switch
                                Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: isLoading
                                            ? null
                                            : _toggleRecording,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                            gradient: RadialGradient(
                                              colors: _isRecording
                                                  ? [
                                                      Colors.red.shade900,
                                                      Colors.red,
                                                    ]
                                                  : [
                                                      Colors.redAccent,
                                                      Colors.red,
                                                    ],
                                              radius: 0.8,
                                            ),
                                          ),
                                          child: _isRecording
                                              ? const Icon(
                                                  Icons.stop_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                                      Positioned(
                                        right: 20,
                                        child: GestureDetector(
                                          onTap: (isLoading || _isRecording)
                                              ? null
                                              : _switchCamera,
                                          child: Opacity(
                                            opacity: (isLoading || _isRecording)
                                                ? 0.4
                                                : 1.0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.sync,
                                                color: Colors.black,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Message Card
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 6,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 120),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                border: Border.all(
                                  color: hasError
                                      ? Colors.orange.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.15),
                                  width: hasError ? 1.5 : 1.2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.topLeft,
                              child: SingleChildScrollView(
                                child: _buildTextBoxContent(state, isLoading),
                              ),
                            ),
                            const Positioned(
                              top: -8,
                              right: -8,
                              child: Text(
                                '✦',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: -8,
                              left: -8,
                              child: Text(
                                '✦',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Bottom Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 32,
                  left: 40,
                  right: 40,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientEnd,
                      AppColors.gradientMiddle,
                      AppColors.gradientStart,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.reply,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    // Clear
                    GestureDetector(
                      onTap: isLoading ? null : _clearAll,
                      child: Opacity(
                        opacity: isLoading ? 0.4 : 1.0,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),

                    // Send
                    GestureDetector(
                      onTap:
                          (isLoading || _recordedVideo == null || !_videoReady)
                          ? null
                          : _sendVideo,
                      child: AnimatedOpacity(
                        opacity:
                            (_recordedVideo != null &&
                                _videoReady &&
                                !isLoading)
                            ? 1.0
                            : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
