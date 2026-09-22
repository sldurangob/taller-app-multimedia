import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Sergio Durango';
  String _bio = 'Diseñador gráfico | Ingeniería Multimedia';

  int _photosCount = 0;
  int _videosCount = 0;
  int _likedVideosCount = 0;
  int _savedVideosCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final likedVideos = prefs.getStringList('liked_videos') ?? [];
    final savedVideos = prefs.getStringList('saved_videos') ?? [];

    if (!mounted) return;

    setState(() {
      _name = prefs.getString('profile_name') ?? 'Sergio Durango';

      _bio = prefs.getString('profile_bio') ??
          'Diseñador gráfico | Ingeniería Multimedia';

      _photosCount = prefs.getInt('photos_count') ?? 0;
      _videosCount = prefs.getInt('videos_count') ?? 0;

      _likedVideosCount = likedVideos.length;
      _savedVideosCount = savedVideos.length;
    });
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentName: _name,
          currentBio: _bio,
        ),
      ),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  void _showProfileInformation() {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text('Información del perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Biografía',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _bio.isEmpty ? 'Sin biografía' : _bio,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 52,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _bio.isEmpty ? 'Sin biografía' : _bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.photo_camera,
                    value: _photosCount,
                    label: 'Fotos',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.videocam,
                    value: _videosCount,
                    label: 'Videos',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite,
                    value: _likedVideosCount,
                    label: 'Me gustan',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.download,
                    value: _savedVideosCount,
                    label: 'Guardados',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Editar perfil'),
                    subtitle: const Text(
                      'Modificar nombre y biografía',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _editProfile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Información del perfil'),
                    subtitle: const Text(
                      'Ver información personal',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showProfileInformation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.currentName,
    );

    _bioController = TextEditingController(
      text: widget.currentBio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_name', name);
    await prefs.setString('profile_bio', bio);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 52,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Escribe tu nombre',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _bioController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Biografía',
              hintText: 'Escribe algo sobre ti',
              prefixIcon: Icon(Icons.edit_note),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text(
                'Guardar cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}