import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
// ↑ typeId: 1 — must be different from Transaction (typeId: 0)
class Budget extends HiveObject {
  @HiveField(0)
  final String category;
  // ↑ Category key (e.g. "food", "transport")

  @HiveField(1)
  final double limit;
  // ↑ Maximum allowed amount in Ariary for this category

  @HiveField(2)
  final int month;
  // ↑ Month this budget applies to (1 = January, 12 = December)

  @HiveField(3)
  final int year;
  // ↑ Year this budget applies to (e.g. 2026)

  Budget({
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  // Creates a copy of this budget with updated fields
  Budget copyWith({
    String? category,
    double? limit,
    int? month,
    int? year,
  }) {
    return Budget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
