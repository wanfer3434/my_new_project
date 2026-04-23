import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_new_project/screens/service/rust_api_chat_service.dart';
import '../models/bot_order.dart';
import '../models/portfolio_balance.dart';

class CryptoDashboardScreen extends StatefulWidget {
  const CryptoDashboardScreen({super.key});

  @override
  State<CryptoDashboardScreen> createState() => _CryptoDashboardScreenState();
}

class _CryptoDashboardScreenState extends State<CryptoDashboardScreen> {
  late final RustApiChatService api;

  bool loading = true;
  bool runningBot = false;
  bool togglingBot = false;
  bool savingConfig = false;

  String statusMessage = '';
  String statusType = 'info';

  List<PortfolioBalance> balances = [];
  List<BotOrder> orders = [];

  bool botActive = false;
  String botMode = 'DRY_RUN';
  String selectedSymbol = 'BTCUSDT';
  double selectedAmount = 10.0;
  String? fromDate;
  String? toDate;
  double usdtBalance = 0.0;

  @override
  void initState() {
    super.initState();
    api = RustApiChatService();
    loadData();
  }

  void updateUsdtBalance() {
    final exact = balances.where((b) => b.asset.toUpperCase() == 'USDT');
    if (exact.isNotEmpty) {
      usdtBalance = double.tryParse(exact.first.free) ?? 0.0;
      return;
    }

    final flexible = balances.where((b) => b.asset.toUpperCase().contains('USDT'));
    if (flexible.isNotEmpty) {
      usdtBalance = double.tryParse(flexible.first.free) ?? 0.0;
      return;
    }

    usdtBalance = 0.0;
  }

  Color _statusCardColor() {
    switch (statusType) {
      case 'success':
        return Colors.green.shade50;
      case 'error':
        return Colors.red.shade50;
      default:
        return Colors.blue.shade50;
    }
  }

  Color _statusTextColor() {
    switch (statusType) {
      case 'success':
        return Colors.green.shade900;
      case 'error':
        return Colors.red.shade900;
      default:
        return Colors.blue.shade900;
    }
  }

