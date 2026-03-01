import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luck_ring_plugin/luck_ring_plugin.dart';
import 'package:luck_ring_plugin/luck_ring_plugin_platform_interface.dart';
import 'package:luck_ring_plugin/luck_ring_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLuckRingPluginPlatform
    with MockPlatformInterfaceMixin
    implements LuckRingPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> init() => Future.value();

  @override
  Future<void> startScan({int timeoutMs = 12000}) => Future.value();

  @override
  Future<void> stopScan() => Future.value();

  @override
  Stream<List<ScanDevice>> get scanResults =>
      Stream.value([]);

  @override
  Future<bool> connect(String address) => Future.value(true);

  @override
  Future<void> disconnect() => Future.value();

  @override
  Future<bool> isConnected() => Future.value(false);

  @override
  Future<HealthData> getHealthData() =>
      Future.value(const HealthData());
}

void main() {
  final LuckRingPluginPlatform initialPlatform = LuckRingPluginPlatform.instance;

  test('$MethodChannelLuckRingPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLuckRingPlugin>());
  });

  test('getPlatformVersion', () async {
    LuckRingPlugin luckRingPlugin = LuckRingPlugin();
    MockLuckRingPluginPlatform fakePlatform = MockLuckRingPluginPlatform();
    LuckRingPluginPlatform.instance = fakePlatform;

    try {
      expect(await luckRingPlugin.getPlatformVersion(), '42');
    } finally {
      LuckRingPluginPlatform.instance = initialPlatform;
    }
  });
}
