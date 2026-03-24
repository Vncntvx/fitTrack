import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../logging/logger_service.dart';

@immutable
class NetworkAddressCandidate {
  const NetworkAddressCandidate({
    required this.interfaceName,
    required this.address,
  });

  final String interfaceName;
  final String address;
}

@immutable
class LanAddressInfo {
  const LanAddressInfo({required this.host, required this.source});

  final String host;
  final String source;

  String url(int port) => 'http://$host:$port';
}

/// 网络信息服务
/// 获取设备的网络信息
class NetworkInfoService {
  static final NetworkInfo _networkInfo = NetworkInfo();

  /// 获取当前可用于局域网访问的地址信息
  static Future<LanAddressInfo?> getLanAddressInfo() async {
    final logger = LoggerService.instance;
    try {
      final wifiIp = await _getWifiIpAddress();
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      final candidates = <NetworkAddressCandidate>[
        for (final interface in interfaces)
          for (final address in interface.addresses)
            NetworkAddressCandidate(
              interfaceName: interface.name,
              address: address.address,
            ),
      ];

      await logger.debug(
        'NetworkInfoService',
        '扫描网络接口',
        data: {
          'interfaces': interfaces.length,
          'wifiIp': wifiIp,
          'candidates': candidates.length,
        },
      );

      final selected = _selectBestLanAddress(
        wifiIp: wifiIp,
        candidates: candidates,
      );

      if (selected == null) {
        await logger.warning(
          'NetworkInfoService',
          '未找到可靠的局域网地址',
          data: {
            'wifiIp': wifiIp,
            'candidates': candidates
                .map(
                  (candidate) => {
                    'interface': candidate.interfaceName,
                    'address': candidate.address,
                  },
                )
                .toList(),
          },
        );
        return null;
      }

      await logger.info(
        'NetworkInfoService',
        '检测到局域网地址',
        data: {'ip': selected.host, 'source': selected.source},
      );
      return selected;
    } catch (e, stackTrace) {
      await logger.error(
        'NetworkInfoService',
        '获取 IP 地址失败',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  /// 获取本机 IP 地址
  static Future<String?> getLocalIpAddress() async {
    final info = await getLanAddressInfo();
    return info?.host;
  }

  static bool isUsableLanAddress(String? address) {
    return _isValidIpv4(address) &&
        !_isEmulatorAddress(address!) &&
        _isPrivateAddress(address);
  }

  @visibleForTesting
  static String? selectBestLanIp({
    String? wifiIp,
    List<NetworkAddressCandidate> candidates = const [],
  }) {
    return _selectBestLanAddress(wifiIp: wifiIp, candidates: candidates)?.host;
  }

  static Future<String?> _getWifiIpAddress() async {
    try {
      final wifiIp = await _networkInfo.getWifiIP();
      if (isUsableLanAddress(wifiIp)) {
        return wifiIp;
      }
    } catch (e) {
      // 插件在当前平台不可用时静默回退到网卡扫描
    }
    return null;
  }

  static LanAddressInfo? _selectBestLanAddress({
    required String? wifiIp,
    required List<NetworkAddressCandidate> candidates,
  }) {
    if (isUsableLanAddress(wifiIp)) {
      return LanAddressInfo(
        host: wifiIp!,
        source: 'network_info_plus.getWifiIP',
      );
    }

    _ScoredLanAddress? bestCandidate;
    for (final candidate in candidates) {
      final score = _scoreCandidate(candidate);
      if (score <= 0) {
        continue;
      }

      if (bestCandidate == null || score > bestCandidate.score) {
        bestCandidate = _ScoredLanAddress(
          score: score,
          host: candidate.address,
          source: candidate.interfaceName,
        );
      }
    }

    if (bestCandidate == null) {
      return null;
    }

    return LanAddressInfo(
      host: bestCandidate.host,
      source: bestCandidate.source,
    );
  }

  static int _scoreCandidate(NetworkAddressCandidate candidate) {
    if (!isUsableLanAddress(candidate.address)) {
      return 0;
    }

    final interfaceScore = _scoreInterfaceName(candidate.interfaceName);
    if (interfaceScore < 0) {
      return 0;
    }

    return interfaceScore + _scoreAddress(candidate.address);
  }

  static int _scoreInterfaceName(String interfaceName) {
    final normalized = interfaceName.toLowerCase();
    const blockedPrefixes = <String>[
      'lo',
      'tun',
      'utun',
      'tap',
      'ppp',
      'rmnet',
      'ccmni',
      'pdp',
      'r_rmnet',
      'v4-rmnet',
      'ipsec',
      'wg',
      'zt',
      'docker',
      'veth',
      'virbr',
      'vmnet',
      'bridge100',
      'awdl',
      'llw',
      'clat',
    ];

    for (final prefix in blockedPrefixes) {
      if (normalized.startsWith(prefix) || normalized.contains(prefix)) {
        return -1;
      }
    }

    if (normalized.contains('wifi') || normalized.contains('wi-fi')) {
      return 300;
    }
    if (normalized.startsWith('wlan') || normalized.startsWith('wl')) {
      return 290;
    }
    if (normalized.startsWith('ap')) {
      return 280;
    }
    if (normalized.startsWith('eth') ||
        normalized.startsWith('en') ||
        normalized.contains('ethernet')) {
      return 260;
    }
    if (normalized.contains('bridge') || normalized.startsWith('br')) {
      return 220;
    }

    return 100;
  }

  static int _scoreAddress(String address) {
    if (address.startsWith('192.168.')) {
      return 30;
    }
    if (address.startsWith('172.')) {
      return 20;
    }
    if (address.startsWith('10.')) {
      return 10;
    }
    return 0;
  }

  static bool _isValidIpv4(String? address) {
    if (address == null || address.isEmpty) {
      return false;
    }

    final parsed = InternetAddress.tryParse(address);
    return parsed != null && parsed.type == InternetAddressType.IPv4;
  }

  static bool _isEmulatorAddress(String address) {
    return address == '10.0.2.15' || address == '10.0.3.15';
  }

  /// 检查是否为私有地址
  static bool _isPrivateAddress(String address) {
    // 10.x.x.x
    if (address.startsWith('10.')) return true;
    // 172.16.x.x - 172.31.x.x
    if (address.startsWith('172.')) {
      final parts = address.split('.');
      if (parts.length >= 2) {
        final second = int.tryParse(parts[1]) ?? 0;
        if (second >= 16 && second <= 31) return true;
      }
    }
    // 192.168.x.x
    if (address.startsWith('192.168.')) return true;
    return false;
  }
}

class _ScoredLanAddress {
  const _ScoredLanAddress({
    required this.score,
    required this.host,
    required this.source,
  });

  final int score;
  final String host;
  final String source;
}
