import 'package:flutter/material.dart';
import '../../../models/parking_vehicle.dart';

class ScanResultPanel extends StatelessWidget {
  final ParkingVehicle result;
  final bool isLoading;
  final VoidCallback onConfirm;

  const ScanResultPanel({
    super.key,
    required this.result,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 12),
          _buildPlateNumber(),
          if (result.info != null) ...[
            const SizedBox(height: 8),
            _buildUnitInfo(),
          ],
          const SizedBox(height: 16),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  /// 차량 상태 배지 (입주 / 방문 / 미등록)
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(), color: _statusColor()),
          const SizedBox(width: 8),
          Text(
            result.statusText,
            style: TextStyle(
              color: _statusColor(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 차량 번호
  Widget _buildPlateNumber() {
    return Text(
      result.vehicleNo,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  /// 등록 호수
  Widget _buildUnitInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.home, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          result.info!,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 확인 버튼
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _statusColor(),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onConfirm,
        child: const Text(
          '확인',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _statusColor() {
    switch (result.status) {
      case VehicleStatus.resident:
        return Colors.green;
      case VehicleStatus.visit:
        return Colors.blue;
      case VehicleStatus.illegal:
        return Colors.red;
    }
  }

  IconData _statusIcon() {
    switch (result.status) {
      case VehicleStatus.resident:
        return Icons.check_circle;
      case VehicleStatus.visit:
        return Icons.directions_car;
      case VehicleStatus.illegal:
        return Icons.warning;
    }
  }
}