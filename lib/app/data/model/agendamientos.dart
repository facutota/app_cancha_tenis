import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AgendamientosModel extends ChangeNotifier {
  static final AgendamientosModel _instance = AgendamientosModel._internal();
  SharedPreferences? _preferences;
  List<Agendamiento> _agendamientos = [];

  factory AgendamientosModel() {
    // Llamamos a un método estático para inicializar antes de devolver la instancia
    AgendamientosModel.initialize();
    return _instance;
  }

  AgendamientosModel._internal();

  // Método estático para inicializar
  static Future<void> initialize() async {
    await _instance._loadAgendamientos();
  }

  List<Agendamiento> get agendamientos => _agendamientos;

// Método para agregar un nuevo agendamiento
  void agregarAgendamiento(Agendamiento agendamiento) {
    // Verificar si la cancha ya tiene los 3 turnos agendados en la fecha seleccionada
    if (!canchaTieneTresTurnosAgendados(
        agendamiento.cancha, agendamiento.fecha)) {
      _agendamientos.add(agendamiento);
      _saveAgendamientos();
      notifyListeners();
    } else {
      // La cancha ya tiene los 3 turnos agendados, puedes manejar esto como desees (mostrar mensaje, etc.)
      if (kDebugMode) {
        print(
            'La cancha ${agendamiento.cancha} ya tiene los 3 turnos agendados para esta fecha.');
      }
    }
  }

  // Nuevo método para verificar si una cancha ya tiene los 3 turnos agendados en una fecha
  bool canchaTieneTresTurnosAgendados(String cancha, DateTime fecha) {
    // Lógica para verificar si la cancha tiene los 3 turnos agendados en la fecha
    // Devuelve true si ya tiene los 3 turnos, false en caso contrario
    final agendamientosEnFecha = _agendamientos.where((agendamiento) =>
        agendamiento.cancha == cancha &&
        agendamiento.fecha.year == fecha.year &&
        agendamiento.fecha.month == fecha.month &&
        agendamiento.fecha.day == fecha.day);

    return agendamientosEnFecha.length >= 3;
  }

  // Método para eliminar un agendamiento
  void borrarAgendamiento(int index) {
    _agendamientos.removeAt(index);
    _saveAgendamientos();
    notifyListeners();
  }

  void ordenarAgendamientosPorFecha() {
    _agendamientos.sort((a, b) => a.fecha.compareTo(b.fecha));
    notifyListeners();
  }

  // Cargar agendamientos desde SharedPreferences
  Future<void> _loadAgendamientos() async {
    _preferences = await SharedPreferences.getInstance();
    final List<String>? agendamientosStrings =
        _preferences?.getStringList('agendamientos');

    if (agendamientosStrings != null) {
      _agendamientos = agendamientosStrings
          .map(
              (agendamientoString) => Agendamiento.fromJson(agendamientoString))
          .toList();
      notifyListeners();
    }
  }

  // Guardar agendamientos en SharedPreferences
  Future<void> _saveAgendamientos() async {
    final List<String> agendamientosStrings =
        _agendamientos.map((agendamiento) => agendamiento.toJson()).toList();
    await _preferences?.setStringList('agendamientos', agendamientosStrings);
    notifyListeners();
  }
}

class Agendamiento {
  String cancha;
  DateTime fecha;
  String nombreUsuario;

  Agendamiento(
      {required this.cancha, required this.fecha, required this.nombreUsuario});

  // Método para convertir un Agendamiento a JSON
  String toJson() {
    return '{"cancha": "$cancha", "fecha": "${fecha.toIso8601String()}", "nombreUsuario": "$nombreUsuario"}';
  }

  // Método para crear un Agendamiento desde JSON
  factory Agendamiento.fromJson(String jsonString) {
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(jsonDecode(jsonString));
    return Agendamiento(
      cancha: json['cancha'],
      fecha: DateTime.parse(json['fecha']),
      nombreUsuario: json['nombreUsuario'],
    );
  }
}
