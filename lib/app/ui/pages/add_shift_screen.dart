import 'package:app_cancha_tenis/app/data/model/agendamientos.dart';
import 'package:app_cancha_tenis/app/ui/pages/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:intl/intl.dart';

import '../../api/prob_precipitacion/prob_precipitacion.dart';

class AddShiftScreen extends StatefulWidget {
  final AgendamientosModel agendamientosModel;

  const AddShiftScreen(this.agendamientosModel, {Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddShiftScreenState createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  DateTime _fechaSeleccionada = DateTime.now();
  String _canchaSeleccionada = 'Cancha A'; // Cancha por defecto
  String _nombreUsuario = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Turno'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _mostrarSelectorFecha();
              },
              child: const Text('Seleccionar Fecha'),
            ),
            const SizedBox(height: 20),
            Text(
              'Fecha seleccionada: ${DateFormat('dd-MM-yyyy').format(_fechaSeleccionada)}',
            ),
            const SizedBox(height: 20),
            FutureBuilder<PronosticoLluvia?>(
              future: probPrecipitacion(_fechaSeleccionada),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final pronostico = snapshot.data;
                  if (pronostico != null) {
                    return Column(
                      children: [
                        Icon(pronostico.icono),
                        const SizedBox(height: 8),
                        Text(
                          pronostico.mensaje,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    );
                  } else {
                    return Container(); // O cualquier otro widget si no hay pronóstico
                  }
                } else {
                  return const CircularProgressIndicator(); // Indicador de carga mientras se obtiene el pronóstico
                }
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _canchaSeleccionada,
              items: [
                'Cancha A',
                'Cancha B',
                'Cancha C',
              ].map((String cancha) {
                return DropdownMenuItem<String>(
                  value: cancha,
                  child: Text(
                    cancha,
                    style: TextStyle(
                      color: widget.agendamientosModel
                              .canchaTieneTresTurnosAgendados(
                        cancha,
                        _fechaSeleccionada,
                      )
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _canchaSeleccionada = newValue;
                  });
                }
              },
            ),
            if (widget.agendamientosModel.canchaTieneTresTurnosAgendados(
                _canchaSeleccionada, _fechaSeleccionada))
              const Text(
                'Cancha no disponible',
                style: TextStyle(
                  color: Colors.red,
                ),
              )
            else
              const Text(
                'Cancha Disponible',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (value) {
                  _nombreUsuario = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Nombre del Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Verificar si el nombre de usuario es válido (más de 3 letras)
                if (_nombreUsuario.length <= 3) {
                  // Mostrar un mensaje de error
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'El nombre de usuario debe tener más de 3 letras.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Verificar si la cancha está disponible antes de registrar
                  if (widget.agendamientosModel.canchaTieneTresTurnosAgendados(
                      _canchaSeleccionada, _fechaSeleccionada)) {
                    // Cancha no disponible
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'No se puede registrar ya que esta cancha no está disponible.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Cancha disponible, puedes registrar la reserva
                    Agendamiento nuevoAgendamiento = Agendamiento(
                      cancha: _canchaSeleccionada,
                      fecha: _fechaSeleccionada,
                      nombreUsuario: _nombreUsuario,
                    );

                    // Agregar el nuevo agendamiento al modelo
                    widget.agendamientosModel
                        .agregarAgendamiento(nuevoAgendamiento);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Turno Listo'),
                          content: const Text('Turno Registrado'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen(
                                          agendamientosModel:
                                              widget.agendamientosModel)),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar el selector de fecha
  Future<void> _mostrarSelectorFecha() async {
    await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now()
          .add(const Duration(days: 30)), // Puedes ajustar el rango como desees
      onChanged: (date) {
        if (kDebugMode) {
          print('Cambió: $date');
        }
      },
      onConfirm: (date) {
        setState(() {
          _fechaSeleccionada = date;
        });
      },
      currentTime: DateTime.now(),
    );
  }
}
