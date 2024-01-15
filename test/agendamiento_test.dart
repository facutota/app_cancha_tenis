import 'package:app_cancha_tenis/app/data/model/agendamientos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Asegurar que Flutter esté inicializado para las pruebas
  WidgetsFlutterBinding.ensureInitialized();
  test(
      'No se pueden registrar más de 3 turnos en la misma cancha para una fecha',
      () {
    // Arrange
    final agendamientosModel = AgendamientosModel();

    // Act
    // Registra 3 turnos en la misma cancha para una fecha específica
    agendamientosModel.agregarAgendamiento(Agendamiento(
      cancha: 'Cancha A',
      fecha: DateTime.now(),
      nombreUsuario: 'Usuario1',
    ));
    agendamientosModel.agregarAgendamiento(Agendamiento(
      cancha: 'Cancha A',
      fecha: DateTime.now(),
      nombreUsuario: 'Usuario2',
    ));
    agendamientosModel.agregarAgendamiento(Agendamiento(
      cancha: 'Cancha A',
      fecha: DateTime.now(),
      nombreUsuario: 'Usuario3',
    ));

    // Intenta registrar un cuarto turno en la misma cancha y fecha
    agendamientosModel.agregarAgendamiento(Agendamiento(
      cancha: 'Cancha A',
      fecha: DateTime.now(),
      nombreUsuario: 'Usuario4',
    ));

    // Assert
    // Verifica que la longitud de la lista sigan siendo 3
    expect(agendamientosModel.agendamientos.length, 3);
  });
}
