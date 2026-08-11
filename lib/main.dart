import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  Map<String, dynamic>? weatherData;

  Future<void> fetchWeather(String cityName) async {
    final apiKey = "3285bd87dd3e0f2272674bc7459ab255";
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['sys'] != null) {
        if (data['sys']['sunrise'] != null) {
          int sunrise = data['sys']['sunrise'];
          DateTime sunriseTime = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000).toLocal();
          data['sys']['sunrise'] = DateFormat('h:mm a').format(sunriseTime);
        }
        if (data['sys']['sunset'] != null) {
          int sunset = data['sys']['sunset'];
          DateTime sunsetTime = DateTime.fromMillisecondsSinceEpoch(sunset * 1000).toLocal();
          data['sys']['sunset'] = DateFormat('h:mm a').format(sunsetTime);
        }
      }

      setState(() {
        city = data['name'];
        temperature = data['main']['temp'].toString();
        description = data['weather'][0]['description'];
        iconCode = data['weather'][0]['icon'];
        weatherData = data;
      });
    } else {
      setState(() {
        city = "Not Found";
        temperature = "";
        description = "";
        iconCode = "";
        weatherData = {"error": "Status ${response.statusCode}"};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  Widget buildJsonTable(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        border: TableBorder.all(color: Colors.grey.shade300),
        children: data.entries.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  entry.key,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: entry.value is Map || entry.value is List
                    ? buildJsonTable(entry.value)
                    : Text(
                        entry.value.toString(),
                        style: TextStyle(fontSize: 14),
                      ),
              ),
            ],
          );
        }).toList(),
      );
    } else if (data is List) {
      return Column(
        children: data.map((item) => buildJsonTable(item)).toList(),
      );
    } else {
      return Text(data.toString(), style: TextStyle(fontSize: 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Weather App",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "$city",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "$temperature °C",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "$description",
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  if (iconCode.isNotEmpty)
                    Center(
                      child: Image.network(
                        "https://openweathermap.org/img/wn/$iconCode@2x.png",
                        width: 100,
                        height: 100,
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            if (weatherData != null) buildJsonTable(weatherData!),
          ],
        ),
      ),
    );
  }
}
