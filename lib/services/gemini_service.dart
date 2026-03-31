import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Singleton pattern — only one instance of this service exists
  // Like a singleton store in Pinia
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Initialize the Gemini model once
  late final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    // ↑ gemini-1.5-flash is the fastest and cheapest model
    //   Perfect for simple tasks like categorization
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

  // ── AUTO CATEGORIZATION ──────────────────────────────────
  // Takes a note like "taxi to work" and returns "transport"
  Future<String> categorizeTransaction(String note) async {
    if (note.trim().isEmpty) return 'other';

    try {
      final prompt = '''
You are a personal finance assistant.
Given this transaction note, return ONLY the most appropriate category.
Choose from exactly these options: food, transport, leisure, health, housing, education, salary, other.
Return only the category word in lowercase, nothing else.

Transaction note: "$note"
''';

      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      final result = response.text?.trim().toLowerCase() ?? 'other';

      // DEBUG — print the raw response to the terminal
      print('>>> Gemini raw response: "$result"');
      print('>>> Note was: "$note"');

      const validCategories = [
        'food',
        'transport',
        'leisure',
        'health',
        'housing',
        'education',
        'salary',
        'other',
      ];

      final matched = validCategories.contains(result) ? result : 'other';
      print('>>> Matched category: "$matched"');

      return matched;
    } catch (e) {
      // DEBUG — print the error
      print('>>> Gemini error: $e');
      return 'other';
    }
  }

  // ── MONTHLY INSIGHT ──────────────────────────────────────
  // Generates a personalized one-sentence insight for the month
  Future<String> generateMonthlyInsight({
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> expensesByCategory,
    required String month,
  }) async {
    if (totalExpenses == 0) return '';

    try {
      // Build a readable summary of spending
      final categorySummary = expensesByCategory.entries
          .map((e) => '${e.key}: ${e.value.toStringAsFixed(0)} Ar')
          .join(', ');

      final prompt = '''
You are a personal finance assistant. Be concise, helpful, and slightly strict.
Generate ONE short sentence (max 20 words) of financial insight based on this data.
Do not use bullet points. Do not add greetings. Just the insight.

Month: $month
Total income: ${totalIncome.toStringAsFixed(0)} Ar
Total expenses: ${totalExpenses.toStringAsFixed(0)} Ar
Expenses by category: $categorySummary
''';

      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      return response.text?.trim() ?? '';
    } catch (e) {
      print(e);
      return '';
    }
  }
}
