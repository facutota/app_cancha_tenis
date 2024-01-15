import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/prob_precipitacion/prob_precipitacion.dart';
import '../../data/model/agendamientos.dart';
import 'add_shift_screen.dart';

class HomeScreen extends StatefulWidget {
  final AgendamientosModel agendamientosModel;

  const HomeScreen({required this.agendamientosModel, Key? key})
      : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnos Agendados'),
      ),
      body: Consumer<AgendamientosModel>(
        builder: (context, agendamientosModel, child) {
          // Obtener los turnos futuros
          List<Agendamiento> turnosFuturos = widget
              .agendamientosModel.agendamientos
              .where((turno) => turno.fecha
                  .isAfter(DateTime.now().subtract(const Duration(days: 1))))
              .toList();

          turnosFuturos.sort((a, b) => a.fecha.compareTo(b.fecha));

          return turnosFuturos.isEmpty
              ? const Center(
                  child: Text(
                      'No hay turnos agendados, toca el icono (+) para agendar un turno.'),
                )
              : ListView.builder(
                  itemCount: turnosFuturos.length,
                  itemBuilder: (context, index) {
                    Agendamiento agendamiento = turnosFuturos[index];

                    return ListTile(
                      title: Text('Cancha: ${agendamiento.cancha}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha: ${DateFormat('dd-MM-yyyy').format(agendamiento.fecha.toLocal())}',
                          ),
                          Text('Usuario: ${agendamiento.nombreUsuario}'),
                          // Puedes agregar porcentaje de probabilidad de lluvia aquí
                          //https://api.meteomatics.com/2024-01-16T15:00:00Z/prob_precip_24h:p/-34.61315,-58.37723/json
                          // Asegúrate de que el método que devuelve el Future esté marcado como async
                          FutureBuilder<PronosticoLluvia?>(
                            future:
                                probPrecipitacion(agendamiento.fecha.toLocal()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                final pronostico = snapshot.data;
                                if (pronostico != null) {
                                  return Column(
                                    children: [
                                      Icon(pronostico.icono),
                                      const SizedBox(height: 8),
                                      Text(
                                        pronostico.mensaje,
                                        style:
                                            const TextStyle(color: Colors.red),
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
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.red[400],
                                title: const Text(
                                  "Borrar Turno",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "¿Estás seguro de querer borrar este turno?",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Cancha: ${agendamiento.cancha}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Fecha: ${DateFormat('dd-MM-yyyy').format(agendamiento.fecha.toLocal())}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Usuario: ${agendamiento.nombreUsuario}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back(); // Cierra el AlertDialog
                                    },
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Llamar al método del modelo para borrar agendamiento
                                      agendamientosModel
                                          .borrarAgendamiento(index);
                                      Get.back(); // Cierra el AlertDialog
                                    },
                                    child: const Text(
                                      "Sí",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de agregar agendamiento
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddShiftScreen(widget.agendamientosModel)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
