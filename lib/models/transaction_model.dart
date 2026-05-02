class TransactionModel {
  final int? id;
  final String uid;
  final String title;
  final double amount;
  final String category;
  final String type;
  final DateTime date;
  final String? note;

  TransactionModel({
    this.id,
    required this.uid,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      uid: map['uid'] ?? '',
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? uid,
    String? title,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
