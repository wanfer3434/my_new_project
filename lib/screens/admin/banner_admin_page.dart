import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BannerAdminPage extends StatefulWidget {
  const BannerAdminPage({super.key});

  @override
  State<BannerAdminPage> createState() => _BannerAdminPageState();
}

class _BannerAdminPageState extends State<BannerAdminPage> {
  static const String baseUrl = 'https://javier.tail33d395.ts.net';
  static const String adminToken = '8YfQm2NwL7rP4xVa9KdE3sHu6ZjC1tRb';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _buttonTextController =
  TextEditingController(text: 'Ver demostración');
  final TextEditingController _ordenController =
  TextEditingController(text: '0');

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _archivoImagenGuardado;
  String? _imageUrlPreview;

  bool _activo = true;
  bool _isSaving = false;
  bool _isLoadingList = false;
  int? _editingBannerId;

  List<dynamic> _banners = [];

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _referenciaController.dispose();
    _costoController.dispose();
    _videoUrlController.dispose();
    _buttonTextController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoadingList = true;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/banners'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _banners = data;
        });
      } else {
        _showMessage('No se pudieron cargar los banners');
      }
    } catch (e) {
      _showMessage('Error cargando banners: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingList = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.bytes == null) {
        _showMessage('No se pudo leer la imagen');
        return;
      }

      setState(() {
        _selectedImageBytes = file.bytes!;
        _selectedImageName = file.name;
        _archivoImagenGuardado = null;
        _imageUrlPreview = null;
      });
    } catch (e) {
      _showMessage('Error seleccionando imagen: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageBytes == null || _selectedImageName == null) {
      return _archivoImagenGuardado;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/upload-banner-image'),
      );

      request.headers['Authorization'] = 'Bearer $adminToken';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedImageBytes!,
          filename: _selectedImageName!,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        _showMessage('Error subiendo imagen: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);

      setState(() {
        _archivoImagenGuardado = data['archivo_imagen'];
        _imageUrlPreview = data['image_url'];
      });

      return _archivoImagenGuardado;
    } catch (e) {
      _showMessage('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String? archivoImagen = _archivoImagenGuardado;

      if (_selectedImageBytes != null) {
        archivoImagen = await _uploadImage();
      }

      if ((archivoImagen == null || archivoImagen.isEmpty) &&
          _editingBannerId == null) {
        _showMessage('Selecciona una imagen para crear el banner');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final body = {
        'nombre': _nombreController.text.trim(),
        'referencia': _referenciaController.text.trim().isEmpty
            ? null
            : _referenciaController.text.trim(),
        'costo': double.tryParse(_costoController.text.trim()) ?? 0,
        'archivo_imagen': archivoImagen ?? '',
        'video_url': _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
        'button_text': _buttonTextController.text.trim().isEmpty
            ? 'Ver demostración'
            : _buttonTextController.text.trim(),
        'activo': _activo ? 1 : 0,
        'orden': int.tryParse(_ordenController.text.trim()) ?? 0,
      };

      http.Response response;

      if (_editingBannerId == null) {
        response = await http.post(
          Uri.parse('$baseUrl/admin/banners'),
          headers: {
            'Authorization': 'Bearer $adminToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      } else {
        final updateBody = Map<String, dynamic>.from(body);

        if ((updateBody['archivo_imagen'] as String).isEmpty) {
          final existing = _banners.cast<dynamic?>().firstWhere(
                (item) => item != null && item['id'] == _editingBannerId,
            orElse: () => null,
          );
          if (existing != null) {
            updateBody['archivo_imagen'] = existing['archivo_imagen'];
          }
        }

        response = await http.put(
          Uri.parse('$baseUrl/admin/banners/$_editingBannerId'),
          headers: {
            'Authorization': 'Bearer $adminToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updateBody),
        );
      }

      if (response.statusCode == 200) {
        _showMessage(
          _editingBannerId == null
              ? 'Banner creado correctamente'
              : 'Banner actualizado correctamente',
        );
        _clearForm();
        await _loadBanners();
      } else {
        _showMessage('Error guardando banner: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error guardando banner: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteBanner(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar banner'),
        content: const Text(
          '¿Seguro que deseas eliminar este banner?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/banners/$id'),
        headers: {
          'Authorization': 'Bearer $adminToken',
        },
      );

      if (response.statusCode == 200) {
        _showMessage('Banner eliminado correctamente');
        if (_editingBannerId == id) {
          _clearForm();
        }
        await _loadBanners();
      } else {
        _showMessage('Error eliminando banner: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error eliminando banner: $e');
    }
  }

  void _loadBannerIntoForm(dynamic banner) {
    setState(() {
      _editingBannerId = banner['id'];
      _nombreController.text = banner['nombre'] ?? '';
      _referenciaController.text = banner['referencia'] ?? '';
      _costoController.text = '${banner['costo'] ?? 0}';
      _videoUrlController.text = banner['video_url'] ?? '';
      _buttonTextController.text =
      (banner['button_text'] ?? '').toString().isEmpty
          ? 'Ver demostración'
          : banner['button_text'];
      _ordenController.text = '${banner['orden'] ?? 0}';
      _activo = (banner['activo'] ?? 1) == 1;
      _archivoImagenGuardado = banner['archivo_imagen'];
      _imageUrlPreview =
      '$baseUrl/static/images/${banner['archivo_imagen']}';
      _selectedImageBytes = null;
      _selectedImageName = null;
    });

    _showMessage('Banner cargado para edición');
  }

  void _clearForm() {
    _nombreController.clear();
    _referenciaController.clear();
    _costoController.clear();
    _videoUrlController.clear();
    _buttonTextController.text = 'Ver demostración';
    _ordenController.text = '0';

    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _archivoImagenGuardado = null;
      _imageUrlPreview = null;
      _activo = true;
      _editingBannerId = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildPreviewCard() {
    Widget imageWidget;

    if (_selectedImageBytes != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _selectedImageBytes!,
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_imageUrlPreview != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _imageUrlPreview!,
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 190,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 50),
          ),
        ),
      );
    } else {
      imageWidget = Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Vista previa del banner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          const SizedBox(height: 10),
          Text(
            _editingBannerId == null
                ? 'Nuevo banner para cámaras y accesorios'
                : 'Editando banner #$_editingBannerId',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sube imagen, agrega video y organiza el carrusel principal de tu tienda.',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          if (_archivoImagenGuardado != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              'Archivo: $_archivoImagenGuardado',
              style: const TextStyle(fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Seleccionar imagen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _clearForm,
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Limpiar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del banner',
                border: OutlineInputBorder(),
                hintText: 'Ej: Sony Cybershot DSC-W55',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _referenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia',
                border: OutlineInputBorder(),
                hintText: 'Ej: Sony-DSC-W55',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Costo',
                border: OutlineInputBorder(),
                hintText: 'Ej: 220000',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe un costo';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Costo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL del video',
                border: OutlineInputBorder(),
                hintText: 'Ej: https://i.imgur.com/xxxx.mp4',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _buttonTextController,
              decoration: const InputDecoration(
                labelText: 'Texto del botón',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ordenController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Orden',
                border: OutlineInputBorder(),
                hintText: '0, 1, 2...',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _activo,
              onChanged: (value) {
                setState(() {
                  _activo = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              title: const Text('Banner activo'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveBanner,
                icon: _isSaving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(
                  _editingBannerId == null
                      ? Icons.save_outlined
                      : Icons.edit_outlined,
                ),
                label: Text(
                  _editingBannerId == null
                      ? 'Guardar banner'
                      : 'Actualizar banner',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerList() {
    if (_isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_banners.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text('No hay banners cargados todavía'),
        ),
      );
    }

    return Column(
      children: _banners.map((banner) {
        final imageUrl = '$baseUrl/static/images/${banner['archivo_imagen']}';
        final nombre = (banner['nombre'] ?? '').toString();
        final referencia = (banner['referencia'] ?? '').toString();
        final costo = banner['costo'];
        final orden = banner['orden'] ?? 0;
        final activo = (banner['activo'] ?? 1) == 1;
        final id = banner['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 74,
                    width: 74,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 74,
                      width: 74,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        referencia.isEmpty ? 'Sin referencia' : referencia,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Costo: \$${(costo ?? 0).toString()} | Orden: $orden | ${activo ? "Activo" : "Inactivo"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Editar',
                  onPressed: () => _loadBannerIntoForm(banner),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: () => _deleteBanner(id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F9),
      appBar: AppBar(
        title: const Text('Administrador de banners'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _loadBanners,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBanners,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 16),
            _buildFormCard(),
            const SizedBox(height: 18),
            const Text(
              'Banners actuales',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildBannerList(),
          ],
        ),
      ),
    );
  }
}