import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class FirebaseRestoreService {
  late final DatabaseReference _db;

  FirebaseRestoreService._internal();

  static final FirebaseRestoreService _instance =
      FirebaseRestoreService._internal();
  factory FirebaseRestoreService() => _instance;

  Future<void> init() async {
    _db = FirebaseDatabase.instance.ref();
  }

  /// Lấy trạng thái coin hiện tại của user
  Future<Map<String, dynamic>?> getUserCoins({required String userId}) async {
    final snapshot = await _db.child('users/$userId/coins').get();

    if (!snapshot.exists) return null;

    final value = snapshot.value;
    if (value is Map) {
      return Map<String, dynamic>.from(value as Map);
    }
    return null;
  }

  Future<void> saveCoins({
    required String userId,
    required int totalCoins,
    required String productId,
    required String originalTransactionId,
    int? purchaseTime,
  }) async {
    final db = FirebaseDatabase.instance.ref('users/$userId');

    purchaseTime ??= DateTime.now().millisecondsSinceEpoch;

    await db
        .runTransaction((mutable) {
          final data = Map<String, dynamic>.from(mutable as Map? ?? {});

          data['coins'] ??= {};
          data['coins']['totalCoins'] = totalCoins;
          data['coins']['restoreUsed'] = false;
          data['coins']['restoreAt'] = null;
          data['coins']['lastUpdateAt'] = ServerValue.timestamp;

          data['iapHistory'] ??= {};

          if (data['iapHistory'][originalTransactionId] != null) {
            return Transaction.abort();
          }

          data['iapHistory'][originalTransactionId] = {
            'productId': productId,
            'coin': totalCoins,
            'purchaseTime': purchaseTime,
          };

          return Transaction.success(data);
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Firebase transaction timeout');
          },
        );
  }

  Future<void> grantTransaction({
    required String userId,
    required String originalTransactionId,
    required Map<String, dynamic> data,
    required int totalCoins,
  }) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');

    await ref.runTransaction((mutable) {
      final map = Map<String, dynamic>.from(mutable as Map? ?? {});
      map['coins'] ??= {};
      map['coins']['totalCoins'] = totalCoins;
      map['coins']['lastUpdateAt'] = ServerValue.timestamp;
      map['iapHistory'] ??= {};
      map['iapHistory'][originalTransactionId] = data;
      return Transaction.success(map);
    });
  }

  Future<int?> applyPurchaseTransaction({
    required String userId,
    required String productId,
    required int coin,
    required String originalTransactionId,
    required int purchaseTime,
  }) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');

    final result = await ref.runTransaction((mutable) {
      final data = Map<String, dynamic>.from(mutable as Map? ?? {});

      data['coins'] ??= {};
      data['iapHistory'] ??= {};

      if (data['iapHistory'][originalTransactionId] != null) {
        return Transaction.abort();
      }

      final currentCoins = (data['coins']['totalCoins'] ?? 0) as int;
      final newTotalCoins = currentCoins + coin;

      data['coins']['totalCoins'] = newTotalCoins;
      data['coins']['restoreUsed'] = false;
      data['coins']['restoreAt'] = null;
      data['coins']['lastUpdateAt'] = ServerValue.timestamp;

      data['iapHistory'][originalTransactionId] = {
        'productId': productId,
        'coin': coin,
        'purchaseTime': purchaseTime,
      };

      return Transaction.success(data);
    });

    if (!result.committed) return null;

    final snap = result.snapshot.value as Map;
    return snap['coins']['totalCoins'] as int;
  }

  Future<bool> isTransactionGranted({
    required String userId,
    required String originalTransactionId,
  }) async {
    final ref = FirebaseDatabase.instance.ref(
      'users/$userId/iapHistory/$originalTransactionId',
    );

    final snap = await ref.get();
    return snap.exists;
  }

  updateCoin({required String userId, required int totalCoins}) async {
    final data = {
      'totalCoins': totalCoins,
      'lastUpdateAt': ServerValue.timestamp,
    };
    await _db
        .child('users/$userId/coins')
        .update(data)
        .timeout(
          Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException("FirebaseRestoreService: Timeout");
          },
        );
  }

  Future<int?> restoreCoins({required String userId}) async {
    final ref = _db.child('users/$userId/coins');

    final result = await ref.runTransaction((mutable) {
      final data = Map<String, dynamic>.from(mutable as Map? ?? {});

      // ❌ Chưa từng mua / chưa có coin
      if (data['totalCoins'] == null) {
        return Transaction.abort();
      }

      // ❌ Đã restore rồi → không cho nữa
      if (data['restoreUsed'] == true) {
        return Transaction.abort();
      }

      // ✅ Lần restore đầu tiên
      data['restoreUsed'] = true;
      data['restoreAt'] = ServerValue.timestamp;

      return Transaction.success(data);
    });

    if (!result.committed) return null;

    final snapshot = result.snapshot.value as Map?;
    if (snapshot == null) return null;

    final coins = snapshot['totalCoins'];
    return coins is int ? coins : null;
  }

  Future<void> clearCoins({required String userId}) async {
    await _db.child('users/$userId/coins').remove();
  }
}
