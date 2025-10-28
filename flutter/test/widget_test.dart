import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rutasfrontend/presentation/controllers/bus_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 INICIANDO TEST COMPLETO DEL SISTEMA DE RUTAS...');
  await testSistemaRutas();
}

Future<void> testSistemaRutas() async {
  try {
    final controller = BusControllerMejorado();

    // 🔥 COORDENADAS DE PRUEBA (Puno, Perú)
    final origen = LatLng(-15.8402, -70.0219); // Plaza de Armas Puno
    final destino = LatLng(-15.8334, -70.0276); // Estación de Bus Puno

    print('📍 ORIGEN: $origen');
    print('🎯 DESTINO: $destino');
    print('⏳ Calculando rutas...\n');

    final resultado = await controller.calcularMejorRuta(origen, destino);

    print('=' * 50);
    print('📊 RESULTADO DEL SISTEMA DE RUTAS');
    print('=' * 50);

    print('✅ Total rutas encontradas: ${resultado.totalRutas}');
    print('✅ Hay rutas directas: ${resultado.hayRutasDirectas ? 'SÍ' : 'NO'}');
    print('✅ Mensaje: ${resultado.mensaje}');

    if (resultado.hayRutas) {
      for (int i = 0; i < resultado.rutasRecomendadas.length; i++) {
        final ruta = resultado.rutasRecomendadas[i];
        print('\n' + '=' * 40);
        print('🚌 RUTA ${i + 1} - ${ruta.tipo}');
        print('=' * 40);
        print('⏰ Tiempo total: ${ruta.tiempoTotal} minutos');
        print(
          '📏 Distancia total: ${ruta.distanciaTotal.toStringAsFixed(2)} km',
        );
        print('📝 Instrucciones: ${ruta.instrucciones}');

        print('\n📋 DETALLE DE LA RUTA:');
        for (int j = 0; j < ruta.segmentos.length; j++) {
          final segmento = ruta.segmentos[j];
          final numero = j + 1;

          if (segmento.esBus) {
            print('   $numero. 🚌 ${segmento.instruccion}');
            print(
              '      ⏰ ${segmento.tiempoEstimado} min | 📏 ${segmento.distancia.toStringAsFixed(2)} km',
            );
          } else if (segmento.esCaminando) {
            print('   $numero. 🚶 ${segmento.instruccion}');
            print(
              '      ⏰ ${segmento.tiempoEstimado} min | 📏 ${segmento.distancia.toStringAsFixed(2)} km',
            );
          }
        }
      }
    } else {
      print('\n❌ No se encontraron rutas disponibles para esta ubicación');
      print('💡 Sugerencias:');
      print('   - Verifica que tengas rutas en tu base de datos');
      print('   - Aumenta el radio de búsqueda');
      print('   - Verifica las coordenadas de origen y destino');
    }

    print('\n' + '=' * 50);
    print('🧪 TEST COMPLETADO');
    print('=' * 50);
  } catch (e, stackTrace) {
    print('\n❌❌❌ ERROR DURANTE EL TEST ❌❌❌');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    print('\n💡 POSIBLES SOLUCIONES:');
    print('   1. Verifica que tu API esté funcionando');
    print('   2. Revisa la conexión a la base de datos');
    print('   3. Verifica que tengas rutas y puntos de ruta cargados');
  }
}
