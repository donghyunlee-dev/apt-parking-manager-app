import '../../../core/network/api_client.dart';
import '../../../core/sessions/session_context.dart';
import '../../../models/notice.dart';

class NoticeApi {
  static Future<List<Notice>> fetchNotices({
    required SessionContext sessionContext,
  }) async {
    final response = await ApiClient.get(
      path: '/api/notices',
      query: {
        'apt_code': sessionContext.session?.aptCode ?? '',
      },
      headers: sessionContext.headers,
    );

    final List<dynamic> data = response['payload'] ?? [];
    return data.map((json) => Notice.fromJson(json)).toList();
  }
}
