import 'package:flutter/material.dart';
import '../../../models/parking_vehicle.dart';
import '../../../core/constants/colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 16),
          Text(
            result.vehicleNo,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.black,
            ),
          ),
          if (result.info != null) ...[
            const SizedBox(height: 8),
            Text(
              result.info!,
              style: const TextStyle(fontSize: 18, color: AppColors.greyText),
            ),
          ],
          const SizedBox(height: 24),
          
          if (result.status == VehicleStatus.illegal)
            _buildActionButtons(context),
            
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.black,
              ),
              child: const Text('닫기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        result.statusText,
        style: TextStyle(
          color: _statusColor(),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/resident/vehicle/register',
                    arguments: result.vehicleNo,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('입주민 등록', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/visitor/vehicle/register',
                    arguments: result.vehicleNo,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('방문객 등록', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _statusColor() {
    switch (result.status) {
      case VehicleStatus.resident: return AppColors.success;
      case VehicleStatus.visit: return AppColors.primary;
      case VehicleStatus.illegal: return AppColors.error;
    }
  }
}