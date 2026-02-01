import 'dart:io';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'services/voice_feedback_service.dart';
import 'widgets/scan_result_panel.dart';
import 'widgets/plate_guide_overlay.dart';
import '../../models/parking_vehicle.dart';
import '../../models/vehicle_scan_voice.dart';
import '../../features/ocr/vehicle_ocr_service.dart';
import 'services/parking_api.dart';
import '../../core/sessions/session_context.dart';


class VehicleScanScreen extends StatefulWidget {
  const VehicleScanScreen({super.key});

  @override
  State<VehicleScanScreen> createState() => _VehicleScanScreenState();
}

class _VehicleScanScreenState extends State<VehicleScanScreen> {
  CameraController? _controller;
  Timer? _scanTimer;
  bool _isProcessing = false;
  Rect? overlayRect;
  final Map<String, int> _plateCounter = {};
  String? _confirmedPlate;

  ParkingVehicle? _result;
  bool _isLoading = false;
  late final SessionContext _sessionContext;
  bool _sessionInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }
 
  @override
  void dispose() {
    _stopAutoScan();
    _controller?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_sessionInitialized) {
      _sessionContext = context.read<SessionContext>();
      _sessionInitialized = true;
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
 
      if (mounted) setState(() {});
  
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateOverlayRect(context);
      });
    } catch (e, stack) {
      debugPrint('Camera init failed: $e');
      if (mounted) setState(() {});  // 에러 상태도 업데이트
    }
  }

  Future<void> _autoScan() async {

    if (_confirmedPlate != null) return;
    if(_isProcessing == true) return;

    _isProcessing = true;

    try {
      final rect = overlayRect;
       
      if (rect == null) return;

      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) return;
       
      final picture = await controller.takePicture();
       
      final croppedFile = await cropByOverlay(
        imageFile: picture,
        overlayRect: rect,
        screenSize: MediaQuery.of(context).size,
      );
       
      final plate = await ocrReadPlate(croppedFile);
       
      if (plate != null) {
        _accumulatePlate(plate);
      }
    } catch (e) {
      debugPrint('Auto scan error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _onScanResult(ParkingVehicle result) {
    setState(() {
      _result = result;
      _isLoading = false;
    });
  
    VoiceFeedbackService().speak(result.voiceMessage!);
  }
  
  void _calculateOverlayRect(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    const overlayWidth = 320.0;
    const overlayHeight = 160.0;

    final left = (screenSize.width - overlayWidth) / 2;
    final top = (screenSize.height - overlayHeight) / 2;

    setState(() {
      overlayRect = Rect.fromLTWH(
        left,
        top,
        overlayWidth,
        overlayHeight,
      );
    });
 
    _startAutoScan();
  }

  Future<File> cropByOverlay({
    required XFile imageFile,
    required Rect overlayRect,
    required Size screenSize,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final original = img.decodeImage(bytes)!;

    final scaleX = original.width / screenSize.width;
    final scaleY = original.height / screenSize.height;

    final cropX = (overlayRect.left * scaleX).round();
    final cropY = (overlayRect.top * scaleY).round();
    final cropWidth = (overlayRect.width * scaleX).round();
    final cropHeight = (overlayRect.height * scaleY).round();

    final cropped = img.copyCrop(
      original,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    final croppedFile = File('${imageFile.path}_crop.jpg');
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    return croppedFile;
  }

  Future<String?> ocrReadPlate(File imageFile) async {
    try {
      final ocrService = VehicleOcrService();
      
      final vehicleNumber = await ocrService.recognizePlate(File(imageFile.path));
      
      if (vehicleNumber == null || vehicleNumber.isEmpty) {
        debugPrint('번호판을 인식하지 못했습니다.');
      }
 
      return vehicleNumber;

    } catch (e) {
      _showError('촬영 중 오류가 발생했습니다.');  
    }
  }
  
  void _accumulatePlate(String plate) {
    final count = (_plateCounter[plate] ?? 0) + 1;
    _plateCounter[plate] = count;

    if (count >= 2 && _confirmedPlate == null) {
      _confirmedPlate = plate;
      _requestParkingInfo(plate);
    }
  }
  
  Future<void> _requestParkingInfo(String plate) async {
     
    setState(() => _isLoading = true);
    
    final result = await ParkingApi.getVehicle(plate, _sessionContext);
      
    _onScanResult(result);
  }
 
  void _onConfirm() {
    setState(() {
      _confirmedPlate = null;
      _result = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startAutoScan() {
    _scanTimer?.cancel();

    _scanTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _autoScan(),
    );
  }

  void _stopAutoScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }
 
  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('주차 차량 확인')),
      body: Stack(
        children: [
          // 📷 카메라 프리뷰
          Positioned.fill(
            child: CameraPreview(controller),
          ),
           
          // 🎯 번호판 가이드
          const PlateGuideOverlay(),
 
          // 하단 결과 패널 (오버레이)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBottomPanel(),
              ),
            ),
          ),  
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    // 로딩 중일 때
    if (_isLoading) {
      return Container(
        key: const ValueKey('loading'),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('차량 정보 조회 중...'),
          ],
        ),
      );

    }

    // 결과가 있을 때
    if (_result != null) {
      return Container(
        key: ValueKey('result_${_result!.vehicleNo}'),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: ScanResultPanel(
          result: _result!,
          isLoading: false,
          onConfirm: _onConfirm,
        
        ),
      );
    }
    return const SizedBox.shrink();
  }
}