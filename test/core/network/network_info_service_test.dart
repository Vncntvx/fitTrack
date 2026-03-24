import 'package:fittrack/core/network/network_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('优先使用 network_info_plus 返回的 Wi-Fi 地址', () {
    final result = NetworkInfoService.selectBestLanIp(
      wifiIp: '192.168.31.24',
      candidates: const [
        NetworkAddressCandidate(
          interfaceName: 'rmnet_data0',
          address: '10.12.0.8',
        ),
        NetworkAddressCandidate(
          interfaceName: 'wlan0',
          address: '192.168.31.9',
        ),
      ],
    );

    expect(result, '192.168.31.24');
  });

  test('跳过蜂窝和 VPN 地址，优先选择 Wi-Fi 或以太网地址', () {
    final result = NetworkInfoService.selectBestLanIp(
      candidates: const [
        NetworkAddressCandidate(
          interfaceName: 'rmnet_data0',
          address: '10.123.45.6',
        ),
        NetworkAddressCandidate(interfaceName: 'tun0', address: '10.8.0.2'),
        NetworkAddressCandidate(
          interfaceName: 'wlan0',
          address: '192.168.0.88',
        ),
      ],
    );

    expect(result, '192.168.0.88');
  });

  test('拒绝模拟器私网地址作为可访问局域网地址', () {
    final result = NetworkInfoService.selectBestLanIp(
      candidates: const [
        NetworkAddressCandidate(interfaceName: 'eth0', address: '10.0.2.15'),
      ],
    );

    expect(result, isNull);
  });
}
