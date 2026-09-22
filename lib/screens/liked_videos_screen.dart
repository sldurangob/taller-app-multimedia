import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedVideosScreen extends StatefulWidget {
  const LikedVideosScreen({super.key});

  @override
  State<LikedVideosScreen> createState() => _LikedVideosScreenState();
}

class _LikedVideosScreenState extends State<LikedVideosScreen> {
  List<String> _likedVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedVideos();
  }

  Future<void> _loadLikedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final videos = prefs.getStringList('liked_videos') ?? [];

    if (!mounted) return;

    setState(() {
      _likedVideos = List<String>.from(videos);
      _isLoading = false;
    });
  }

  Future<void> _removeLike(String videoName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quitar Me gusta'),
          content: Text(
            '¿Quieres quitarle el Me gusta a "$videoName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Quitar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();

    final updatedVideos = List<String>.from(_likedVideos)
      ..remove(videoName);

    await prefs.setStringList('liked_videos', updatedVideos);

    if (!mounted) return;

    setState(() {
      _likedVideos = updatedVideos;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video eliminado de Me gustan'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshVideos() async {
    await _loadLikedVideos();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos que me gustaron'),
        centerTitle: true,
        actions: [
          if (_likedVideos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_likedVideos.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshVideos,
              child: _likedVideos.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 72,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No tienes videos que te gustaron',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Los videos que marques con ❤️ '
                                'aparecerán aquí.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _likedVideos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final videoName = _likedVideos[index];

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  colorScheme.primaryContainer,
                              child: Icon(
                                Icons.favorite,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              videoName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              'Video que te gustó',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                              ),
                              tooltip: 'Quitar Me gusta',
                              onPressed: () =>
                                  _removeLike(videoName),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}