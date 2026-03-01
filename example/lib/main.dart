import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luck_ring_plugin/luck_ring_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luck Ring Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RingConnectPage(),
    );
  }
}

class RingConnectPage extends StatefulWidget {
  const RingConnectPage({super.key});

  @override
  State<RingConnectPage> createState() => _RingConnectPageState();
}

class _RingConnectPageState extends State<RingConnectPage> {
  final _plugin = LuckRingPlugin();
  StreamSubscription<List<ScanDevice>>? _scanResultsSub;
  List<ScanDevice> _devices = [];
  bool _scanning = false;
  bool _connected = false;
  String? _selectedAddress;
  HealthData? _healthData;
  bool _loadingHealth = false;
  String? _status;
  bool _sdkReady = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _requestPermissions();
    await _initSdk();
  }

  Future<void> _requestPermissions() async {
    try {
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      if (!mounted) return;
      setState(() {
        _status = statuses[Permission.bluetooth]?.isGranted == true
            ? 'Permissions OK'
            : 'Some permissions denied';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Permission error: $e');
    }
  }

  Future<void> _initSdk() async {
    try {
      await _plugin.init();
      _sdkReady = true;
      _listenToScanResults();
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'SDK init failed: $e');
    }
  }

  void _listenToScanResults() {
    _scanResultsSub?.cancel();
    _scanResultsSub = _plugin.scanResults.listen(
      (devices) {
        if (mounted) setState(() => _devices = devices);
      },
      onError: (error) {
        if (mounted) {
          setState(() => _status = 'Scan stream error: $error');
        }
      },
    );
  }

  Future<void> _startScan() async {
    if (!_sdkReady) {
      await _initSdk();
      if (!_sdkReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SDK not ready. Check permissions.')),
          );
        }
        return;
      }
    }

    setState(() {
      _scanning = true;
      _devices = [];
      _status = 'Scanning...';
    });

    try {
      await _plugin.startScan(timeoutMs: 12000);
      if (mounted) setState(() => _status = 'Scan completed');
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Scan failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _stopScan() async {
    try {
      await _plugin.stopScan();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _scanning = false;
        _status = 'Scan stopped';
      });
    }
  }

  Future<void> _connect(ScanDevice device) async {
    setState(() => _status = 'Connecting...');
    try {
      final ok = await _plugin.connect(device.address);
      if (!mounted) return;
      setState(() {
        _connected = ok;
        _selectedAddress = device.address;
        _status = ok ? 'Connected to ${device.name}' : 'Connection failed';
      });
      if (ok) _stopScan();
    } catch (e) {
      if (mounted) setState(() => _status = 'Connect failed: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await _plugin.disconnect();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _connected = false;
        _selectedAddress = null;
      });
    }
  }

  @override
  void dispose() {
    _scanResultsSub?.cancel();
    _scanResultsSub = null;
    super.dispose();
  }

  Future<void> _fetchHealthData() async {
    if (!_connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to a device first')),
      );
      return;
    }
    setState(() => _loadingHealth = true);
    try {
      final data = await _plugin.getHealthData();
      print('data: ${jsonEncode(data.toMap())}');
      if (mounted) setState(() {
        _healthData = data;
        _loadingHealth = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loadingHealth = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luck Ring'),
        actions: [
          if (_connected)
            IconButton(
              icon: const Icon(Icons.link_off),
              onPressed: _disconnect,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _setup,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_status != null) Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_status!, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _scanning ? null : _startScan,
                      icon: _scanning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_scanning ? 'Scanning...' : 'Scan Devices'),
                    ),
                  ),
                  if (_scanning) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _stopScan,
                      child: const Text('Stop'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (_devices.isNotEmpty) ...[
                const Text('Discovered devices:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._devices.map((d) => Card(
                  child: ListTile(
                    title: Text(d.name.isEmpty ? 'Unknown' : d.name),
                    subtitle: Text(d.address),
                    trailing: FilledButton(
                      onPressed: () => _connect(d),
                      child: const Text('Connect'),
                    ),
                  ),
                )),
                const SizedBox(height: 24),
              ],
              if (_connected) ...[
                const Divider(),
                FilledButton.icon(
                  onPressed: _loadingHealth ? null : _fetchHealthData,
                  icon: _loadingHealth
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.favorite),
                  label: Text(_loadingHealth ? 'Syncing...' : 'Get Health Data'),
                ),
              ],
              if (_healthData != null) ...[
                const SizedBox(height: 24),
                const Text('Health Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _HealthDataView(data: _healthData!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthDataView extends StatelessWidget {
  final HealthData data;

  const _HealthDataView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.errorMessage != null)
              Text('Error: ${data.errorMessage}', style: TextStyle(color: Colors.red[700])),
            if (data.batteryLevel != null)
              Text('Battery: ${data.batteryLevel}%'),
            if (data.deviceInfo != null)
              Text('Device: ${data.deviceInfo!.macAddress ?? "—"}'),
            if (data.heartRate.isNotEmpty)
              Text('Heart rate: ${data.heartRate.length} readings'),
            if (data.bloodOxygen.isNotEmpty)
              Text('Blood oxygen: ${data.bloodOxygen.length} readings'),
            if (data.bloodPressure.isNotEmpty)
              Text('Blood pressure: ${data.bloodPressure.length} readings'),
            if (data.sleep.isNotEmpty)
              Text('Sleep: ${data.sleep.length} records'),
            if (data.sport.isNotEmpty)
              Text('Sport: ${data.sport.length} records'),
          ],
        ),
      ),
    );
  }
}
