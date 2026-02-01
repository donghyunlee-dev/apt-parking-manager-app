import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/sessions/session_context.dart';
import 'home_action_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
    
  @override
  Widget build(BuildContext context) {
     
    final session = context.watch<SessionContext>().session;
    debugPrint("session : $session");
      
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          session!.aptName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // TODO 설정 화면 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UserHeader(bouncerName: session!.bouncerName),
            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                HomeActionCard(
                  title: '입주 차량 등록',
                  assetPath: 'assets/icons/resident_car.png',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/resident/vehicle/register',
                    );
                  },
                ),
                HomeActionCard(
                  title: '방문 차량 등록',
                  assetPath: 'assets/icons/visitor_car.png',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/visitor/vehicle/register'
                    );
                  },
                ),
                HomeActionCard(
                  title: '주차 차량 조회',
                  assetPath: 'assets/icons/parking_check.png',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/vehicle-scan',   
                    );
                  },
                ),
                HomeActionCard(
                  title: '차량 조회',
                  assetPath: 'assets/icons/vehicle_search.png',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),
            _NoticeSection(),
          ],
        ),
      ),
    );
  }
}


class _UserHeader extends StatelessWidget {
  final String bouncerName;

  const _UserHeader({required this.bouncerName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundImage: AssetImage('assets/images/avatar_guard.png'),
        ),
        const SizedBox(width: 12),
        Text(
          '안녕하세요, $bouncerName님',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NoticeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '주차장 점검 안내',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '내일 오전 10시 정기 점검이 진행됩니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}