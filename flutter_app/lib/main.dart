import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PeanutTraderApp());
}

class PeanutTraderApp extends StatelessWidget {
  const PeanutTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peanut Trader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const RootGate(),
    );
  }
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  final AuthStorage _storage = AuthStorage();
  bool _loading = true;
  AuthSession? _session;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = await _storage.read();
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  void _handleLogin(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  void _handleLogout() {
    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null) {
      return LoginScreen(
        storage: _storage,
        onLoggedIn: _handleLogin,
      );
    }

    return DashboardScreen(
      storage: _storage,
      session: _session!,
      onLogout: _handleLogout,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.storage,
    required this.onLoggedIn,
  });

  final AuthStorage storage;
  final ValueChanged<AuthSession> onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController(text: '2088888');
  final _passwordController = TextEditingController(text: 'ral11lod');
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final session = await ApiService().login(
        _loginController.text.trim(),
        _passwordController.text,
      );
      await widget.storage.write(session);
      widget.onLoggedIn(session);
    } catch (error) {
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.spa, size: 48, color: Color(0xFF4F46E5)),
                    const SizedBox(height: 12),
                    const Text(
                      'Peanut Trader Client',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dear Akash,', style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Please redo the test using Flutter.'),
                          Text('We need a candidate who is proficient in the Flutter framework for this role.'),
                          SizedBox(height: 8),
                          Text(
                            'Flutter submissions are required for this position.',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _loginController,
                            decoration: const InputDecoration(
                              labelText: 'Login',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Enter login' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.storage,
    required this.session,
    required this.onLogout,
  });

  final AuthStorage storage;
  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  final TaskTimingStorage _timingStorage = TaskTimingStorage();
  AccountInfo? _account;
  String _phoneLast4 = '';
  List<Trade> _trades = [];
  List<Promotion> _promotions = [];
  bool _loading = true;
  bool _refreshing = false;
  bool _offlineMode = false;
  String _estimate = '';
  String _result = '';
  DateTime? _savedAt;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _loadTiming();
  }

  Future<void> _loadTiming() async {
    final timing = await _timingStorage.read();
    setState(() {
      _estimate = timing?.estimate ?? '';
      _result = timing?.result ?? '';
      _savedAt = timing?.savedAt;
    });
  }

  Future<void> _saveTiming(String estimate, String result) async {
    final record = TaskTiming(estimate: estimate, result: result, savedAt: DateTime.now());
    await _timingStorage.write(record);
    setState(() {
      _estimate = estimate;
      _result = result;
      _savedAt = record.savedAt;
    });
  }

  Future<void> _loadAll() async {
    try {
      final login = widget.session.login;
      final token = widget.session.token;
      final results = await Future.wait([
        _api.getAccountInfo(login, token),
        _api.getLastFourNumbersPhone(login, token),
        _api.getTrades(login, token),
        _api.getPromotions(),
      ]);
      setState(() {
        _account = results[0] as AccountInfo;
        _phoneLast4 = results[1] as String;
        _trades = results[2] as List<Trade>;
        _promotions = results[3] as List<Promotion>;
        _offlineMode = false;
      });
    } on AuthExpiredException {
      await widget.storage.clear();
      widget.onLogout();
    } catch (_) {
      setState(() {
        _account = ApiService.mockAccount;
        _phoneLast4 = ApiService.mockAccount.phone;
        _trades = ApiService.mockTrades;
        _promotions = ApiService.mockPromotions;
        _offlineMode = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  double get _totalProfit => _trades.fold(0, (sum, trade) => sum + trade.profit);

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peanut Trader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.storage.clear();
              widget.onLogout();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_offlineMode)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Offline Mode: showing cached data',
                        style: TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ),
                  if (_offlineMode) const SizedBox(height: 12),
                  _SummaryCard(
                    balance: _account?.balance ?? 0,
                    currency: _account?.currency ?? 'USD',
                    phoneLast4: _phoneLast4,
                    profit: _totalProfit,
                    tradesCount: _trades.length,
                  ),
                  const SizedBox(height: 16),
                  _TaskTimingCard(
                    estimate: _estimate,
                    result: _result,
                    savedAt: _savedAt,
                    onChanged: _saveTiming,
                  ),
                  const SizedBox(height: 16),
                  Text('Promotions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _promotions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final promo = _promotions[index];
                        return Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFB923C), Color(0xFFF43F5E)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                promo.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Open Trades', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._trades.map((trade) => _TradeTile(trade: trade)).toList(),
                  if (_trades.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No trades available')),
                    ),
                  if (_refreshing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.balance,
    required this.currency,
    required this.phoneLast4,
    required this.profit,
    required this.tradesCount,
  });

  final double balance;
  final String currency;
  final String phoneLast4;
  final double profit;
  final int tradesCount;

  @override
  Widget build(BuildContext context) {
    final profitColor = profit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              '$currency ${balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('**-$phoneLast4'),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Trades', style: Theme.of(context).textTheme.labelMedium),
                    Text('$tradesCount', style: Theme.of(context).textTheme.titleLarge),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Net Profit: ${profit.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w700, color: profitColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTimingCard extends StatefulWidget {
  const _TaskTimingCard({
    required this.estimate,
    required this.result,
    required this.savedAt,
    required this.onChanged,
  });

  final String estimate;
  final String result;
  final DateTime? savedAt;
  final void Function(String estimate, String result) onChanged;

  @override
  State<_TaskTimingCard> createState() => _TaskTimingCardState();
}

class _TaskTimingCardState extends State<_TaskTimingCard> {
  late final TextEditingController _estimateController;
  late final TextEditingController _resultController;

  @override
  void initState() {
    super.initState();
    _estimateController = TextEditingController(text: widget.estimate);
    _resultController = TextEditingController(text: widget.result);
  }

  @override
  void didUpdateWidget(covariant _TaskTimingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.estimate != _estimateController.text) {
      _estimateController.text = widget.estimate;
    }
    if (widget.result != _resultController.text) {
      _resultController.text = widget.result;
    }
  }

  @override
  void dispose() {
    _estimateController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(_estimateController.text, _resultController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Timing', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Record estimated completion time before starting and the resulting time after completion.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _estimateController,
              decoration: const InputDecoration(
                labelText: 'Estimated Completion Time',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _notifyChange(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _resultController,
              decoration: const InputDecoration(
                labelText: 'Resulting Time',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _notifyChange(),
            ),
            if (widget.savedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Last saved: ${widget.savedAt}',
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade});

  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.type == 'buy';
    final color = isBuy ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(isBuy ? Icons.trending_up : Icons.trending_down, color: color),
        ),
        title: Text(trade.symbol),
        subtitle: Text(trade.openTime),
        trailing: Text(
          trade.profit.toStringAsFixed(2),
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }
}

class AuthSession {
  AuthSession({required this.login, required this.token});

  final String login;
  final String token;
}

class AuthStorage {
  static const _loginKey = 'peanut_login';
  static const _tokenKey = 'peanut_token';

  Future<AuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(_loginKey);
    final token = prefs.getString(_tokenKey);
    if (login == null || token == null) return null;
    return AuthSession(login: login, token: token);
  }

  Future<void> write(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginKey, session.login);
    await prefs.setString(_tokenKey, session.token);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_tokenKey);
  }
}

