import 'package:flutter/material.dart';
import 'image_screen.dart';
import 'video_screen.dart';
import 'web_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'saved_videos_screen.dart';
import 'liked_videos_screen.dart';

class MainNavigator extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainNavigator({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _cameraOpen = false;

  double _dragDistance = 0;

  late AnimationController _cameraAnimationController;
  late Animation<Offset> _cameraSlideAnimation;

  final List<Widget> _screens = const [
    VideoScreen(),
    ImageScreen(),
    WebScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _cameraSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cameraAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _cameraAnimationController.dispose();
    super.dispose();
  }

  void _openCamera() {
    if (_cameraOpen) return;

    setState(() {
      _cameraOpen = true;
    });

    _cameraAnimationController.forward(from: 0);
  }

  Future<void> _closeCamera() async {
    if (!_cameraOpen) return;

    await _cameraAnimationController.reverse();

    if (!mounted) return;

    setState(() {
      _cameraOpen = false;
    });
  }

  void _handleSwipeStart(DragStartDetails details) {
    if (_cameraOpen) return;

    _dragDistance = 0;
  }

  void _handleSwipeUpdate(DragUpdateDetails details) {
    if (_cameraOpen) return;

    _dragDistance += details.delta.dx;
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (_cameraOpen) return;

    final velocity = details.primaryVelocity ?? 0;

    if (_dragDistance >= 100 || velocity >= 400) {
      _openCamera();
    }

    _dragDistance = 0;
  }

  void _openProfile() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void _openSavedVideos() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SavedVideosScreen(),
      ),
    );
  }

  void _openLikedVideos() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LikedVideosScreen(),
      ),
    );
  }

  void _showAbout() {
    Navigator.pop(context);

    final colorScheme = Theme.of(context).colorScheme;

    showAboutDialog(
      context: context,
      applicationName: 'App Multimedia',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.perm_media,
        size: 42,
        color: colorScheme.primary,
      ),
      children: const [
        Text(
          'Aplicación multimedia desarrollada con Flutter.',
        ),
        SizedBox(height: 12),
        Text(
          'Permite visualizar videos, explorar imágenes, '
          'navegar por la web y utilizar la cámara.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _handleSwipeStart,
          onHorizontalDragUpdate: _handleSwipeUpdate,
          onHorizontalDragEnd: _handleSwipeEnd,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('App Multimedia'),
              centerTitle: true,
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ],
            ),
            endDrawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.perm_media,
                          color: colorScheme.onPrimary,
                          size: 42,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'App Multimedia',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Mi perfil'),
                    onTap: _openProfile,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.download,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Videos guardados'),
                    onTap: _openSavedVideos,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.favorite,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Videos que me gustaron'),
                    onTap: _openLikedVideos,
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.dark_mode,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Modo oscuro'),
                    value: widget.isDarkMode,
                    onChanged: widget.onThemeChanged,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Configuración'),
                    onTap: _openSettings,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Acerca de la aplicación'),
                    onTap: _showAbout,
                  ),
                  const ListTile(
                    leading: Icon(Icons.article_outlined),
                    title: Text('Versión'),
                    subtitle: Text('1.0.0'),
                  ),
                ],
              ),
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: 'Videos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.image),
                  label: 'Imágenes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.web),
                  label: 'Web',
                ),
              ],
            ),
          ),
        ),
        if (_cameraOpen)
          Positioned.fill(
            child: SlideTransition(
              position: _cameraSlideAnimation,
              child: CameraScreen(
                onClose: _closeCamera,
              ),
            ),
          ),
      ],
    );
  }
}