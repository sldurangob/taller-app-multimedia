import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoFlashEnabled = false;
  bool _captureSoundEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;

      _vibrationEnabled =
          prefs.getBool('vibration_enabled') ?? true;

      _autoFlashEnabled =
          prefs.getBool('auto_flash_enabled') ?? false;

      _captureSoundEnabled =
          prefs.getBool('capture_sound_enabled') ?? true;

      _isLoading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notifications_enabled', value);

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = value;
    });

    _showMessage(
      value
          ? 'Notificaciones activadas'
          : 'Notificaciones desactivadas',
    );
  }

  Future<void> _setVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('vibration_enabled', value);

    if (!mounted) return;

    setState(() {
      _vibrationEnabled = value;
    });

    _showMessage(
      value ? 'Vibración activada' : 'Vibración desactivada',
    );
  }

  Future<void> _setAutoFlash(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('auto_flash_enabled', value);

    if (!mounted) return;

    setState(() {
      _autoFlashEnabled = value;
    });

    _showMessage(
      value
          ? 'Flash automático activado'
          : 'Flash automático desactivado',
    );
  }

  Future<void> _setCaptureSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('capture_sound_enabled', value);

    if (!mounted) return;

    setState(() {
      _captureSoundEnabled = value;
    });

    _showMessage(
      value
          ? 'Sonido de captura activado'
          : 'Sonido de captura desactivado',
    );
  }

  Future<void> _clearTemporaryData() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar datos temporales'),
          content: const Text(
            'Se eliminarán únicamente los datos temporales '
            'de la aplicación. Tu perfil, fotos, videos, '
            'Me gusta y videos guardados no serán eliminados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('temporary_data');

    if (!mounted) return;

    _showMessage('Datos temporales eliminados');
  }

  void _showStorageLocation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Almacenamiento'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Las fotos y videos capturados se guardan '
                'en la galería del dispositivo cuando utilizas '
                'el botón de descarga.',
              ),
              SizedBox(height: 16),
              Text(
                'Las preferencias de la aplicación se almacenan '
                'localmente.',
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

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'App Multimedia',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.perm_media,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: const [
        SizedBox(height: 12),
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

  void _showVersion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Versión'),
          content: const Text(
            'App Multimedia\n\nVersión 1.0.0',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionTitle(
            title: 'APARIENCIA',
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.dark_mode,
              color: colorScheme.primary,
            ),
            title: const Text('Modo oscuro'),
            subtitle: Text(
              widget.isDarkMode
                  ? 'Tema oscuro activado'
                  : 'Tema claro activado',
            ),
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
          const Divider(),
          const _SectionTitle(
            title: 'INTERFAZ',
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.notifications,
              color: colorScheme.primary,
            ),
            title: const Text('Notificaciones'),
            subtitle: Text(
              _notificationsEnabled
                  ? 'Las notificaciones están activadas'
                  : 'Las notificaciones están desactivadas',
            ),
            value: _notificationsEnabled,
            onChanged: _setNotifications,
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.vibration,
              color: colorScheme.primary,
            ),
            title: const Text('Vibración'),
            subtitle: Text(
              _vibrationEnabled
                  ? 'Vibración activada'
                  : 'Vibración desactivada',
            ),
            value: _vibrationEnabled,
            onChanged: _setVibration,
          ),
          const Divider(),
          const _SectionTitle(
            title: 'CÁMARA',
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.flash_auto,
              color: colorScheme.primary,
            ),
            title: const Text('Flash automático'),
            subtitle: Text(
              _autoFlashEnabled
                  ? 'El flash automático está activado'
                  : 'El flash automático está desactivado',
            ),
            value: _autoFlashEnabled,
            onChanged: _setAutoFlash,
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.volume_up,
              color: colorScheme.primary,
            ),
            title: const Text('Sonido de captura'),
            subtitle: Text(
              _captureSoundEnabled
                  ? 'Sonido activado'
                  : 'Sonido desactivado',
            ),
            value: _captureSoundEnabled,
            onChanged: _setCaptureSound,
          ),
          const Divider(),
          const _SectionTitle(
            title: 'ALMACENAMIENTO',
          ),
          ListTile(
            leading: Icon(
              Icons.folder,
              color: colorScheme.primary,
            ),
            title: const Text('Ubicación de almacenamiento'),
            subtitle: const Text(
              'Galería del dispositivo',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showStorageLocation,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_sweep,
              color: colorScheme.primary,
            ),
            title: const Text('Borrar datos temporales'),
            subtitle: const Text(
              'Eliminar datos temporales de la aplicación',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearTemporaryData,
          ),
          const Divider(),
          const _SectionTitle(
            title: 'APLICACIÓN',
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: colorScheme.primary,
            ),
            title: const Text('Acerca de la aplicación'),
            subtitle: const Text(
              'Información sobre App Multimedia',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAbout,
          ),
          ListTile(
            leading: Icon(
              Icons.article_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showVersion,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}