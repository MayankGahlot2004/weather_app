# weather_app

**Flutter Weather App 🌦️**

A simple yet powerful weather forecast application built with Flutter. This app provides real-time weather data for the user's current location, offering a clean, intuitive, and modern user interface.

**Features**

Automatic Location Detection: On startup, the app automatically identifies the user's current location using the device's GPS to provide an instant, relevant forecast.

Real-Time Weather Data: Delivers up-to-the-minute weather information, including temperature, sky conditions (e.g., Clouds, Rain, Clear), humidity, wind speed, and atmospheric pressure.

Hourly Forecast: Displays a scrollable hourly forecast, allowing users to see temperature and weather changes throughout the day.

Dynamic UI: The user interface is built to be clean and responsive, with icons that change according to the current weather conditions.

Refresh Functionality: A simple refresh button allows users to fetch the latest weather data on demand.

Privacy-Focused: If location permission is denied, the app gracefully falls back to a default location (Delhi) without crashing.

**How It Works**

The app is built using the Flutter framework and the Dart programming language. It leverages the following to deliver its functionality:

OpenWeather API for fetching comprehensive weather data.

geolocator and geocoding packages to handle location detection and convert GPS coordinates to city names.

FutureBuilder to manage asynchronous API calls and efficiently update the UI with loading, error, and success states.