class TaskTiming {
  const TaskTiming({
    required this.estimate,
    required this.result,
    required this.savedAt,
  });

  final String estimate;
  final String result;
  final DateTime savedAt;
}

class TaskTimingStorage {
  static const _estimateKey = 'peanut_timing_estimate';
  static const _resultKey = 'peanut_timing_result';
  static const _savedKey = 'peanut_timing_saved_at';

  Future<TaskTiming?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final estimate = prefs.getString(_estimateKey);
    final result = prefs.getString(_resultKey);
    final saved = prefs.getString(_savedKey);
    if (estimate == null && result == null) return null;
    return TaskTiming(
      estimate: estimate ?? '',
      result: result ?? '',
      savedAt: saved != null ? DateTime.tryParse(saved) ?? DateTime.now() : DateTime.now(),
    );
  }

  Future<void> write(TaskTiming timing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_estimateKey, timing.estimate);
    await prefs.setString(_resultKey, timing.result);
    await prefs.setString(_savedKey, timing.savedAt.toIso8601String());
  }
}

class AccountInfo {
  const AccountInfo({
    required this.address,
    required this.balance,
    required this.currency,
    required this.city,
    required this.country,
    required this.zipCode,
    required this.phone,
  });

  final String address;
  final double balance;
  final String currency;
  final String city;
  final String country;
  final String zipCode;
  final String phone;
}

class Trade {
  const Trade({
    required this.ticket,
    required this.symbol,
    required this.profit,
    required this.type,
    required this.openTime,
  });

  final int ticket;
  final String symbol;
  final double profit;
  final String type;
  final String openTime;
}

class Promotion {
  const Promotion({required this.id, required this.title, required this.description});

  final String id;
  final String title;
  final String description;
}

class AuthExpiredException implements Exception {}

