import 'package:flutter/material.dart';
import 'package:musang_syncronizehub_odyssey/dao/data_processing/process_data.dart';
import 'package:musang_syncronizehub_odyssey/features/core/models/dashboard/atgSummary_model.dart';
import 'package:musang_syncronizehub_odyssey/helpers/serializers.dart';
import 'package:musang_syncronizehub_odyssey/services/postgrest_service.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AtgSumDao {
  final PostgrestClient _client;

  AtgSumDao(PostgrestService service) : _client = service.client;

  /** Supabase Function: process_atg_summary_setof_atg_summary(fromDate,endDate,siteID)
   * Parameter: fromDate first date of user choice
   *            endDate last date of user choice
   *            siteID is the site base on assignment for each user has site after login 
   * Result : set of column data from table atg_summary( from_date, end_date, change, site_id)           
   *  */
  /* 
  Future<List<ATGSummaryModel>> readSetOf({DateTimeRange? dateRange}) async {
    final userList = await supabase.rpc('process_atg_summary_setof_atg_summary', 
       params: {'fromDate': dateRange.Start, 'end_date': dateRange.End, 'siteID': users.siteID}); 
  }
  */

  Future<List<ATGSummaryModel>> read(int page, int limit,
      {DateTimeRange? dateRange}) async {
    try {
      final int offset = (page - 1) * limit;
      var query = _client
          .from('atg_summary')
          .select(
              'id, from_date, end_date, from_tank_position, last_tank_position, change, site_id')
          .order('from_date', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;

      List<Map<String, dynamic>> data = response as List<Map<String, dynamic>>;

      if (dateRange != null) {
        data = data.where((item) {
          final fromDate = DateTime.parse(item['from_date']);
          final endDate = DateTime.parse(item['end_date']);
          return fromDate.isAfter(dateRange.start) &&
              endDate.isBefore(dateRange.end);
        }).toList();
      }

      print('Fetched Data: $data');
      List<ATGSummaryModel> atgSummaryModels = data
          .map((item) {
            return serializers.deserializeWith(
                ATGSummaryModel.serializer, item);
          })
          .where((item) => item != null)
          .toList()
          .cast<ATGSummaryModel>();
      return sortAtgSummaryData(atgSummaryModels);
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }
}
