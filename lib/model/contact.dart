import 'package:meta/meta.dart';
import 'package:sqflite/sql.dart';
import 'package:wallet/wallet.dart';

class Contact {
  Contact({
    @required this.fullname,
    @required this.address,
    this.contactId,
    this.createdAt,
    this.updatedAt,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      contactId: map['id'],
      address: map['address'],
      fullname: map['full_name'],
      createdAt: DateTime.parse(map['created_at']).toUtc(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at']).toUtc()
          : DateTime.parse(map['created_at']).toUtc(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'full_name': fullname,
      'created_at': createdAt?.toUtc()?.toIso8601String(),
      'updated_at': updatedAt?.toUtc()?.toIso8601String(),
    };
  }

  final String fullname, address;
  DateTime createdAt, updatedAt;
  int contactId;
  RxString currentBalance = '0'.obs;

  String get addressFormated => addressFormat(address);

  static Stream<Contact> fetch(
    Database db, {
    int limit = 20,
    int offset = 0,
  }) async* {
    final result = await db.instance.query(
      TableNames.contacts,
      limit: limit,
      offset: offset,
      orderBy: 'updated_at DESC',
    );
    for (final item in result) {
      final contact = Contact.fromMap(item);
      yield contact;
    }
  }

  Future<int> save(
    Database db,
  ) async {
    createdAt = DateTime.now().toUtc();
    final result = await db.instance.insert(
      TableNames.contacts,
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    contactId = result;
    updatedAt = DateTime.now().toUtc();
    return result;
  }

  Future<int> update(Database db, {DateTime updatedAt}) async {
    this.updatedAt = DateTime.now().toUtc();
    this.updatedAt ??= updatedAt;
    final result = await db.instance.update(
      TableNames.contacts,
      toMap(),
      where: 'id = ?',
      whereArgs: [contactId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<void> delete(Database db) async {
    await db.instance.delete(
      TableNames.contacts,
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