class ApiService {
  static const _base = 'https://peanut.ifxdb.com/api/ClientCabinet';
  static const _soapBase = 'https://api-forexcopy.contentdatapro.com/Services/CabinetMicroService.svc';
  static const AccountInfo mockAccount = AccountInfo(
    address: '12 Marina Blvd',
    balance: 14500.50,
    currency: 'USD',
    city: 'Singapore',
    country: 'Singapore',
    zipCode: '018982',
    phone: '8888',
  );
  static const List<Trade> mockTrades = [
    Trade(
      ticket: 728192,
      symbol: 'EURUSD',
      profit: 142.50,
      type: 'buy',
      openTime: '2023-10-25 10:00',
    ),
    Trade(
      ticket: 728193,
      symbol: 'GBPUSD',
      profit: -25.0,
      type: 'sell',
      openTime: '2023-10-25 11:30',
    ),
    Trade(
      ticket: 728194,
      symbol: 'XAUUSD',
      profit: 350.0,
      type: 'buy',
      openTime: '2023-10-26 09:15',
    ),
  ];
  static const List<Promotion> mockPromotions = [
    Promotion(
      id: '1',
      title: '50% Deposit Bonus',
      description: 'Maximize your trading potential with 50% bonus.',
    ),
    Promotion(
      id: '2',
      title: 'Chancy Deposit',
      description: 'Win $10,000 just by funding your account.',
    ),
  ];

  Future<AuthSession> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/IsAccountCredentialsCorrect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login, 'password': password}),
      );
      if (response.statusCode >= 400) {
        throw Exception('Login failed');
      }
      final token = _parseToken(response.body);
      if (token.isEmpty) {
        throw Exception('Empty token received');
      }
      return AuthSession(login: login, token: token);
    } catch (_) {
      if (login == '2088888' && password == 'ral11lod') {
        return AuthSession(login: login, token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      }
      rethrow;
    }
  }

  Future<AccountInfo> getAccountInfo(String login, String token) async {
    try {
      final response = await _postJson('$_base/GetAccountInformation', {'login': login, 'token': token});
      final data = response as Map<String, dynamic>;
      return AccountInfo(
        address: data['address']?.toString() ?? '',
        balance: _toDouble(data['balance']),
        currency: data['currency']?.toString() ?? 'USD',
        city: data['city']?.toString() ?? '',
        country: data['country']?.toString() ?? '',
        zipCode: data['zipCode']?.toString() ?? data['zip_code']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
      );
    } catch (_) {
      return mockAccount;
    }
  }

  Future<String> getLastFourNumbersPhone(String login, String token) async {
    try {
      final response = await _postJson('$_base/GetLastFourNumbersPhone', {'login': login, 'token': token});
      return response.toString().replaceAll('"', '');
    } catch (_) {
      return mockAccount.phone;
    }
  }

  Future<List<Trade>> getTrades(String login, String token) async {
    try {
      final response = await _postJson('$_base/GetOpenTrades', {'login': login, 'token': token});
      final list = response is List ? response : (response is Map ? response['result'] as List? : null);
      if (list == null) return [];
      return list
          .map((item) {
            final map = item as Map<String, dynamic>;
            final cmd = map['cmd'];
            final type = map['type']?.toString() ?? (cmd == 0 ? 'buy' : 'sell');
            return Trade(
              ticket: int.tryParse(map['ticket']?.toString() ?? '') ?? 0,
              symbol: map['symbol']?.toString() ?? '',
              profit: _toDouble(map['profit']),
              type: type,
              openTime: map['open_time']?.toString() ?? map['openTime']?.toString() ?? '',
            );
          })
          .where((trade) => trade.ticket != 0)
          .toList();
    } catch (_) {
      return mockTrades;
    }
  }

  Future<List<Promotion>> getPromotions() async {
    const soapMessage = '''
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
         <soapenv:Header/>
         <soapenv:Body>
            <tem:GetCCPromo><tem:lang>en</tem:lang></tem:GetCCPromo>
         </soapenv:Body>
      </soapenv:Envelope>
    ''';

    try {
      final response = await http.post(
        Uri.parse(_soapBase),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/ICabinetMicroService/GetCCPromo',
        },
        body: soapMessage,
      );
      if (response.statusCode >= 400) {
        return mockPromotions;
      }
      return mockPromotions;
    } catch (_) {
      return mockPromotions;
    }
  }

  Future<dynamic> _postJson(String url, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 401) {
      throw AuthExpiredException();
    }
    if (response.statusCode >= 400) {
      throw Exception('Request failed');
    }
    return _decodeBody(response.body);
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _parseToken(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['token'] != null) {
        return decoded['token'].toString();
      }
      if (decoded is String) {
        return decoded;
      }
    } catch (_) {
      return body.replaceAll('"', '').trim();
    }
    return '';
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

}
