# Finance Tracker

Application Flutter de gestion de finances personnelles, conçue pour suivre les transactions quotidiennes, visualiser les tendances mensuelles, fixer des budgets et recevoir des insights assistes par IA.

## Apercu

`Finance Tracker` est une application mobile orientee utilisateur final avec:
- suivi des revenus et depenses en temps reel
- categorisation manuelle et auto-categorisation via Gemini
- statistiques mensuelles (totaux, repartition, evolution)
- gestion de budgets et rappels intelligents
- experience moderne (Material 3, mode clair/sombre, animations)

## Fonctionnalites

- **Transactions**
  - ajout rapide via pave numerique
  - type `income` / `expense`
  - categorie + note optionnelle
  - historique des operations
- **IA (Gemini)**
  - auto-detection de categorie selon la note
  - generation d'un insight mensuel court
- **Budget & Notifications**
  - suivi des enveloppes budgetaires
  - rappels locaux bases sur l'activite
- **UX**
  - navigation par onglets avec `go_router`
  - mode clair/sombre
  - animations Lottie et micro-interactions

## Stack Technique

- **Framework**: Flutter (Dart 3)
- **State management**: `provider`
- **Base locale**: `hive` + `hive_flutter`
- **Navigation**: `go_router`
- **IA**: `google_generative_ai` (Gemini)
- **Config secrete**: `flutter_dotenv`
- **Charts**: `fl_chart`
- **Notifications locales**: `flutter_local_notifications`

## Structure du Projet

```text
lib/
  models/         # Entites (Transaction, Budget, ...)
  providers/      # Etat applicatif (transactions, budgets, theme, streak)
  screens/        # Ecrans (home, add, history, stats, settings)
  services/       # Services (Gemini, notifications, insights)
  widgets/        # Composants UI reutilisables
  router/         # Configuration go_router + shell navigation
  utils/          # Constantes, formatters, helpers
```

## Prerequis

- Flutter SDK installe
- Dart SDK (inclus avec Flutter)
- Android Studio ou VS Code + emulation configuree
- Cle API Gemini valide

Verifier votre installation:

```bash
flutter --version
flutter doctor
```

## Installation

1. Cloner le repository
```bash
git clone <URL_DU_REPO>
cd finance-tracker-app
```

2. Installer les dependances
```bash
flutter pub get
```

3. Generer les adapters Hive (si necessaire)
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Configurer les variables d'environnement

Creer un fichier `.env` a la racine:

```env
GEMINI_API_KEY=your_api_key_here
```

5. Lancer l'application
```bash
flutter run
```

## Configuration Environnement

- Le fichier `.env` est charge au demarrage dans `main.dart`.
- La cle `GEMINI_API_KEY` est consommee dans `GeminiService`.
- Ne jamais versionner de secrets reels.

Exemple `.gitignore` recommande:

```gitignore
.env
```

## Commandes Utiles

```bash
# Analyse statique
flutter analyze

# Formatage
dart format .

# Tests
flutter test

# Build APK release
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release
```

## Navigation Applicative

Routes principales:
- `/` : Home
- `/history` : Historique
- `/stats` : Statistiques
- `/settings` : Parametres
- `/add` : Ajout de transaction (modal plein ecran)

## Qualite & Bonnes Pratiques

- Architecture separee par responsabilites (`screens`, `providers`, `services`)
- Etat reactive avec `ChangeNotifier`
- Persistance locale robuste via Hive
- Code linted avec `flutter_lints`
- UI coherent en Material 3
