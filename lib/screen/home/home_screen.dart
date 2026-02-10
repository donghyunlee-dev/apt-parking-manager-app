import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/sessions/session_context.dart';
import '../../../core/constants/colors.dart';
import '../../../models/notice.dart';
import 'home_action_card.dart';
import 'services/notice_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Notice>? _notices;
  bool _noticesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    try {
      final sessionContext = context.read<SessionContext>();
      final result = await NoticeApi.fetchNotices(sessionContext: sessionContext);
      if (mounted) {
        setState(() {
          _notices = result;
          _noticesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _noticesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionContext>().session;
      
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(session!.aptName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldExit = await _showExitDialog(context);
          if (shouldExit == true && context.mounted) {
            SystemNavigator.pop();
          }
        },
        child: RefreshIndicator(
          onRefresh: _loadNotices,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _UserHeader(bouncerName: session.bouncerName),
                const SizedBox(height: 32),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    HomeActionCard(
                      title: '입주 차량\n등록',
                      icon: Icons.person_add_rounded,
                      onTap: () => Navigator.pushNamed(context, '/resident/vehicle/register'),
                    ),
                    HomeActionCard(
                      title: '방문 차량\n등록',
                      icon: Icons.car_rental_rounded,
                      onTap: () => Navigator.pushNamed(context, '/visitor/vehicle/register'),
                    ),
                    HomeActionCard(
                      title: '주차 차량\n스캔',
                      icon: Icons.document_scanner_rounded,
                      onTap: () => Navigator.pushNamed(context, '/vehicle-scan'),
                    ),
                    HomeActionCard(
                      title: '전체 차량\n조회',
                      icon: Icons.search_rounded,
                      onTap: () => Navigator.pushNamed(context, '/vehicle/search'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Text(
                  '공지사항',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: 16),
                _NoticeSection(notices: _notices, isLoading: _noticesLoading),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('앱을 종료하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('종료', style: TextStyle(color: AppColors.error)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String bouncerName;

  const _UserHeader({required this.bouncerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘도 수고 많으십니다',
                  style: TextStyle(color: AppColors.greyText, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bouncerName님',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeSection extends StatelessWidget {
  final List<Notice>? notices;
  final bool isLoading;

  const _NoticeSection({this.notices, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (notices == null || notices!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
        child: const Text('등록된 공지사항이 없습니다.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.greyText)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: List.generate(notices!.length, (index) {
          final notice = notices![index];
          return Column(
            children: [
              _NoticeItem(notice: notice),
              if (index < notices!.length - 1)
                const Divider(height: 32, color: AppColors.divider),
            ],
          );
        }),
      ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final Notice notice;

  const _NoticeItem({required this.notice});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showNoticeDetail(context, notice);
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.category,
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  notice.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notice.createdAt.split('T')[0],
                  style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.divider),
        ],
      ),
    );
  }

  void _showNoticeDetail(BuildContext context, Notice notice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Area
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notice.category,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          notice.createdAt.split('T')[0],
                          style: const TextStyle(color: AppColors.greyText, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notice.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content Area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    notice.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.greyText,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              // Footer Area
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
