import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_project/app_properties.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  Color activeCardColor = const Color(0xFF1E3A8A);

  final List<Color> cardColors = const [
    Color(0xFF1E3A8A),
    Color(0xFF0F766E),
    Color(0xFF7C3AED),
    Color(0xFFB91C1C),
    Color(0xFF374151),
  ];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection.index == 1) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    monthController.dispose();
    yearController.dispose();
    cvcController.dispose();
    cardHolderController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String formatCardNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    String newText = '';
    const groupSize = 4;

    for (int i = 0; i < digitsOnly.length; i += groupSize) {
      newText += digitsOnly.substring(i, math.min(i + groupSize, digitsOnly.length));
      if (i + groupSize < digitsOnly.length) {
        newText += '  ';
      }
    }
    return newText;
  }

  String formatExpiry(String month, String year) {
    if (month.isEmpty && year.isEmpty) return 'MM/AA';
    final mm = month.isEmpty ? 'MM' : month;
    final yy = year.isEmpty ? 'AA' : year;
    return '$mm/$yy';
  }

  String get maskedCvc {
    if (cvcController.text.isEmpty) return '***';
    return cvcController.text;
  }

  String get displayHolderName {
    if (cardHolderController.text.trim().isEmpty) return 'NOMBRE DEL TITULAR';
    return cardHolderController.text.trim().toUpperCase();
  }

  String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el número de tarjeta';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 16) {
      return 'La tarjeta debe tener 16 dígitos';
    }
    return null;
  }

  String? validateMonth(String? value) {
    if (value == null || value.isEmpty) return 'Mes';
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Mes inválido';
    }
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.isEmpty) return 'Año';
    final year = int.tryParse(value);
    if (year == null || value.length != 2) {
      return 'Año inválido';
    }
    return null;
  }

  String? validateCvc(String? value) {
    if (value == null || value.isEmpty) return 'CVC';
    if (value.length < 3) return 'CVC inválido';
    return null;
  }

  String? validateHolder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el nombre del titular';
    }
    if (value.trim().length < 4) {
      return 'Nombre demasiado corto';
    }
    return null;
  }

  void saveCard() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Método de pago guardado correctamente'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Aquí luego puedes integrar Firebase / API / Stripe / PayU / Wompi
      // Navigator.pop(context);
    }
  }

  Widget _buildSecurityChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.green.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.green[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            activeCardColor,
            activeCardColor.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: activeCardColor.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARJETA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.verified_user, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 46,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  cardNumberController.text.isEmpty
                      ? '0000  0000  0000  0000'
                      : formatCardNumber(cardNumberController.text),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn('VENCE', formatExpiry(monthController.text, yearController.text)),
              _infoColumn('CVC', maskedCvc),
            ],
          ),
          const SizedBox(height: 22),
          _infoColumn('TITULAR', displayHolderName),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: activeCardColor, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saveButton = InkWell(
      onTap: saveCard,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 62,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: mainButton,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Guardar método de pago',
            style: TextStyle(
              color: Color(0xfffefefe),
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (_, constraints) => GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Método de pago',
                              style: TextStyle(
                                color: darkGrey,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const CloseButton(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Agrega una tarjeta para facilitar tus compras de forma rápida y segura.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSecurityChip(Icons.lock_outline, 'Pago seguro'),
                            const SizedBox(width: 10),
                            _buildSecurityChip(Icons.shield_outlined, 'Datos protegidos'),
                          ],
                        ),

                        const SizedBox(height: 22),
                        _buildCardPreview(),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: cardColors
                              .map(
                                (color) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  activeCardColor = color;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                width: activeCardColor == color ? 28 : 22,
                                height: activeCardColor == color ? 28 : 22,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: activeCardColor == color
                                        ? Colors.black87
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.30),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: shadow,
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: cardNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(16),
                                ],
                                decoration: _inputDecoration(
                                  hint: 'Número de tarjeta',
                                  icon: Icons.credit_card,
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: validateCardNumber,
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: monthController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      decoration: _inputDecoration(
                                        hint: 'Mes',
                                        icon: Icons.calendar_month_outlined,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                      validator: validateMonth,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: yearController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      decoration: _inputDecoration(
                                        hint: 'Año',
                                      ),
                                      onChanged: (_) => setState(() {}),
                                      validator: validateYear,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: cvcController,
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      decoration: _inputDecoration(
                                        hint: 'CVC',
                                        icon: Icons.lock_outline,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                      validator: validateCvc,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: cardHolderController,
                                textCapitalization: TextCapitalization.words,
                                decoration: _inputDecoration(
                                  hint: 'Nombre del titular',
                                  icon: Icons.person_outline,
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: validateHolder,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tus datos de pago se gestionan de forma segura. Nunca compartiremos la información sensible de tu tarjeta.',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        saveButton,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}