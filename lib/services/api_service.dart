import 'package:dio/dio.dart';

class ApiService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000/api',
    ),
  );

  Future<List<dynamic>> getProperties() async {

    final response = await dio.get('/properties');

    return response.data;
  }
}