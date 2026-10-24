import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Stream de órdenes por usuario (más recientes primero)
final ordersStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
      final q = FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true);

      return q.snapshots().map((snap) {
        return snap.docs.map((d) {
          final data = d.data();
          return {'id': d.id, ...data};
        }).toList();
      });
    });
