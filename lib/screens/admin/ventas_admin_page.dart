import 'package:flutter/material.dart';

import '../service/ventas_service.dart';

class VentasAdminPage extends StatefulWidget {
  const VentasAdminPage({super.key});

  @override
  State<VentasAdminPage> createState() => _VentasAdminPageState();
}

class _VentasAdminPageState extends State<VentasAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final referenciaController = TextEditingController();
  final precioController = TextEditingController();
  final cantidadController = TextEditingController(text: '1');
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();

  bool cargando = false;
  bool guardando = false;

  int ventasHoy = 0;
  double totalHoy = 0;

  @override
  void initState() {
    super.initState();
    cargarVentasHoy();
  }

  @override
  void dispose() {
    referenciaController.dispose();
    precioController.dispose();
    cantidadController.dispose();
    nombreController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  Future<void> cargarVentasHoy() async {
    setState(() => cargando = true);

    try {
      final data = await VentasService.obtenerVentasHoy();

      setState(() {
        ventasHoy = data['ventas_hoy'] ?? 0;
        totalHoy = (data['total_hoy'] ?? 0).toDouble();
      });
    } catch (_) {
      _mostrarMensaje('No se pudieron cargar las ventas de hoy');
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  Future<void> guardarVenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => guardando = true);

    final referencia = referenciaController.text.trim();
    final precio = double.tryParse(
      precioController.text.trim().replaceAll('.', '').replaceAll(',', '.'),
    ) ??
        0;

    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 1;

    try {
      final ok = await VentasService.registrarVenta(
        referencia: referencia,
        precio: precio,
        cantidad: cantidad,
        canal: 'App Flutter',
        clienteNombre: nombreController.text.trim(),
        clienteTelefono: telefonoController.text.trim(),
      );

      if (ok) {
        _mostrarMensaje('Venta registrada correctamente ✅');
        limpiarFormulario();
        await cargarVentasHoy();
      } else {
        _mostrarMensaje('No se pudo registrar la venta');
      }
    } catch (_) {
      _mostrarMensaje('Error conectando con el servidor');
    } finally {
      if (mounted) {
        setState(() => guardando = false);
      }
    }
  }

  void limpiarFormulario() {
    referenciaController.clear();
    precioController.clear();
    cantidadController.text = '1';
    nombreController.clear();
    telefonoController.clear();
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String formatoPrecio(double valor) {
    return valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Ventas del negocio'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: cargarVentasHoy,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: cargarVentasHoy,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildResumenCard(),
              const SizedBox(height: 16),
              _buildVentaForm(),
              const SizedBox(height: 16),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xff1B5E20),
            Color(0xff43A047),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: cargando
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de hoy',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${formatoPrecio(totalHoy)} COP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$ventasHoy ventas registradas hoy',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVentaForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar nueva venta',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Guarda la venta y descuenta automáticamente del inventario.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),

            _buildTextField(
              controller: referenciaController,
              label: 'Referencia del producto',
              icon: Icons.qr_code_2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe la referencia del producto';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: precioController,
              label: 'Precio de venta',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe el precio';
                }

                final precio = double.tryParse(
                  value.trim().replaceAll('.', '').replaceAll(',', '.'),
                );

                if (precio == null || precio <= 0) {
                  return 'Precio inválido';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: cantidadController,
              label: 'Cantidad',
              icon: Icons.inventory,
              keyboardType: TextInputType.number,
              validator: (value) {
                final cantidad = int.tryParse(value ?? '');
                if (cantidad == null || cantidad <= 0) {
                  return 'Cantidad inválida';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: nombreController,
              label: 'Nombre del cliente opcional',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: telefonoController,
              label: 'Teléfono / WhatsApp opcional',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: guardando ? null : guardarVenta,
                icon: guardando
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  guardando ? 'Guardando...' : 'Guardar venta',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xffF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Consejo: registra cada venta apenas la cierres. Así sabrás cuánto vendes al día y qué productos debes volver a comprar.',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}