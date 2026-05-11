import 'package:dio/dio.dart';
import 'package:ishara/core/constants/api_constants.dart';
import 'package:ishara/core/network/api_client.dart';
import '../models/contact_model.dart';

class ContactsRepository {
  final Dio _dio = ApiClient.getInstance();

  List<dynamic> _parseListResponse(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      final data =
          responseData['data'] ??
          responseData['contacts'] ??
          responseData['users'] ??
          [];
      if (data is List) return data;
    }
    return [];
  }

  Future<List<ContactModel>> getMyContacts() async {
    final response = await _dio.get(ApiConstants.getMyContacts);
    final list = _parseListResponse(response.data);
    return list.map((e) => ContactModel.fromJson(e)).toList();
  }

  Future<List<ContactModel>> searchContacts({
    required String query,
    int pageNumber = 1,
    int pageSize = 5,
  }) async {
    final response = await _dio.get(
      ApiConstants.searchContacts,
      queryParameters: {
        'user': query,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    final list = _parseListResponse(response.data);
    return list.map((e) => ContactModel.fromJson(e)).toList();
  }

  Future<void> addContact(String contactId) async {
    await _dio.post(
      ApiConstants.addContact,
      queryParameters: {'contactId': contactId},
    );
  }

  Future<void> deleteContact(String contactId) async {
    await _dio.delete(
      ApiConstants.deleteContact,
      queryParameters: {'contactId': contactId},
    );
  }
}
