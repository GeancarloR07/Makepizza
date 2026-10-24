import 'package:cloud_firestore/cloud_firestore.dart';

/// Si no existe el doc `app_config/seed_v1` con { done: true },
/// inserta pizzas, bebidas e ingredientes de ejemplo y marca como hecho.
///
/// ⚠️ Requiere permisos de escritura según tus reglas de Firestore.
/// Si tu BD permite escribir sólo autenticado, llama a esto **después de login**.
class AutoSeeder {
  static const _flagDocPath = 'app_config/seed_v1';

  static Future<void> run() async {
    final db = FirebaseFirestore.instance;
    final flagRef = db.doc(_flagDocPath);

    // ¿Ya sembrado?
    final flagSnap = await flagRef.get();
    final already = flagSnap.data()?['done'] == true;
    if (already) return;

    // Datos demo
    final pizzas = [
      {
        'id': 'pz_margherita',
        'name': 'Margherita',
        'basePrice': 22000,
        'imageUrl': '',
        'description': 'Salsa de tomate, mozzarella y albahaca',
      },
      {
        'id': 'pz_pepperoni',
        'name': 'Pepperoni',
        'basePrice': 26000,
        'imageUrl': '',
        'description': 'Clásica con pepperoni y queso',
      },
      {
        'id': 'pz_hawaiana',
        'name': 'Hawaiana',
        'basePrice': 27000,
        'imageUrl': '',
        'description': 'Jamón + piña + queso',
      },
      {
        'id': 'pz_cuatro_quesos',
        'name': 'Cuatro Quesos',
        'basePrice': 30000,
        'imageUrl': '',
        'description': 'Mozzarella, parmesano, azul y provolone',
      },
      {
        'id': 'pz_vegetariana',
        'name': 'Vegetariana',
        'basePrice': 28000,
        'imageUrl': '',
        'description': 'Champiñón, pimentón, cebolla, aceitunas',
      },
    ];

    final drinks = [
      {
        'id': 'drk_cola_350',
        'name': 'Cola 350ml',
        'price': 5000,
        'imageUrl': '',
      },
      {
        'id': 'drk_sprite_350',
        'name': 'Sprite 350ml',
        'price': 5000,
        'imageUrl': '',
      },
      {
        'id': 'drk_soda_600',
        'name': 'Soda 600ml',
        'price': 6000,
        'imageUrl': '',
      },
      {
        'id': 'drk_jugo_naranja',
        'name': 'Jugo de naranja 500ml',
        'price': 7000,
        'imageUrl': '',
      },
      {
        'id': 'drk_agua_600',
        'name': 'Agua 600ml',
        'price': 4000,
        'imageUrl': '',
      },
    ];

    final ingredients = [
      {'id': 'ing_pepperoni', 'name': 'Pepperoni', 'price': 3000},
      {'id': 'ing_jamon', 'name': 'Jamón', 'price': 2500},
      {'id': 'ing_pina', 'name': 'Piña', 'price': 2000},
      {'id': 'ing_champinon', 'name': 'Champiñón', 'price': 2000},
      {'id': 'ing_pimenton', 'name': 'Pimentón', 'price': 1500},
      {'id': 'ing_cebolla', 'name': 'Cebolla', 'price': 1500},
      {'id': 'ing_aceitunas', 'name': 'Aceitunas', 'price': 2000},
      {'id': 'ing_extra_queso', 'name': 'Extra queso', 'price': 2500},
      {'id': 'ing_tomate', 'name': 'Tomate', 'price': 1500},
      {'id': 'ing_maiz', 'name': 'Maíz', 'price': 1500},
    ];

    // Escribimos con WriteBatch para eficiencia/atomicidad
    final batch = db.batch();

    for (final p in pizzas) {
      final ref = db.collection('products').doc(p['id'] as String);
      batch.set(ref, p, SetOptions(merge: true));
    }
    for (final d in drinks) {
      final ref = db.collection('drinks').doc(d['id'] as String);
      batch.set(ref, d, SetOptions(merge: true));
    }
    for (final i in ingredients) {
      final ref = db.collection('ingredients').doc(i['id'] as String);
      batch.set(ref, i, SetOptions(merge: true));
    }

    // Marcador de "ya sembrado"
    batch.set(flagRef, {
      'done': true,
      'at': FieldValue.serverTimestamp(),
      'by': 'auto_seed',
      'version': 1,
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
