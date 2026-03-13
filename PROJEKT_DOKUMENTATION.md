# Recipe Vault - Projekt-Dokumentation

## Inhaltsverzeichnis
1. [Projektübersicht](#projektübersicht)
2. [Installation und Setup](#installation-und-setup)
3. [Projekt starten](#projekt-starten)
4. [Bedienungsanleitung](#bedienungsanleitung)
5. [Protokolle](#protokolle)
6. [Meilenstein-Plan vs. Tatsächlicher Fortschritt](#meilenstein-plan-vs-tatsächlicher-fortschritt)

---

## Projektübersicht

**Recipe Vault** ist eine moderne Rezeptverwaltungs-App, die aus einem Flutter-Frontend und einem Node.js/TypeScript-Backend besteht.

### Technologie-Stack

#### Backend
- **Runtime**: Node.js
- **Sprache**: TypeScript
- **Framework**: Express.js
- **Datenbank**: SQL.js (SQLite in-memory/persistent)
- **Validierung**: Zod
- **Weitere Dependencies**: 
  - cors (Cross-Origin Resource Sharing)
  - multer (Datei-Upload)
  - dotenv (Umgebungsvariablen)

#### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **HTTP Client**: http package
- **Animationen**: Native Flutter Animations (AnimationController, Tween, Curves)
- **Weitere Dependencies**:
  - image_picker (Bildauswahl)
  - shared_preferences (Lokale Speicherung)
  - flutter_rating_bar (Bewertungsanzeige)

### ✨ Animation-Features

Die App verfügt über umfangreiche Animationen für ein modernes, flüssiges Benutzererlebnis:

#### Rezeptkarten-Animationen
- **Staggered Fade-In**: Karten erscheinen nacheinander mit verzögertem Einblenden
- **Scale Animation**: Sanfte Skalierung beim Laden
- **Press Feedback**: Visuelles Feedback beim Antippen (Skalierung + Elevation)
- **Hero Animation**: Nahtloser Bildübergang von Karte zu Detailansicht

#### Seitenübergänge
- **Slide Transition**: Rezept hinzufügen/bearbeiten gleitet von rechts ein
- **Fade Transition**: Rezeptdetails blenden sanft ein
- **Scale Transition**: Einkaufsliste erscheint mit Zoom-Effekt

#### Interaktive Animationen
- **FAB Rotation**: Plus-Button rotiert und pulsiert beim Klicken
- **Checkbox Animation**: Einkaufslisten-Checkboxen skalieren beim Abhaken
- **Text Durchstreichung**: Animierte Durchstreichung abgehakter Artikel
- **Stepper Transitions**: Sanfte Übergänge zwischen Formularschritten

#### Detail-Screen Animationen
- **Slide-Up Content**: Inhalte gleiten von unten nach oben ein
- **Fade-In Elements**: Zutaten und Schritte blenden nacheinander ein
- **Hero Image**: Großes Bild mit Hero-Animation vom Thumbnail

### Projektstruktur

```
WmcProject2026/
├── Backend/
│   ├── src/
│   │   ├── controllers/      # Business-Logik
│   │   ├── routes/           # API-Endpunkte
│   │   ├── models/           # Datenmodelle
│   │   ├── db/               # Datenbank-Initialisierung
│   │   ├── middleware/       # Express-Middleware
│   │   └── index.ts          # Einstiegspunkt
│   ├── package.json
│   ├── tsconfig.json
│   └── nodemon.json
│
└── Frontend/
    └── recipefrontend/
        ├── lib/
        │   ├── screens/      # UI-Screens
        │   ├── providers/    # State Management
        │   ├── services/     # API-Service
        │   ├── models/       # Datenmodelle
        │   ├── widgets/      # Wiederverwendbare Widgets
        │   ├── themes/       # App-Themes
        │   └── main.dart     # Einstiegspunkt
        └── pubspec.yaml
```

---

## Installation und Setup

### Voraussetzungen

#### Für das Backend:
- **Node.js** (Version 18 oder höher)
- **npm** (kommt mit Node.js)

#### Für das Frontend:
- **Flutter SDK** (Version 3.11.0 oder höher)
- **Android Studio** oder **Xcode** (für mobile Entwicklung)
- **Chrome** (für Web-Entwicklung)

### Backend-Installation

1. **Navigieren Sie zum Backend-Verzeichnis:**
   ```bash
   cd Backend
   ```

2. **Installieren Sie die Dependencies:**
   ```bash
   npm install
   ```

3. **TypeScript kompilieren:**
   ```bash
   npx tsc
   ```

### Frontend-Installation

1. **Navigieren Sie zum Frontend-Verzeichnis:**
   ```bash
   cd Frontend/recipefrontend
   ```

2. **Installieren Sie die Flutter-Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Überprüfen Sie die Flutter-Installation:**
   ```bash
   flutter doctor
   ```

---

## Projekt starten

### Backend starten

Es gibt zwei Möglichkeiten, das Backend zu starten:

#### Option 1: Development-Modus (mit Hot-Reload)
```bash
cd Backend
npm run dev
```

Der Development-Server läuft auf **http://localhost:3000** und startet automatisch neu bei Dateiänderungen.

#### Option 2: Production-Modus
```bash
cd Backend
npm run start
```

**Wichtig**: Der Server muss laufen, bevor das Frontend gestartet wird!

#### Backend-Endpunkte

Nach dem Start ist die API unter folgenden Endpunkten erreichbar:

- **GET** `/` - API-Status
- **GET** `/api/recipes` - Alle Rezepte abrufen
- **GET** `/api/recipes/:id` - Einzelnes Rezept abrufen
- **POST** `/api/recipes` - Neues Rezept erstellen
- **PUT** `/api/recipes/:id` - Rezept aktualisieren
- **DELETE** `/api/recipes/:id` - Rezept löschen
- **GET** `/api/categories` - Kategorien abrufen
- **GET** `/api/shopping-list` - Einkaufsliste abrufen
- **POST** `/api/shopping-list/aggregate` - Einkaufsliste aus Rezepten generieren
- **PUT** `/api/shopping-list/:id/check` - Einkaufslisteneintrag abhaken
- **PUT** `/api/shopping-list/:id/amount` - Menge ändern
- **DELETE** `/api/shopping-list/checked` - Abgehakte Einträge löschen
- **DELETE** `/api/shopping-list` - Gesamte Liste löschen
- **POST** `/api/images` - Bild hochladen

### Frontend starten

#### Für Web-Entwicklung:
```bash
cd Frontend/recipefrontend
flutter run -d chrome
```

#### Für Android-Emulator:
```bash
cd Frontend/recipefrontend
flutter run -d android
```

#### Für iOS-Simulator (nur macOS):
```bash
cd Frontend/recipefrontend
flutter run -d ios
```

**Hinweis**: Das Frontend verbindet sich standardmäßig mit `http://localhost:3000`. Stellen Sie sicher, dass das Backend läuft!

---

## Bedienungsanleitung

### 1. Startseite (Home Screen)

[*Screenshot: Hauptbildschirm mit Rezeptübersicht in Grid-Ansicht*]

Die Startseite zeigt alle gespeicherten Rezepte in einer übersichtlichen Grid-Ansicht mit animierten Karten.

**Animationen:**
- Rezeptkarten erscheinen nacheinander mit Fade-In-Effekt (Staggered Animation)
- Beim Antippen einer Karte: Sanfte Skalierung und Schatten-Reduktion
- Plus-Button (FAB) rotiert und pulsiert beim Klicken

**Funktionen:**
- **Suchleiste**: Rezepte nach Namen durchsuchen
- **Filter-Chips**: Rezepte nach Kategorien filtern (Alle, Vegan, Dessert, Hauptgericht, Snack, Frühstück)
- **Theme-Auswahl**: Farbschema der App ändern (Palette-Icon oben rechts)
- **Einkaufsliste**: Zur Einkaufsliste navigieren (Warenkorb-Icon oben rechts)
- **Neues Rezept**: Rezept hinzufügen (Plus-Button unten rechts)

**Rezeptkarten zeigen:**
- Rezeptbild (oder Platzhalter)
- Rezeptname
- Kategorie
- Schwierigkeitsgrad (Sterne)
- Zubereitungszeit

**Aktionen:**
- **Tippen auf Karte**: Rezeptdetails öffnen
- **Löschen-Icon**: Rezept löschen (mit Bestätigungsdialog)

[*Screenshot: Suchfunktion mit eingegebenem Suchtext*]

[*Screenshot: Kategoriefilter aktiv (z.B. "Dessert" ausgewählt)*]

[*Screenshot: Theme-Auswahl-Dialog mit verschiedenen Farbschemata*]

---

### 2. Rezept hinzufügen/bearbeiten (Add/Edit Screen)

[*Screenshot: Stepper-Ansicht - Schritt 1 "Grunddaten"*]

Das Hinzufügen oder Bearbeiten eines Rezepts erfolgt in 4 Schritten mit animierten Übergängen:

**Animationen:**
- **Slide-In**: Screen gleitet von rechts ins Bild
- **Stepper Transitions**: Sanfte Fade-Übergänge zwischen Schritten
- **Form Feedback**: Visuelles Feedback bei Eingaben

#### Schritt 1: Grunddaten
- **Name**: Rezeptname eingeben (Pflichtfeld)
- **Zubereitungszeit**: Zeit in Minuten (Pflichtfeld, nur Zahlen)
- **Kategorie**: Aus Dropdown auswählen
- **Schwierigkeit**: 1-5 Sterne bewerten

[*Screenshot: Ausgefülltes Formular für Grunddaten*]

#### Schritt 2: Zutaten
- **Zutaten hinzufügen**: Menge, Einheit und Name eingeben
- **Mehrere Zutaten**: Mit "Zutat hinzufügen" weitere Zeilen anlegen
- **Zutaten entfernen**: Minus-Icon neben der Zutat

**Format:**
- Menge: z.B. 200, 1.5
- Einheit: z.B. g, ml, Stk, TL, EL
- Zutat: z.B. Mehl, Zucker, Eier

[*Screenshot: Zutatenliste mit mehreren eingetragenen Zutaten*]

#### Schritt 3: Anleitung
- **Schritte hinzufügen**: Zubereitungsschritte nacheinander eingeben
- **Nummerierung**: Erfolgt automatisch
- **Schritte entfernen**: Minus-Icon neben dem Schritt
- **Mehrere Schritte**: Mit "Schritt hinzufügen" weitere Schritte anlegen

[*Screenshot: Anleitungsschritte mit nummerierten Eingabefeldern*]

#### Schritt 4: Bild
- **Bild hochladen**: "Bild hochladen" Button klicken
- **Bildauswahl**: Aus Galerie wählen
- **Bild ändern**: Neues Bild auswählen
- **Optional**: Rezept kann auch ohne Bild gespeichert werden

[*Screenshot: Bild-Upload-Ansicht mit hochgeladenem Bild*]

**Speichern:**
- Im letzten Schritt auf "Speichern" klicken
- Bei Erfolg: Rückkehr zur Startseite
- Bei Fehler: Fehlermeldung wird angezeigt

[*Screenshot: Erfolgreich gespeichertes Rezept*]

---

### 3. Rezeptdetails (Detail Screen)

[*Screenshot: Rezeptdetailseite mit Hero-Image und Informationen*]

Die Detailansicht zeigt alle Informationen zu einem Rezept mit flüssigen Animationen:

**Animationen:**
- **Hero Animation**: Rezeptbild wächst nahtlos von der Karte zur Vollbildansicht
- **Fade-In**: Alle Inhalte blenden sanft ein
- **Slide-Up**: Informationen gleiten von unten nach oben ins Bild

**Oberer Bereich:**
- **Hero-Image**: Großes Rezeptbild mit Titel (animierter Übergang)
- **Bearbeiten-Icon**: Rezept bearbeiten
- **Löschen-Icon**: Rezept löschen

**Informationszeile:**
- Kategorie (als Badge)
- Schwierigkeitsgrad (Sterne)
- Zubereitungszeit

[*Screenshot: Informationszeile mit Kategorie, Sternen und Zeit*]

**Zutaten-Sektion:**
- Liste aller Zutaten mit Menge und Einheit
- Übersichtliche Darstellung mit Bullet-Points

[*Screenshot: Zutatenliste in der Detailansicht*]

**Anleitung-Sektion:**
- Nummerierte Schritte
- Kreisförmige Nummerierung für bessere Lesbarkeit

[*Screenshot: Zubereitungsschritte mit Nummerierung*]

**Aktionen:**
- **Zur Einkaufsliste**: Alle Zutaten zur Einkaufsliste hinzufügen
- **Teilen**: Rezept als Text teilen (öffnet Dialog mit formatiertem Text)

[*Screenshot: "Zur Einkaufsliste hinzugefügt" Snackbar*]

[*Screenshot: Teilen-Dialog mit Rezepttext*]

---

### 4. Einkaufsliste (Shopping List Screen)

[*Screenshot: Einkaufsliste mit gruppierten Einträgen*]

Die Einkaufsliste aggregiert Zutaten aus mehreren Rezepten und gruppiert sie nach Kategorien.

**Animationen:**
- **Scale-In**: Screen erscheint mit Zoom-Effekt
- **Slide-Up Items**: Einträge gleiten von unten nach oben ein
- **Checkbox Animation**: Checkboxen skalieren beim Abhaken (1.2x)
- **Text Animation**: Durchstreichung wird animiert
- **Background Fade**: Abgehakte Einträge erhalten animierten Hintergrund
- **Opacity Transition**: Bearbeiten-Icon blendet aus bei abgehakten Einträgen

**Funktionen:**
- **Gruppierung**: Zutaten nach Kategorien sortiert
- **Abhaken**: Checkbox zum Markieren gekaufter Artikel (mit Animation)
- **Menge bearbeiten**: Stift-Icon zum Ändern der Menge
- **Durchgestrichen**: Abgehakte Einträge werden animiert durchgestrichen

[*Screenshot: Einzelner Eintrag mit Checkbox, Name, Menge und Bearbeiten-Icon*]

**Aktionen in der App-Bar:**
- **Abgehakte löschen**: Alle abgehakten Einträge entfernen (Besen-Icon)
- **Alle löschen**: Gesamte Einkaufsliste leeren (Papierkorb-Icon)

[*Screenshot: Bestätigungsdialog "Abgehakte löschen"*]

**Menge bearbeiten:**
1. Auf Stift-Icon tippen
2. Neue Menge eingeben
3. "Speichern" klicken

[*Screenshot: Dialog zum Bearbeiten der Menge*]

**Leere Einkaufsliste:**
- Zeigt Platzhalter-Icon und Hinweistext
- Aufforderung, Rezepte hinzuzufügen

[*Screenshot: Leere Einkaufsliste mit Platzhalter*]

---

### 5. Theme-Auswahl

[*Screenshot: Theme-Auswahl-Bottom-Sheet*]

Die App bietet mehrere Farbschemata:

**Verfügbare Themes:**
- Standard-Theme
- Verschiedene Farbvarianten
- Jedes Theme mit eigener Primärfarbe

**Theme wechseln:**
1. Palette-Icon in der App-Bar tippen
2. Gewünschtes Theme auswählen
3. Theme wird sofort angewendet und gespeichert

[*Screenshot: App mit verschiedenen Theme-Varianten (mehrere Screenshots)*]

---

### 6. Fehlerbehandlung

**Backend nicht erreichbar:**

[*Screenshot: Fehlermeldung "Backend nicht erreichbar"*]

- Zeigt Offline-Icon und Fehlermeldung
- "Erneut versuchen" Button zum Neuladen

**Leere Zustände:**

[*Screenshot: "Noch keine Rezepte" Platzhalter*]

- Freundliche Platzhalter-Grafiken
- Hilfreiche Hinweistexte
- Handlungsaufforderungen

---

## Protokolle

### Entwicklungsprotokolle

Hier sollten alle Meeting-Protokolle, Entscheidungen und wichtige Diskussionen gesammelt werden:

#### Protokoll-Vorlage

```
Datum: [TT.MM.JJJJ]
Teilnehmer: [Namen]
Dauer: [Zeit]

Themen:
1. [Thema 1]
   - Diskussion: ...
   - Entscheidung: ...
   
2. [Thema 2]
   - Diskussion: ...
   - Entscheidung: ...

Nächste Schritte:
- [ ] Aufgabe 1 (Verantwortlich: Name, Frist: Datum)
- [ ] Aufgabe 2 (Verantwortlich: Name, Frist: Datum)

Offene Punkte:
- ...
```

#### Beispiel-Einträge

**[Hier Ihre tatsächlichen Protokolle einfügen]**

---

## Meilenstein-Plan vs. Tatsächlicher Fortschritt

### Geplante Meilensteine

#### Meilenstein 1: Projektsetup und Grundstruktur
**Geplant**: [Datum einfügen]
**Tatsächlich**: [Datum einfügen]
**Status**: ✅ Abgeschlossen / ⏳ In Arbeit / ❌ Verzögert

**Aufgaben:**
- [x] Backend-Projekt initialisieren
- [x] Frontend-Projekt initialisieren
- [x] Grundlegende Projektstruktur erstellen
- [x] Dependencies installieren

**Abweichungen**: [Beschreibung einfügen]

---

#### Meilenstein 2: Backend-Entwicklung
**Geplant**: [Datum einfügen]
**Tatsächlich**: [Datum einfügen]
**Status**: ✅ Abgeschlossen / ⏳ In Arbeit / ❌ Verzögert

**Aufgaben:**
- [x] Datenbank-Schema erstellen
- [x] Recipe-API implementieren
- [x] Shopping-List-API implementieren
- [x] Categories-API implementieren
- [x] Image-Upload implementieren
- [x] Validierung mit Zod
- [x] CORS konfigurieren

**Abweichungen**: [Beschreibung einfügen]

---

#### Meilenstein 3: Frontend-Grundfunktionen
**Geplant**: [Datum einfügen]
**Tatsächlich**: [Datum einfügen]
**Status**: ✅ Abgeschlossen / ⏳ In Arbeit / ❌ Verzögert

**Aufgaben:**
- [x] Home Screen mit Rezeptliste
- [x] Detail Screen
- [x] Add/Edit Screen mit Stepper
- [x] API-Service implementieren
- [x] State Management mit Provider
- [x] Rezept-Modell erstellen

**Abweichungen**: [Beschreibung einfügen]

---

#### Meilenstein 4: Erweiterte Features
**Geplant**: [Datum einfügen]
**Tatsächlich**: [Datum einfügen]
**Status**: ✅ Abgeschlossen / ⏳ In Arbeit / ❌ Verzögert

**Aufgaben:**
- [x] Einkaufsliste-Screen
- [x] Suchfunktion
- [x] Kategoriefilter
- [x] Bild-Upload
- [x] Theme-Auswahl
- [x] Bewertungssystem (Schwierigkeitsgrad)

**Abweichungen**: [Beschreibung einfügen]

---

#### Meilenstein 5: Testing und Optimierung
**Geplant**: [Datum einfügen]
**Tatsächlich**: [Datum einfügen]
**Status**: ✅ Abgeschlossen / ⏳ In Arbeit / ❌ Verzögert

**Aufgaben:**
- [ ] Unit-Tests Backend
- [ ] Widget-Tests Frontend
- [ ] Integration-Tests
- [ ] Performance-Optimierung
- [ ] Bug-Fixes
- [ ] Code-Review

**Abweichungen**: [Beschreibung einfügen]

---

#### Meilenstein 6: Dokumentation und Deployment
**Geplant**: [Datum einfügen]
**Tatsächlich**: [Datum einfügen]
**Status**: ✅ Abgeschlossen / ⏳ In Arbeit / ❌ Verzögert

**Aufgaben:**
- [x] Projekt-Dokumentation erstellen
- [x] Bedienungsanleitung mit Screenshots
- [ ] API-Dokumentation
- [ ] Code-Kommentare
- [ ] Deployment-Anleitung
- [ ] Präsentation vorbereiten

**Abweichungen**: [Beschreibung einfügen]

---

### Zeitplan-Übersicht

| Meilenstein | Geplant | Tatsächlich | Verzögerung | Status |
|-------------|---------|-------------|-------------|--------|
| M1: Setup | [Datum] | [Datum] | [Tage] | [Status] |
| M2: Backend | [Datum] | [Datum] | [Tage] | [Status] |
| M3: Frontend Basis | [Datum] | [Datum] | [Tage] | [Status] |
| M4: Features | [Datum] | [Datum] | [Tage] | [Status] |
| M5: Testing | [Datum] | [Datum] | [Tage] | [Status] |
| M6: Doku | [Datum] | [Datum] | [Tage] | [Status] |

---

### Erkenntnisse und Lessons Learned

#### Was lief gut:
- [Ihre Erkenntnisse einfügen]

#### Herausforderungen:
- [Ihre Erkenntnisse einfügen]

#### Verbesserungspotenzial:
- [Ihre Erkenntnisse einfügen]

#### Technische Entscheidungen:
- **SQL.js statt PostgreSQL/MySQL**: [Begründung]
- **Provider statt Bloc/Riverpod**: [Begründung]
- **Stepper für Rezepteingabe**: [Begründung]

---

## Anhang

### Wichtige Befehle

#### Backend
```bash
# Dependencies installieren
npm install

# Development-Server starten
npm run dev

# Production-Build
npm run start

# TypeScript kompilieren
npx tsc
```

#### Frontend
```bash
# Dependencies installieren
flutter pub get

# App starten (Web)
flutter run -d chrome

# App starten (Android)
flutter run -d android

# Build erstellen
flutter build apk
flutter build web

# Tests ausführen
flutter test
```

### Bekannte Probleme und Lösungen

#### Problem: Backend nicht erreichbar
**Lösung**: 
1. Überprüfen, ob Backend läuft (`http://localhost:3000`)
2. CORS-Einstellungen prüfen
3. Firewall-Einstellungen überprüfen

#### Problem: Bilder werden nicht angezeigt
**Lösung**:
1. Backend-Image-Upload-Ordner prüfen
2. Bildpfade in API-Response überprüfen
3. Netzwerkverbindung testen

#### Problem: Flutter-Abhängigkeiten nicht gefunden
**Lösung**:
```bash
flutter clean
flutter pub get
```

---

## Kontakt und Support

**Projektteam**: [Namen einfügen]
**Betreuer**: [Name einfügen]
**Repository**: [Git-URL einfügen]

---

**Letzte Aktualisierung**: [Datum einfügen]
