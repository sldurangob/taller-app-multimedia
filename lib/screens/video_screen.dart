import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;

  bool _showControls = true;
  bool _isLiked = false;
  bool _isSaved = false;

  String _videoName = 'Video de ejemplo';

  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _loadExampleVideo();
  }

  Future<void> _loadExampleVideo() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
    );

    try {
      await controller.initialize();
      await controller.setLooping(false);

      controller.addListener(_videoListener);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _videoName = 'Video de ejemplo';
      });

      await _loadVideoState();
    } catch (_) {
      await controller.dispose();

      if (mounted) {
        _showError('No se pudo cargar el video de ejemplo.');
      }
    }
  }

  void _videoListener() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.path == null) {
        _showError('No se pudo obtener el archivo seleccionado.');
        return;
      }

      final path = file.path!;

      final newController = VideoPlayerController.file(
        File(path),
      );

      try {
        await newController.initialize();
        await newController.setLooping(false);
      } catch (_) {
        await newController.dispose();

        if (mounted) {
          _showError(
            'No se pudo reproducir el video seleccionado.',
          );
        }

        return;
      }

      newController.addListener(_videoListener);

      final oldController = _controller;

      if (mounted) {
        setState(() {
          _controller = newController;
          _videoName = file.name;
          _showControls = true;
          _isLiked = false;
          _isSaved = false;
        });
      }

      _controlsTimer?.cancel();

      if (oldController != null) {
        oldController.removeListener(_videoListener);
        await oldController.dispose();
      }

      await _loadVideoState();
    } catch (_) {
      if (mounted) {
        _showError('Error al seleccionar el video.');
      }
    }
  }

  Future<void> _loadVideoState() async {
    final prefs = await SharedPreferences.getInstance();

    final likedVideos = prefs.getStringList('liked_videos') ?? [];
    final savedVideos = prefs.getStringList('saved_videos') ?? [];

    if (!mounted) return;

    setState(() {
      _isLiked = likedVideos.contains(_videoName);
      _isSaved = savedVideos.contains(_videoName);
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();

    final likedVideos =
        prefs.getStringList('liked_videos') ?? [];

    if (_isLiked) {
      likedVideos.remove(_videoName);
    } else if (!likedVideos.contains(_videoName)) {
      likedVideos.add(_videoName);
    }

    await prefs.setStringList(
      'liked_videos',
      likedVideos,
    );

    if (!mounted) return;

    setState(() {
      _isLiked = !_isLiked;
    });
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();

    final savedVideos =
        prefs.getStringList('saved_videos') ?? [];

    if (_isSaved) {
      savedVideos.remove(_videoName);
    } else if (!savedVideos.contains(_videoName)) {
      savedVideos.add(_videoName);
    }

    await prefs.setStringList(
      'saved_videos',
      savedVideos,
    );

    if (!mounted) return;

    setState(() {
      _isSaved = !_isSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved
              ? 'Video guardado'
              : 'Video eliminado de guardados',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    if (_isVideoFinished()) {
      await controller.seekTo(Duration.zero);
      await controller.play();

      _startControlsTimer();
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();

      _controlsTimer?.cancel();

      if (mounted) {
        setState(() {
          _showControls = true;
        });
      }
    } else {
      await controller.play();

      _startControlsTimer();
    }
  }

  void _showControlsTemporarily() {
    if (!mounted) return;

    setState(() {
      _showControls = true;
    });

    _startControlsTimer();
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();

    _controlsTimer = Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        final controller = _controller;

        if (controller != null &&
            controller.value.isInitialized &&
            controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      },
    );
  }

  bool _isVideoFinished() {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return false;
    }

    return controller.value.position >=
        controller.value.duration;
  }

  void _shareVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir seleccionada'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();

    _controller?.removeListener(_videoListener);
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reproductor de video',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          if (controller == null ||
              !controller.value.isInitialized)
            const SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            GestureDetector(
              onTap: _showControlsTemporarily,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: VideoPlayer(controller),
                    ),
                    if (_showControls)
                      Center(
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(170),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isVideoFinished()
                                  ? Icons.replay
                                  : controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                    if (_showControls)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(210),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              VideoProgressIndicator(
                                controller,
                                allowScrubbing: true,
                                padding: EdgeInsets.zero,
                                colors:
                                    const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.white54,
                                  backgroundColor: Colors.white30,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(
                                      controller.value.position,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(
                                      controller.value.duration,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _videoName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _toggleLike,
                    child: Column(
                      children: [
                        Icon(
                          _isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isLiked
                              ? Colors.red
                              : colorScheme.onSurface,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Me gusta',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _shareVideo,
                    child: Column(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: colorScheme.onSurface,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Compartir',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _toggleSave,
                    child: Column(
                      children: [
                        Icon(
                          _isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _isSaved
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(
                Icons.video_library,
              ),
              label: const Text(
                'Cargar video',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}