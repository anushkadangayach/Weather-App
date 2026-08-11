import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String city = "Jaipur";
  String temperature = "";
  String description = "";
  String iconCode = "";

  // ✅ Fetch weather data from OpenWeatherMap API
  Future<void> fetchWeather(String cityName) async {
    final apiKey = "3285bd87dd3e0f2272674bc7459ab255"; // Replace with your OpenWeatherMap API key
   final url = "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric";
  


    final response = await http.get(Uri.parse(url));
     print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        city = data['name'];
        temperature = data['main']['temp'].toString();
        description = data['weather'][0]['description'];
        iconCode = data['weather'][0]['icon'];
      });
    } else {
      setState(() {
        city = "Not Found";
        temperature = "";
        description = "";
        iconCode = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city); // Load default city weather
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather App")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter City",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  fetchWeather(value);
                  _controller.clear();
                }
              },
            ),
            SizedBox(height: 20),
            if (temperature.isNotEmpty)
              Column(
                children: [
                  Text(
                    "$city",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$temperature °C",
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    "$description",
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  if (iconCode.isNotEmpty)
                    Image.network(
                      "https://openweathermap.org/img/wn/$iconCode@2x.png",
                      width: 100,
                      height: 100,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
