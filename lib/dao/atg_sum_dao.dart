import 'package:musang_syncronizehub_odyssey/features/core/models/dashboard/atgSummary_model.dart';
import 'package:musang_syncronizehub_odyssey/services/postgrest_service.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/**
 * Change to stored procedure or function in postgresql process_atg_summary(fromDate, endDate, siteID)
 * Feb 18 2024 11:01
 */
class AtgSumDao {
  final PostgrestClient _client;

  AtgSumDao(PostgrestService service) : _client = service.client;

  // Get all data fetches
  Future<List<ATGSummary>> read() async {
    final List<
        Map<String,
            dynamic>> response = await _client.from('atg_summary').select(
        'id, from_date, end_date, from_tank_position, last_tank_position, change');

    print('Data: ${response}');
    return response.map((item) => ATGSummary.fromJson(item)).toList();
  }
}
