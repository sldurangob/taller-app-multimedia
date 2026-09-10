import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  // ----------------------------------------------------------
  // VIDEO DE EJEMPLO
  // ----------------------------------------------------------

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
    } catch (e) {
      await controller.dispose();

      if (mounted) {
        _showError('No se pudo cargar el video de ejemplo.');
      }
    }
  }

  // ----------------------------------------------------------
  // LISTENER DEL VIDEO
  // ----------------------------------------------------------

  void _videoListener() {
    if (!mounted) return;

    setState(() {});
  }

  // ----------------------------------------------------------
  // SELECCIONAR VIDEO
  // ----------------------------------------------------------

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
      } catch (e) {
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
        });
      }

      _controlsTimer?.cancel();

      if (oldController != null) {
        oldController.removeListener(_videoListener);
        await oldController.dispose();
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al seleccionar el video.');
      }
    }
  }

  // ----------------------------------------------------------
  // PLAY / PAUSA
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // CONTROLES
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // VIDEO TERMINADO
  // ----------------------------------------------------------

  bool _isVideoFinished() {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return false;
    }

    return controller.value.position >=
        controller.value.duration;
  }

  // ----------------------------------------------------------
  // ME GUSTA
  // ----------------------------------------------------------

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  // ----------------------------------------------------------
  // GUARDAR
  // ----------------------------------------------------------

  void _toggleSave() {
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

  // ----------------------------------------------------------
  // COMPARTIR
  // ----------------------------------------------------------

  void _shareVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir seleccionada'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ----------------------------------------------------------
  // FORMATO DE TIEMPO
  // ----------------------------------------------------------

  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ----------------------------------------------------------
  // ERROR
  // ----------------------------------------------------------

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void dispose() {
    _controlsTimer?.cancel();

    _controller?.removeListener(_videoListener);
    _controller?.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const Text(
            'Reproductor de video',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // REPRODUCTOR
          // --------------------------------------------------

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

                    // VIDEO
                    Positioned.fill(
                      child: VideoPlayer(controller),
                    ),

                    // BOTÓN PLAY / PAUSA
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

                    // CONTROLES INFERIORES
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

          // --------------------------------------------------
          // NOMBRE DEL VIDEO
          // --------------------------------------------------

          Text(
            _videoName,

            textAlign: TextAlign.center,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // ME GUSTA / COMPARTIR / GUARDAR
          // --------------------------------------------------

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

              children: [

                // ME GUSTA
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
                              : Colors.black87,

                          size: 28,
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Me gusta',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // COMPARTIR
                Expanded(
                  child: InkWell(
                    onTap: _shareVideo,

                    child: const Column(
                      children: [

                        Icon(
                          Icons.share_outlined,
                          size: 28,
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Compartir',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // GUARDAR
                Expanded(
                  child: InkWell(
                    onTap: _toggleSave,

                    child: Column(
                      children: [

                        Icon(
                          _isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,

                          size: 28,
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 12,
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

          // --------------------------------------------------
          // CARGAR VIDEO
          // --------------------------------------------------

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