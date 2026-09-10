import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final List<String> imageUrls = const [
    'https://picsum.photos/id/10/600/400',
    'https://picsum.photos/id/20/600/400',
    'https://picsum.photos/id/30/600/400',
    'https://picsum.photos/id/40/600/400',
    'https://picsum.photos/id/50/600/400',
    'https://picsum.photos/id/60/600/400',
    'https://picsum.photos/id/70/600/400',
    'https://picsum.photos/id/80/600/400',
    'https://picsum.photos/id/90/600/400',
  ];

  int selectedImage = 0;

  // Imagen seleccionada desde el dispositivo
  File? localImage;

  // Color principal verde teal
  static const Color tealColor = Color(0xFF00897B);

  // Función para seleccionar una imagen
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        localImage = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: tealColor,
        foregroundColor: Colors.white,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visor de Imágenes Interactivo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Hecho por Sergio Durango',
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedImage = 0;
                localImage = null;
              });
            },
            icon: const Icon(Icons.refresh),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // VISOR PRINCIPAL
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: SizedBox(
                width: double.infinity,
                height: 220,

                child: Stack(
                  children: [

                    // Imagen con zoom y desplazamiento
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,

                        child: localImage != null
                            ? Image.file(
                                localImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.network(
                                imageUrls[selectedImage],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,

                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }

                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: tealColor,
                                    ),
                                  );
                                },

                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    // Indicador "Toca para ampliar"
                    Positioned(
                      right: 8,
                      bottom: 8,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: const Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 14,
                            ),

                            SizedBox(width: 4),

                            Text(
                              'Toca para ampliar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BOTÓN PARA CARGAR IMAGEN
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: pickImage,

                icon: const Icon(
                  Icons.add_photo_alternate,
                ),

                label: const Text(
                  'Cargar imagen desde mi dispositivo',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: tealColor,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TÍTULO DE GALERÍA
            const Text(
              'GALERÍA DE MUESTRA (GRIDVIEW)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            // GRID DE IMÁGENES
            GridView.builder(
              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount: imageUrls.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),

              itemBuilder: (context, index) {
                final isSelected =
                    selectedImage == index &&
                    localImage == null;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = index;

                      // Volver a mostrar una imagen de Internet
                      localImage = null;
                    });
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8),

                      border: isSelected
                          ? Border.all(
                              color: tealColor,
                              width: 2,
                            )
                          : null,
                    ),

                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(7),

                      child: Image.network(
                        imageUrls[index],

                        fit: BoxFit.cover,

                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,

                              child:
                                  CircularProgressIndicator(
                                color: tealColor,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            // MENSAJE DE IMAGEN CARGADA
            if (localImage != null) ...[
              const SizedBox(height: 20),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(10),

                  border: Border.all(
                    color:
                        tealColor.withValues(alpha: 0.3),
                  ),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: tealColor,
                    ),

                    SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Imagen cargada desde el dispositivo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}