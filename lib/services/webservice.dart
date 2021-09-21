import 'dart:convert';
import 'package:flutter_projects/models/news.dart';
import 'package:http/http.dart' as http;


Future<List<NewsContent>> fetchContent() async{
  final response = await http.get(
    Uri.parse('https://connect.bcplindia.co.in/MobileAppAPI/News_Events'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //return NewsContent.fromJson(jsonDecode(response.body));

    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((newscontent) => new NewsContent.fromJson(newscontent)).toList();
  } else {
    // If the server did not return a 200 OK response,
    print("The error message is: ${response.body}");
    throw Exception('Failed to authenticate.');
  }
}