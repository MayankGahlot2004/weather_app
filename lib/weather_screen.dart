import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'hourly_forecast_item.dart';
import 'Additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';




class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String,dynamic>>? weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = getCurrentWeather();
  }

  Future<Map<String,dynamic>> getCurrentWeather() async{
   
   try {

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
      }
      if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever){
        return fetchWeatherForCity('Delhi');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
      String? cityName = placemark.isNotEmpty ? placemark[0].locality : 'Delhi';

      if(cityName == null || cityName.isEmpty)
      {
        cityName = 'Delhi';
      }
      return fetchWeatherForCity(cityName);
      /*
      String cityName = 'Jalandhar';
      final res = await http.get(
        Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,IN&APPID=$openWeatherApiKey&units=metric'
      ),
      );
      final data = jsonDecode(res.body);

      return data;
      */
   } catch (e) {
      return fetchWeatherForCity('Delhi');
   }
  }

  Future<Map<String, dynamic>> fetchWeatherForCity(String cityName) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,IN&APPID=$openWeatherApiKey&units=metric';

    final res = await http.get(Uri.parse(url));

    if(res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
    
      
  

  @override
  Widget build(BuildContext context) {
    List<Widget>buildCards(List<dynamic> forecastList, String cityName) {
      final currWeatherData = forecastList[0];
      final currTemp = currWeatherData['main']['temp'];
        final currSky = currWeatherData['weather'][0]['main'];
        final currPressure = currWeatherData['main']['pressure'];
        final currWindSpeed = currWeatherData['wind']['speed'];
        final currHumidity = currWeatherData['main']['humidity'];

      return [
              //main card
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
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              cityName,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              '${currTemp.round()}°C',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              currSky == 'Clouds' || currSky == 'Rain' ? Icons.cloud : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$currSky',
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


              //Weather Forecast cards
              const SizedBox(height: 20),
              const Text(
                'Weather Forecast',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
             
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index)
                {
                  final hourlyForecast = forecastList[index + 1];
                  final time = DateTime.parse(hourlyForecast['dt_txt']);
                  final weatherIcon = hourlyForecast['weather'][0]['main'];

                  return HourlyForecastItem(
                    time: DateFormat.j().format(time),
                    icon: weatherIcon == 'Clouds' || weatherIcon == 'Rain' ? Icons.cloud : Icons.sunny,
                    temp: '${hourlyForecast['main']['temp'].round()}°C',
                  );
                }
              ),
              ),
              
          
              //Additional Cards
              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$currHumidity',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '$currWindSpeed'
                  ),
                  AdditionalInfoItem(
                    icon: Icons.compress,
                    label: 'Pressure',
                    value: '$currPressure',
                  ),
                ],
              ),
            ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weatherFuture = getCurrentWeather();
              });
            },
             icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        //Loading State Handled
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return LinearProgressIndicator();
          }

          //Error State Handling
          if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currWeatherList = data['list'];
          final String cityName = data['city']['name'];

          

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildCards(currWeatherList, cityName),
            ),
          );
        }
      ),
    );
  }
}



