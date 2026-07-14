import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visitor.dart';

const String baseUrl = "http://192.168.103.130:8000";

class ApiService {
  // GET all visitors
  static Future<List<Visitor>> getVisitors() async {
    final response = await http.get(Uri.parse('$baseUrl/visitors'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((map) => Visitor.fromMap(map)).toList();
    } else {
      throw Exception('Failed to load visitors');
    }
  }

  // POST — register new visitor
  static Future<Visitor> insertVisitor(Visitor visitor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visitors'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visitor.toApiMap()),
    );

     print('INSERT RESPONSE: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Visitor.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register visitor');
    }
  }

  // PUT — update visitor (time out)
  static Future<void> checkoutVisitor(int id, {String? pin}) async {
  final url = '$baseUrl/visitors/$id/checkout';
  final body = pin != null ? jsonEncode({'pin': pin}) : jsonEncode({});

  final response = await http.put(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to checkout visitor');
  }
}

  // GET pin by visitor ID
  static Future<String> getVisitorPin(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/visitors/$id/pin'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pin'].toString();
    } else {
      throw Exception('Failed to fetch PIN');
    }
  }
}
