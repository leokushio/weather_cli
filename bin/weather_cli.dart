import 'dart:convert';
import 'dart:io';
import 'package:ansi_modifier/ansi_modifier.dart';
import 'package:http/http.dart' as http;
import 'package:interact/interact.dart';

void main() async {
  const String APIKey = '6690d433aa4e5097590106qxb4ea3f0';
  // List<dynamic> coordinatesValue = [];
  List<CoordinatesData> locationsList = [];
  String? lat, lon;

  print('''
__    __ ____   ____  _____  _   _  ____ _____     ____  _     _ 
\\ \\/\\/ /| ===| / () \\|_   _|| |_| || ===|| () )   / (__`| |__ | |
 \\_/\\_/ |____|/__/\\__\\ |_|  |_| |_||____||_|\\_\\   \\____)|____||_|
'''
      .style(Ansi.green + Ansi.italic + Ansi.bold));

  while (true) {
    locationsList = [];
    print('Enter your city Name (q to quit):');
    String? city = stdin.readLineSync();
    if (city == 'q') {
      break;
    }

    try {
      var coordinatesResponse = await http.get(
          Uri.parse('https://geocode.maps.co/search?q=$city&api_key=$APIKey'));
      List<dynamic> coordinatesValue = jsonDecode(coordinatesResponse.body);

      for (var i = 0; i < coordinatesValue.length; i++) {
        locationsList.add(CoordinatesData(
          displayName: coordinatesValue[i]['display_name'],
          lat: coordinatesValue[i]['lat'],
          lon: coordinatesValue[i]['lon'],
        ));
      }

      final selection = Select(
              prompt: 'Select Location',
              options: locationsList.map((e) => e.displayName!).toList())
          .interact();

      lat = locationsList[selection].lat;
      lon = locationsList[selection].lon;
    } catch (e) {
      print(e);
    }
    print('');
    final loading = Spinner(
      icon: '🌥️',
      leftPrompt: (done) => '', // prompts are optional
      rightPrompt: (done) =>
          done ? 'Todays Weather' : 'searching afor weather information',
    ).interact();

    await Future.delayed(const Duration(seconds: 5));

    try {
      var response = await http.get(Uri.parse(
          'https://www.7timer.info/bin/civil.php?lon=$lon&lat=$lat&ac=0&unit=metric&output=json'));
      loading.done();
      Map<String, dynamic> responseValue = jsonDecode(response.body);
      print('\nWeather: '.style(Ansi.blue + Ansi.bold) +
          '${responseValue["dataseries"][0]['weather']}');
      print('Temperature: '.style(Ansi.blue + Ansi.bold) +
          '${responseValue["dataseries"][0]['temp2m']} \u00B0C');
    } catch (e) {
      print('wrong url'.style(Ansi.red));
    }
    // print('-----------------------------------------------');
  }

  print('Good bye!');
}

class CoordinatesData {
  String? displayName, lat, lon;

  CoordinatesData({this.displayName, this.lat, this.lon});
}