  void _setStatus(String message, {String type = 'info'}) {
    if (!mounted) return;
    setState(() {
      statusMessage = message;
      statusType = type;
    });
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      statusMessage = '';
    });

    try {
      final portfolio = await api.getPortfolio();
      final orderList = await api.getOrders();

      Map<String, dynamic>? botStatus;
      try {
        botStatus = await api.getBotStatus();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        balances = portfolio;
        orders = orderList;

        if (botStatus != null) {
          botActive = botStatus['active'] ?? botActive;
          botMode = (botStatus['mode'] ?? botMode).toString();
          selectedSymbol = (botStatus['symbol'] ?? selectedSymbol).toString();

          final rawAmount = botStatus['amount'];
          if (rawAmount is num) {
            selectedAmount = rawAmount.toDouble();
          } else {
            selectedAmount =
                double.tryParse(rawAmount.toString()) ?? selectedAmount;
          }
        }

        updateUsdtBalance();
      });
    } catch (e) {
      _setStatus('Error cargando datos: $e', type: 'error');
    } finally {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> runBotOnce() async {
    if (!mounted) return;

    setState(() {
      runningBot = true;
      statusMessage = '';
    });

    try {
      final result = await api.runBotOnce(
        symbol: selectedSymbol,
        amount: selectedAmount,
      );

      if (result == null) {
        _setStatus('Error ejecutando bot', type: 'error');
        return;
      }

      final mode = result['mode']?.toString() ?? 'ok';
      _setStatus('Run once ejecutado: $mode', type: 'success');

      await loadData();
    } catch (e) {
      _setStatus('Error ejecutando bot: $e', type: 'error');
    } finally {
      if (!mounted) return;
      setState(() {
        runningBot = false;
      });
    }
  }

  Future<void> toggleBot(bool value) async {
    if (!mounted) return;

    setState(() {
      togglingBot = true;
      statusMessage = '';
    });

    try {
      final ok = await api.toggleBot(enabled: value);

      if (!ok) {
        _setStatus('No se pudo cambiar el estado del bot', type: 'error');
        return;
      }

      setState(() {
        botActive = value;
      });

      _setStatus(
        value ? 'Bot activado correctamente' : 'Bot desactivado correctamente',
        type: 'success',
      );
    } catch (e) {
      _setStatus('Error cambiando estado del bot: $e', type: 'error');
    } finally {
      if (!mounted) return;
      setState(() {
        togglingBot = false;
      });
    }
  }

  Future<void> saveConfig() async {
    if (!mounted) return;

    setState(() {
      savingConfig = true;
      statusMessage = '';
    });

    try {
      final ok = await api.updateBotConfig(
        symbol: selectedSymbol,
        amount: selectedAmount,
        mode: botMode,
      );

      if (!ok) {
        _setStatus('No se pudo guardar la configuración', type: 'error');
        return;
      }

      _setStatus('Configuración guardada correctamente', type: 'success');
      await loadData();
    } catch (e) {
      _setStatus('Error guardando configuración: $e', type: 'error');
    } finally {
      if (!mounted) return;
      setState(() {
        savingConfig = false;
      });
    }
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      setState(() {
        fromDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      setState(() {
        toDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> filterOrders() async {
    try {
      final filtered = await api.getOrders(
        symbol: selectedSymbol,
        from: fromDate,
        to: toDate,
      );

      if (!mounted) return;

      setState(() {
        orders = filtered;
      });

      _setStatus('Órdenes filtradas correctamente', type: 'success');
    } catch (e) {
      _setStatus('Error filtrando órdenes: $e', type: 'error');
    }
  }

  Widget _buildBotHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: botActive
              ? [Colors.black87, Colors.green.shade600]
              : [Colors.black87, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: botActive
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: botActive ? Colors.greenAccent : Colors.white10,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              Positioned(
                top: -8,
                right: -22,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${usdtBalance.toStringAsFixed(2)} USDT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bot automático',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  botActive ? 'Activo' : 'Inactivo',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Modo: $botMode',
                  style: TextStyle(
                    color: botMode == 'LIVE'
                        ? Colors.orangeAccent
                        : Colors.cyanAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Símbolo: $selectedSymbol | Monto: ${selectedAmount.toStringAsFixed(0)} USDT',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control del bot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSymbol,
                    decoration: const InputDecoration(
                      labelText: 'Símbolo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'BTCUSDT',
                        child: Text('BTCUSDT'),
                      ),
                      DropdownMenuItem(
                        value: 'ETHUSDT',
                        child: Text('ETHUSDT'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedSymbol = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: selectedAmount,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 10.0, child: Text('10 USDT')),
                      DropdownMenuItem(value: 20.0, child: Text('20 USDT')),
                      DropdownMenuItem(value: 50.0, child: Text('50 USDT')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedAmount = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: botMode,
                    decoration: const InputDecoration(
                      labelText: 'Modo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'DRY_RUN',
                        child: Text('DRY_RUN'),
                      ),
                      DropdownMenuItem(
                        value: 'LIVE',
                        child: Text('LIVE'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => botMode = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: savingConfig ? null : saveConfig,
                    icon: const Icon(Icons.save),
                    label: Text(
                      savingConfig ? 'Guardando...' : 'Guardar config',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bot ON / OFF'),
              subtitle: Text(botActive ? 'Bot activo' : 'Bot detenido'),
              value: botActive,
              onChanged: togglingBot ? null : toggleBot,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: loading ? null : loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recargar'),
                ),
                ElevatedButton.icon(
                  onPressed: runningBot ? null : runBotOnce,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(runningBot ? 'Ejecutando...' : 'Run once'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtro por fecha',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickFromDate,
                    child: Text(fromDate ?? 'Desde'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickToDate,
                    child: Text(toDate ?? 'Hasta'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: filterOrders,
                  child: const Text('Filtrar'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                    await loadData();
                  },
                  child: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalances() {
    if (balances.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay balances disponibles'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: balances.map((b) {
                final freeValue =
                    double.tryParse(b.free.toString()) ?? 0.0;
                final lockedValue =
                    double.tryParse(b.locked.toString()) ?? 0.0;

                return Container(
                  width: 165,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.asset,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Free: ${freeValue.toStringAsFixed(8)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Locked: ${lockedValue.toStringAsFixed(8)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    if (orders.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay órdenes registradas'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Symbol')),
              DataColumn(label: Text('Side')),
              DataColumn(label: Text('Quote')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Created')),
            ],
            rows: orders.map((o) {
              final quoteSpent =
                  double.tryParse(o.quoteSpent.toString()) ?? 0.0;
              final baseQty =
                  double.tryParse((o.baseQty ?? 0).toString()) ?? 0.0;
              final price =
                  double.tryParse((o.price ?? 0).toString()) ?? 0.0;

              return DataRow(
                cells: [
                  DataCell(Text(o.id.toString())),
                  DataCell(Text(o.symbol)),
                  DataCell(Text(o.side)),
                  DataCell(Text(quoteSpent.toStringAsFixed(2))),
                  DataCell(Text(baseQty.toStringAsFixed(8))),
                  DataCell(Text(price.toStringAsFixed(2))),
                  DataCell(Text(o.status)),
                  DataCell(
                    SizedBox(
                      width: 180,
                      child: Text(
                        o.createdAt,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Dashboard'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBotHeader(),
            const SizedBox(height: 12),
            _buildActions(),
            if (statusMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                color: _statusCardColor(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    statusMessage,
                    style: TextStyle(color: _statusTextColor()),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildDateFilter(),
            const SizedBox(height: 12),
            _buildBalances(),
            const SizedBox(height: 12),
            _buildOrdersTable(),
          ],
        ),
      ),
    );
  }
}