import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen> {
  List<String> _savedVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedVideos();
  }

  Future<void> _loadSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final videos = prefs.getStringList('saved_videos') ?? [];

    if (!mounted) return;

    setState(() {
      _savedVideos = List<String>.from(videos);
      _isLoading = false;
    });
  }

  Future<void> _removeVideo(String videoName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar video'),
          content: Text(
            '¿Quieres eliminar "$videoName" de tus videos guardados?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();

    final updatedVideos = List<String>.from(_savedVideos)
      ..remove(videoName);

    await prefs.setStringList('saved_videos', updatedVideos);

    if (!mounted) return;

    setState(() {
      _savedVideos = updatedVideos;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video eliminado de guardados'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshVideos() async {
    await _loadSavedVideos();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos guardados'),
        centerTitle: true,
        actions: [
          if (_savedVideos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_savedVideos.length}',
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
              child: _savedVideos.isEmpty
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
                                Icons.download_outlined,
                                size: 72,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No tienes videos guardados',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Los videos que guardes aparecerán aquí.',
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
                      itemCount: _savedVideos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final videoName = _savedVideos[index];

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
                                Icons.video_library,
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
                              'Video guardado',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              tooltip: 'Eliminar',
                              onPressed: () =>
                                  _removeVideo(videoName),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}