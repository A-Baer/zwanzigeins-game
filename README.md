# Zwanzigeins – Entwirr die Zahlen!

Zahlen-Challenges und spielerisches Lernen in traditioneller und stellenwertgerechter Sprechweise.

Die App verbindet Zahlenmix, Kategorie-Training und lokale Zweispieler-Duelle
mit einem eigenständigen Lernbereich. Dort können Nutzerinnen und Nutzer vergleichen, wie Zahlen in der
traditionellen Form („einundzwanzig“) und entlang der Stellenwerte
(„zwanzigeins“) aufgebaut sind. Sie ergänzt die bestehende Forschungs-App um
eine eigenständige, motivierende Lernroute.

## Aktueller MVP

- Eigenständige Gestaltung mit dem Original-Logo aus zwanzigeins-app
- sechs aufeinander aufbauende Lektionen für Zahlen von 11 bis 99
- Übungen zum Hören, Bilden und Vergleichen
- interaktives Zahlenlabor von 10 bis 99 mit beiden Sprechweisen
- deutsche Text-to-Speech-Ausgabe, soweit vom Zielsystem unterstützt
- lokal gespeicherter Fortschritt und Klarheitsenergie
- adaptive Navigation für Smartphone, Web und Desktop
- Zahlenmuseum, Forschungslinks und Vereinsmitgliedschaft
- keine Registrierung, Werbung oder Cloud-Synchronisierung

## Zielplattformen

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Entwicklung

Voraussetzung ist ein aktuelles Flutter-SDK.

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Produktkonzept und weitere Ausbaustufen stehen in [PLANUNG.md](PLANUNG.md).

## Datenschutz

Der MVP speichert ausschließlich Lernfortschritt und Einstellungen lokal auf
dem Gerät. Externe Vereinsseiten werden erst nach einer bewussten Aktion im
Systembrowser geöffnet.

## Challenge-Vorbereitung

Der Einstieg ist jetzt `Challenges | Lernen | Ranglisten | Profil | Mehr`.

- Zahlenmix mit zehn Aufgaben sowie Hörspur, Zahlwort-Zuordnung und Baustein-Ordnen
- traditionelle oder stellenwertgerechte Sprechweise für jeden Versuch
- zwei Spieler nacheinander an einem Gerät, gleicher Mix und unabhängige Moduswahl
- lokale Einzelbestwerte je Kategorie/Modus und die letzten 50 Einzelversuche
- bevorzugte Sprechweise und separates Löschen der Challenge-Ergebnisse im Profil
- richtig vor schnell; Antwortzeit ohne Feedback/Übergaben; kein Zeitlimit
- Texthilfe bei Hörfragen und App-Unterbrechungen zählen als Training ohne Bestwert

Das ist lokale Vorbereitung. Online-Gegner, Einladungen, Konten und öffentliche
Ranglisten sind noch nicht verfügbar. Lokale Scores werden nicht später hochgeladen.
Das lokale Duell ist ein Freundschaftsspiel: Mitsehen, gleiche Fragen und
geräteabhängige Audiozeiten erlauben keine manipulationssichere Wertung.
Der Lernbereich bleibt ohne Konto nutzbar, bestehende Lernstände bleiben erhalten.
Die Online-Anbindung ist in [docs/ONLINE_API.md](docs/ONLINE_API.md) beschrieben.
