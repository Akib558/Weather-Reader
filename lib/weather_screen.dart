import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // String cityName = 'Dhaka';
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=Dhaka,bd&APPID=d36da5a42396dc950cd00a2d6cbe2db4'));

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "An unexpected error";
      }

      return data;

      // print(data['list'][0]['main']['temp']);

      // temp = data['list'][0]['main']['temp'] - 273;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather Reader",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          //Inkwell can be used
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        // future: getCurrentWeather(),
        future: weather,
        builder: (context, snapshot) {
          // print(snapshot);
          // print(snapshot.runtimeType);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 10,
            ));
          }

          final data = snapshot.data!;
          final currecntTemperature = data['list'][0]['main']['temp'] - 273;
          final currentWeather = data['list'][0]['weather'][0]['main'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final currentWindSpeed = data['list'][0]['wind']['speed'];
          final currentPressure = data['list'][0]['main']['pressure'];
          // currecntTemperature = currecntTemperature

          return Padding(
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  "${currecntTemperature.toStringAsFixed(2)} °C",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  currentWeather == 'Rain'
                                      ? Icons.water
                                      : currentWeather == 'Clouds'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                  size: 70,
                                ),
                                Text(
                                  "${currentWeather}",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Text(
                    "Weather Forecast: ",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       for(int i = 1; i <= 30; i++)
                  //         HourlyForecastItem(
                  //           icon: data['list'][0]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                  //           time: data['list'][0]['dt'].toString(),
                  //           temp: (data['list'][0]['main']['temp']-273).toStringAsFixed(2)+' °C'),
                  //     ],
                  //   ),
                  // ),

                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      itemCount: 6,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final timee =
                            DateTime.parse(data['list'][index + 1]['dt_txt']);

                        return HourlyForecastItem(
                            icon: data['list'][index + 1]['weather'][0]
                                        ['main'] ==
                                    'Rain'
                                ? Icons.water
                                : data['list'][index + 1]['weather'][0]
                                            ['main'] ==
                                        'Clouds'
                                    ? Icons.cloud
                                    : Icons.sunny,
                            time: DateFormat.jm().format(timee).toString(),
                            // time: data['list'][index+1]['dt_txt'].toString(),
                            temp:
                                (data['list'][index + 1]['main']['temp'] - 273)
                                        .toStringAsFixed(2) +
                                    ' °C');
                      },
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Text(
                    "Additional Information: ",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInformation(
                          icon: Icons.water_drop,
                          top: "Humidity",
                          bottom: "${currentHumidity}"),
                      AdditionalInformation(
                          icon: Icons.air,
                          top: "Wind Speed",
                          bottom: "${currentWindSpeed}"),
                      AdditionalInformation(
                          icon: Icons.umbrella,
                          top: "Pressure",
                          bottom: "${currentPressure}"),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0),
      child: SizedBox(
        // height: double.infinity,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10,
                ),
                Icon(
                  icon,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(temp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdditionalInformation extends StatelessWidget {
  final IconData icon;
  final String top;
  final String bottom;
  const AdditionalInformation({
    super.key,
    required this.icon,
    required this.top,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            top,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Text(
          bottom,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
