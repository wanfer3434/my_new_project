import 'package:flutter/material.dart';
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
  String statusMessage = '';

  List<PortfolioBalance> balances = [];
  List<BotOrder> orders = [];

  @override
  void initState() {
    super.initState();

    api = RustApiChatService();

    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      statusMessage = '';
    });

    try {
      final portfolio = await api.getPortfolio();
      final orderList = await api.getOrders();

      setState(() {
        balances = portfolio;
        orders = orderList;
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error cargando datos: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> runBotOnce() async {
    setState(() {
      runningBot = true;
      statusMessage = '';
    });

    try {
      final result = await api.runBotOnce(
        symbol: 'BTCUSDT',
        amount: 10.0,
      );

      if (result == null) {
        setState(() {
          statusMessage = '❌ Error ejecutando bot';
        });
        return;
      }

      setState(() {
        statusMessage = 'Run once ejecutado: ${result['mode'] ?? 'ok'}';
      });

      await loadData();
    } catch (e) {
      setState(() {
        statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        runningBot = false;
      });
    }
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
              'Portfolio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...balances.map((b) {
              return ListTile(
                dense: true,
                title: Text(b.asset),
                subtitle: Text('Free: ${b.free} | Locked: ${b.locked}'),
              );
            }),
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
              return DataRow(
                cells: [
                  DataCell(Text(o.id.toString())),
                  DataCell(Text(o.symbol)),
                  DataCell(Text(o.side)),
                  DataCell(Text(o.quoteSpent.toStringAsFixed(2))),
                  DataCell(Text((o.baseQty ?? 0).toStringAsFixed(8))),
                  DataCell(Text((o.price ?? 0).toStringAsFixed(2))),
                  DataCell(Text(o.status)),
                  DataCell(SizedBox(
                    width: 180,
                    child: Text(
                      o.createdAt,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
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
            _buildActions(),
            if (statusMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(statusMessage),
                ),
              ),
            ],
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