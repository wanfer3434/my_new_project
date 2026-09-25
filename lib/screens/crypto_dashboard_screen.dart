// lib/screens/crypto_dashboard_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CryptoDashboardPage extends StatefulWidget {
  const CryptoDashboardPage({super.key});

  @override
  State<CryptoDashboardPage> createState() => _CryptoDashboardPageState();
}

class _CryptoDashboardPageState extends State<CryptoDashboardPage> {
  final String baseUrl = 'https://javier-1.tail33d395.ts.net';

  bool loading = true;
  Timer? refreshTimer;

  List<double> btcPrices = [];
  List<BotSignalPoint> botSignals = [];

  BotStatus botStatus = BotStatus.empty();

  @override
  void initState() {
    super.initState();
    _loadDashboard();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
          (_) => _loadDashboard(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // =========================
  // DASHBOARD
  // =========================
  Future<void> _loadDashboard() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/bot/status'),
        headers: {
          'Authorization':
          'Bearer TU_TOKEN',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          botStatus = BotStatus.fromJson(data);
          loading = false;
        });

        await _loadPrice();
        await _loadSignals();
      }
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadPrice() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT'),
      );

      final data = jsonDecode(res.body);
      final price = double.tryParse(data['price'].toString()) ?? 0;

      if (price > 0 && mounted) {
        setState(() {
          btcPrices.add(price);
          if (btcPrices.length > 50) btcPrices.removeAt(0);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSignals() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Authorization': 'Bearer fe62823e3f876ad1a9cd859fd1518dcd6ee2ac70a06e947b049fafc65d7d59a2',
        },
      );

      if (res.statusCode != 200) return;

      final List data = jsonDecode(res.body);

      final signals = data
          .where((e) => e['side'] == 'WAIT_BUY')
          .take(20)
          .map((e) {
        final raw = _safeJson(e['raw_response']);

        return BotSignalPoint(
          trendOk: raw['trend_ok'] == true,
          momentumOk: raw['momentum_ok'] == true,
          rsiOk: raw['rsi_ok'] == true,
          volumeOk: raw['volume_ok'] == true,
          rsi: _toDouble(raw['rsi']),
          changePct: _toDouble(raw['change_pct']),
        );
      }).toList();

      if (mounted) {
        setState(() => botSignals = signals);
      }
    } catch (_) {}
  }

  Map<String, dynamic> _safeJson(dynamic value) {
    try {
      if (value == null) return {};
      if (value is Map) return Map<String, dynamic>.from(value);
      return jsonDecode(value.toString());
    } catch (_) {
      return {};
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    return double.tryParse(v.toString()) ?? 0;
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crypto Dashboard")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statusCard(),
          const SizedBox(height: 16),
          _priceCard(),
          const SizedBox(height: 16),
          _signalsCard(),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return Card(
      child: ListTile(
        title: Text("Bot: ${botStatus.state.name}"),
        subtitle: Text(botStatus.message),
      ),
    );
  }

  Widget _priceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          btcPrices.isEmpty
              ? "Cargando precio..."
              : "BTC: ${btcPrices.last.toStringAsFixed(2)}",
        ),
      ),
    );
  }

  Widget _signalsCard() {
    return Card(
      child: Column(
        children: botSignals
            .map(
              (s) => ListTile(
            title: Text(
                "RSI: ${s.rsi.toStringAsFixed(2)} | Change: ${s.changePct.toStringAsFixed(2)}%"),
            subtitle: Text(
              "T:${s.trendOk} M:${s.momentumOk} R:${s.rsiOk} V:${s.volumeOk}",
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

// =========================
// MODELS
// =========================

enum BotState { active, waiting, inPosition, error }

class BotStatus {
  final BotState state;
  final String message;

  BotStatus({
    required this.state,
    required this.message,
  });

  factory BotStatus.empty() {
    return BotStatus(
      state: BotState.waiting,
      message: "Esperando señal...",
    );
  }

  factory BotStatus.fromJson(Map<String, dynamic> json) {
    final stateText = json['state']?.toString() ?? 'waiting';

    return BotStatus(
      state: _parse(stateText),
      message: json['message']?.toString() ?? '',
    );
  }

  static BotState _parse(String v) {
    switch (v) {
      case 'active':
        return BotState.active;
      case 'in_position':
        return BotState.inPosition;
      case 'error':
        return BotState.error;
      default:
        return BotState.waiting;
    }
  }
}

class BotSignalPoint {
  final bool trendOk;
  final bool momentumOk;
  final bool rsiOk;
  final bool volumeOk;
  final double rsi;
  final double changePct;

  BotSignalPoint({
    required this.trendOk,
    required this.momentumOk,
    required this.rsiOk,
    required this.volumeOk,
    required this.rsi,
    required this.changePct,
  });
}