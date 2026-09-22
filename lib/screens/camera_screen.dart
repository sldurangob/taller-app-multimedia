import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback onClose;

  const CameraScreen({
    super.key,
    required this.onClose,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  VideoPlayerController? _videoController;

  List<CameraDescription> _cameras = [];

  int _cameraIndex = 0;

  FlashMode _flashMode = FlashMode.off;

  bool _isInitializing = true;
  bool _isRecording = false;
  bool _isSaving = false;

  bool _vibrationEnabled = true;
  bool _autoFlashEnabled = false;

  XFile? _capturedFile;
  bool _capturedIsVideo = false;

  @override
  void initState() {
    super.initState();
    _loadCameraSettings();
  }

  Future<void> _loadCameraSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _vibrationEnabled =
        prefs.getBool('vibration_enabled') ?? true;

    _autoFlashEnabled =
        prefs.getBool('auto_flash_enabled') ?? false;

    if (!mounted) return;

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return;
      }

      await _setupCamera(_cameraIndex);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupCamera(int index) async {
    await _controller?.dispose();

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
    );

    _controller = controller;

    try {
      await controller.initialize();

      if (_autoFlashEnabled) {
        try {
          await controller.setFlashMode(FlashMode.auto);
          _flashMode = FlashMode.auto;
        } catch (_) {
          _flashMode = FlashMode.off;
        }
      } else {
        try {
          await controller.setFlashMode(_flashMode);
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _reloadCameraSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final vibrationEnabled =
        prefs.getBool('vibration_enabled') ?? true;

    final autoFlashEnabled =
        prefs.getBool('auto_flash_enabled') ?? false;

    if (!mounted) return;

    setState(() {
      _vibrationEnabled = vibrationEnabled;
      _autoFlashEnabled = autoFlashEnabled;
    });

    if (_controller != null &&
        _controller!.value.isInitialized &&
        !_isRecording &&
        _autoFlashEnabled) {
      try {
        await _controller!.setFlashMode(FlashMode.auto);

        if (!mounted) return;

        setState(() {
          _flashMode = FlashMode.auto;
        });
      } catch (_) {}
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;

    if (_vibrationEnabled) {
      await HapticFeedback.selectionClick();
    }

    setState(() {
      _isInitializing = true;
    });

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _setupCamera(_cameraIndex);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording) {
      return;
    }

    FlashMode nextMode;

    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off;
        break;
    }

    try {
      await _controller!.setFlashMode(nextMode);

      if (mounted) {
        setState(() {
          _flashMode = nextMode;
        });
      }
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording ||
        _isSaving ||
        _capturedFile != null) {
      return;
    }

    try {
      await _reloadCameraSettings();

      if (_autoFlashEnabled) {
        try {
          await _controller!.setFlashMode(FlashMode.auto);
          _flashMode = FlashMode.auto;
        } catch (_) {}
      }

      final file = await _controller!.takePicture();

      await _incrementPhotoCount();

      if (_vibrationEnabled) {
        await HapticFeedback.mediumImpact();
      }

      if (!mounted) return;

      setState(() {
        _capturedFile = file;
        _capturedIsVideo = false;
      });
    } catch (_) {}
  }

  Future<void> _startRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording ||
        _isSaving ||
        _capturedFile != null) {
      return;
    }

    try {
      await _reloadCameraSettings();

      await _controller!.startVideoRecording();

      if (_vibrationEnabled) {
        await HapticFeedback.mediumImpact();
      }

      if (mounted) {
        setState(() {
          _isRecording = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;

    try {
      final file = await _controller!.stopVideoRecording();

      await _incrementVideoCount();

      if (_vibrationEnabled) {
        await HapticFeedback.mediumImpact();
      }

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _capturedFile = file;
        _capturedIsVideo = true;
      });

      await _initializeVideoPreview(file.path);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  Future<void> _incrementPhotoCount() async {
    final prefs = await SharedPreferences.getInstance();

    final currentCount =
        prefs.getInt('photos_count') ?? 0;

    await prefs.setInt(
      'photos_count',
      currentCount + 1,
    );
  }

  Future<void> _incrementVideoCount() async {
    final prefs = await SharedPreferences.getInstance();

    final currentCount =
        prefs.getInt('videos_count') ?? 0;

    await prefs.setInt(
      'videos_count',
      currentCount + 1,
    );
  }

  Future<void> _initializeVideoPreview(String path) async {
    await _videoController?.dispose();

    final controller = VideoPlayerController.file(
      File(path),
    );

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
      });
    } catch (_) {
      await controller.dispose();
    }
  }

  Future<void> _saveCapturedFile() async {
    if (_capturedFile == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        final accessGranted = await Gal.requestAccess();

        if (!accessGranted) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se concedió permiso para guardar en la galería',
              ),
            ),
          );

          return;
        }
      }

      if (_capturedIsVideo) {
        await Gal.putVideo(_capturedFile!.path);
      } else {
        await Gal.putImage(_capturedFile!.path);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardado en la galería'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar en la galería'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _discardCapturedFile() {
    _videoController?.dispose();
    _videoController = null;

    setState(() {
      _capturedFile = null;
      _capturedIsVideo = false;
    });
  }

  void _handleCameraSwipeEnd(DragEndDetails details) {
    if (_capturedFile != null || _isRecording) return;

    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -500) {
      widget.onClose();
    }
  }

  Widget _buildCapturedPreview() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_capturedIsVideo)
            Center(
              child: Image.file(
                File(_capturedFile!.path),
                fit: BoxFit.contain,
              ),
            )
          else if (_videoController != null &&
              _videoController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio:
                    _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _discardCapturedFile,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isSaving ? null : _saveCapturedFile,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_capturedIsVideo &&
                    _videoController != null &&
                    _videoController!.value.isInitialized)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_videoController!
                            .value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamera() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_controller == null ||
        !_controller!.value.isInitialized) {
      return const Center(
        child: Text(
          'No se pudo iniciar la cámara',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _flashMode == FlashMode.off
                          ? Icons.flash_off
                          : _flashMode == FlashMode.auto
                              ? Icons.flash_auto
                              : Icons.flash_on,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'GRABANDO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed:
                        _isRecording ? null : _switchCamera,
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: _takePicture,
                    onLongPress: _startRecording,
                    onLongPressUp: _stopRecording,
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 150),
                      width: _isRecording ? 82 : 76,
                      height: _isRecording ? 82 : 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 150),
                          width: _isRecording ? 42 : 62,
                          height: _isRecording ? 42 : 62,
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? Colors.red
                                : Colors.white,
                            shape: _isRecording
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: _isRecording
                                ? BorderRadius.circular(8)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                _isRecording
                    ? 'Suelta para detener'
                    : 'Toca para foto · Mantén para video',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleCameraSwipeEnd,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _capturedFile != null
            ? _buildCapturedPreview()
            : _buildCamera(),
      ),
    );
  }
}