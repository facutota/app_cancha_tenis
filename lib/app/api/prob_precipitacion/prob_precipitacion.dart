import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PronosticoLluvia {
  final IconData icono;
  final String mensaje;

  PronosticoLluvia(this.icono, this.mensaje);
}

Future<PronosticoLluvia?> probPrecipitacion(DateTime fecha) async {
  // Formatear la fecha en el formato necesario para la URL
  String formattedDate = '${DateFormat('yyyy-MM-dd').format(fecha)}T14:00:00Z';
  String accessToken = dotenv.env['ACCESS_TOKEN']!;

  final response = await http.get(Uri.parse(
      "https://api.meteomatics.com/$formattedDate/prob_precip_24h:p/-34.61315,-58.37723/json?access_token=$accessToken"));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    // Obtener el valor
    double? precipitationProbability =
        jsonData['data'][0]['coordinates'][0]['dates'][0]['value'];

    // Verificar si el valor existe y devolverlo
    if (precipitationProbability != null) {
      if (precipitationProbability < 20) {
        return PronosticoLluvia(Icons.wb_sunny, '$precipitationProbability %');
      } else if (precipitationProbability >= 20 &&
          precipitationProbability < 50) {
        return PronosticoLluvia(Icons.wb_cloudy, '$precipitationProbability %');
      } else {
        return PronosticoLluvia(
            Icons.beach_access, '$precipitationProbability %');
      }
    } else {
      // Manejar el caso en el que no se pudo obtener la precipitationProbability
      return PronosticoLluvia(Icons.warning, 'No disponible');
    }
  }

  // Manejar el caso donde no se pudo obtener la respuesta
  return Future.value(null);
}
