# Online-Challenges: Integrationsvertrag (Entwurf)

Status: Vorbereitung, kein implementierter oder erreichbarer Server. Der Vertrag
muss vor Backend-Umsetzung fachlich abgestimmt werden. Keine Anbieter-, Stack-
oder Architekturstandard-Auswahl getroffen. Bestehende Lern-Speicherschlüssel
bleiben unverändert. `challenge_practice_v1` enthält ausschließlich lokale Daten.

## Grenze zwischen Training und Wettbewerb

`ChallengeFactory`, `ChallengeQuestion` und `ChallengeResult` sind lokale Modelle;
sie enthalten Lösungen und sind NICHT als Online-Payloads geeignet. Die lokale
Wertung `local-v1` ermittelt richtige Antworten vor Antwortzeit. Der Timer umfasst
Audio und Eingabe, aber kein Feedback/Übergaben. Es gibt kein Zeitlimit. Zeiten
sind geräteabhängig. Texthilfe oder Hintergrundwechsel schließen Bestwerte aus.
Ein Geräteduell wird nur am Ende verglichen und nicht als Einzelbestwert gespeichert.

Die UI bleibt bis zur Anbindung ausdrücklich lokal. Es gibt keine erfundenen
Gegner, öffentlichen Scores, ausgedachten Konten oder Uploadwarteschlange für
lokale Leistungen. Künftige Online-Daten und Kontotokens sind separat zu speichern.
Keine spätere automatische Übernahme lokaler Bestwerte in öffentliche Ranglisten.

## Geplanter Client-Adapter

Ein `OnlineCompetitionRepository` erhält einen austauschbaren HTTP-Transport und
liefert eigene, streng validierte DTOs. Authentifizierte Sitzungen und deren sichere
Speicherung folgen nach Entscheidung über Konten/Alterskonzept. Der Adapter wird
erst zusammen mit einem verifizierbaren Backend implementiert; aktuell existiert
bewusst kein vorgetäuschter Netzwerkadapter.

| Operation | Geplanter Request | Serverantwort |
|---|---|---|
| Regeln/Kategorien | GET /v1/competition/rules | ruleSetId, Kategorien, Bereiche, Modi, Audio-/Zeitregeln, Online-Verfügbarkeit |
| Duell erstellen | POST /v1/duels | duelId, Status, kurzlebiger Einladungscode, expiresAt |
| Zufälliger Gegner | POST /v1/matchmaking | ticketId, waiting/matched, optional duelId |
| Wartestatus/Abbrechen | GET oder DELETE /v1/matchmaking/{ticketId} | Status bzw. Abbruchbestätigung |
| Einladung annehmen | POST /v1/duels/join | duelId, eigene participationId, Status |
| Duellstatus | GET /v1/duels/{duelId} | freigegebener Status, eigene Teilnahme, Ergebnis erst bei Berechtigung |
| Einzelversuch | POST /v1/attempts | attemptId, ruleSetId, Modus, Kategorie, Umfang |
| Teilnahme starten | POST /v1/participations/{id}/start | attemptId, erste Aufgabe, Serverfristen |
| Einzelversuch starten | POST /v1/attempts/{id}/start | erste Aufgabe, Serverfristen |
| Antwort | POST /v1/attempts/{id}/answers | Bestätigung, erlaubtes Feedback, nächste Aufgabe oder finaler Status |
| Unterbrechung/Wiederaufnahme | GET /v1/attempts/{id} | verbindlicher Zustand; nie ein zusätzlicher Versuch |
| Ergebnis | GET /v1/attempts/{id}/result | pending/verified/rejected, vom Server berechnete Wertung |
| Rangliste | GET /v1/leaderboards | boardId, Filter, Seiten-Cursor, Ränge, eigene Position |

Konten, Abmeldung, Löschung, Blockieren, Melden und Moderation benötigen zusätzlich
abgestimmte Endpunkte. API-Version und fachliche Regelversion sind getrennt.

## Payload-Grenzen

Versuchserstellung enthält Kategorie (mixed/listen/match/build), Modus
(traditional/placeValue), ruleSetId und bei Duellen die berechtigte Teilnahme.
Der Server bestimmt die Aufgaben. Moduswechsel nach dem Start ist ausgeschlossen.

Ausgegebene Aufgabe: opake questionId, Sequenznummer, Abfrageart, Eingabeform,
freigegebener Anzeigetext/Ziffern oder signierte Audio-Referenz, Antwortoptionen
mit opaken IDs, gegebenenfalls Baustein-IDs, Server-Zeitfenster. Bei Hörfragen darf
weder die Zahl noch ihr Text in URL, Dateiname, Metadaten oder Payload verraten
werden. Keine Antworten, Seeds oder künftigen Aufgaben im Client-Payload.

Antwort: attemptId über Pfad, questionId, Sequenz, Antwort-/Baustein-IDs und
Idempotency-Key. Kein vertrauenswürdiger Endscore, keine vom Client frei wählbare
Bewertungszeit. Client-Messungen sind höchstens ergänzende Diagnosedaten. Der
Server prüft Sitzung, Teilnehmer, Status, Frist, Aufgabe, Antwort und Reihenfolge.
Wiederholte identische Requests ergeben dieselbe Bestätigung. Widersprüchliche
Wiederholungen, fremde Versuche und abgelaufene Antworten werden abgelehnt.

Ranglisteneinträge enthalten nur Pseudonym, Rang, bestätigte Leistung und öffentliche
Regelparameter. Keine E-Mail, Lernfehlerhistorie, Sitzungsdaten oder interne IDs,
über die private Daten erreichbar werden. Gleichstände teilen den Rang.

## Fehler und Lebenszyklus

Explizite Zustände: signedOut, unavailable, offline, waiting, ready, playing,
submitting, verificationPending, completed, expired, rejected, cancelled.
HTTP-Fehler erhalten maschinenlesbare Codes und sichere deutsche UI-Texte.
Timeouts führen zu Statusabfrage bzw. idempotenter Wiederholung, nicht zu einer
optimistisch bestätigten Wertung. 401 beendet/erneuert die Sitzung nach dem
gewählten Auth-Verfahren; 403/409/410 können nicht lokal umgangen werden;
429 berücksichtigt Retry-After. Keine Endlosschleifen oder stillen neuen Versuche.

## Vor Freischaltung noch nötig

Backend/DB, Konten und Alterskonzept, standardisierte Schwierigkeit, geprüfte
Audioausgabe, faire Zeitmessung einschließlich Netzlatenz, Einladungen und
Gegnerzuordnung, Missbrauchsschutz, Moderation, atomare Wertung, Integrationstests,
Betrieb/Monitoring, getrennte Umgebungen und wiederherstellbare Backups.
Keine allgemeinen Architekturvorgaben ohne ausdrückliche Bestätigung anwenden.
