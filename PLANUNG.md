# Zwanzigeins – Entwirr die Zahlen!

## Produktidee und Umsetzungsplanung für eine gamifizierte Flutter-App

Stand: 13. September 2026

## Umsetzungsstand des MVP

Der erste funktionsfähige Flutter-MVP ist angelegt. Er umfasst eine adaptive
Oberfläche mit Original-Logo für Smartphone und größere Fenster, sechs spielbare Lektionen mit je
sieben Aufgaben, unmittelbares Antwortfeedback, Sprachausgabe, einen linearen
Lernweg, lokal gespeicherten Fortschritt, Klarheitsenergie, das Zahlenmuseum,
ein interaktives Zahlenlabor von 10 bis 99 mit beiden Sprechweisen,
Forschungslinks und einen direkten Zugang zum aktuellen Aufnahmeantrag des
Vereins. Android, iOS, Web, Windows, macOS und Linux sind als Flutter-Ziele
konfiguriert.

Noch nicht Teil des MVP sind Konten und Synchronisierung, Sprech­erkennung,
Alltagsmissionen, Figurenanimationen, Sounds, redaktionell gepflegte
Ferninhalte sowie eine Übergabe von Mitgliedsdaten innerhalb der App. Das
Aufnahmeformular wird bewusst extern geöffnet, sodass die App selbst keine
personenbezogenen Vereinsdaten verarbeitet.

## Implementierte Vorbereitung des Challenge-Bereichs

Der lokale Prototyp enthält jetzt die Navigation Challenges, Lernen, Ranglisten,
Profil und Mehr. Spielbar sind zehnteilige Zahlenmix-Runden, die drei Kategorien
Hören/Zahlwort-Zuordnung/Bausteine und Freundschaftsduelle nacheinander an einem
Gerät. Beide Personen wählen ihre Sprechweise unabhängig; Aufgaben und Reihenfolge
bleiben im Duell gleich. Lokale Einzelbestwerte, eine begrenzte Versuchshistorie
und die bevorzugte Sprechweise werden getrennt vom Lernfortschritt gespeichert.
Texthilfe und Hintergrundwechsel schließen einen Bestwert aus. Geräteduelle zählen
nicht als Einzelbestwerte. Die Baustein-Kategorie nutzt zunächst 21–99 ohne volle
Zehner, die übrigen Kategorien 11–99.

Die lokalen Regeln heißen `local-v1`: Richtigkeit vor Antwortzeit, zehn Aufgaben,
kein Zeitlimit, Antwortzeit inklusive Audio/Eingabe und ohne Feedback/Übergabe.
Dies sind Übungsregeln, keine freigegebene Online-Wertung. Online-Funktionen bleiben
sichtbar als nicht verfügbar gekennzeichnet. Der API-Entwurf steht in
[docs/ONLINE_API.md](docs/ONLINE_API.md); Backend und Netzwerkadapter sind noch nicht
implementiert. Der Lernbereich mit seinen sechs Stationen bleibt erhalten.

## Verbindliche Produkterweiterung: Challenges und Lernen

Planungsänderung auf Nutzerwunsch: Die App besteht künftig aus zwei gleichwertigen
Produkthälften. **Challenges sind der Hook und der zentrale Einstieg**, Lernen
und Entdecken bilden die zweite Hälfte. Die App richtet sich damit auch an
Menschen, die mit ihrer vertrauten traditionellen Sprechweise antreten möchten,
ohne zuerst eine andere Zahlenreihenfolge zu lernen.

Verbindlich gewünscht sind Duelle gegen andere Spieler mit zufällig gemischten
Abfragearten, eine unabhängig je Spieler wählbare Sprechweise und kategorieweise
Ranglisten für gewertete Einzelversuche. „Verdreht“ bezeichnet die traditionelle
Sprechweise; „links nach rechts“ bezeichnet die stellenwertgerechte Sprechweise.
Die Auswahl darf keinen Modus als falsch oder minderwertig darstellen.

Der oben beschriebene lokale Flutter-Prototyp ist der tatsächliche
Implementierungsstand; Online-Konten, Online-Duelle, öffentliche Ranglisten
und Backend sind noch nicht implementiert oder bereitgestellt. Die frühere
reine Lern-MVP-Abgrenzung wird durch den nachstehenden Produktzuschnitt ersetzt.

## 1. Zusammenfassung

Die geplante App verbindet kurze Zahlen-Challenges gegen andere Spieler und
kategorieweise Bestenlisten mit einem gleichwertigen Lern- und Entdeckungsbereich.
Der Wettbewerb liefert den Anlass zum Einstieg und Wiederkommen; der Lernbereich
hilft, Zahlenverständnis und beide Sprechweisen zu erkunden. Die stellenwertgerechte
Zahlensprechweise wie „zwanzigeins“ ist eine frei wählbare Alternative zur
traditionellen Form „einundzwanzig“, keine Zugangsvoraussetzung zum Wettbewerb.

Die App soll nicht behaupten, dass die traditionelle Sprechweise falsch sei oder abgeschafft werden müsse. Sie folgt der Haltung von Zwanzigeins e. V.: Beide Sprechweisen können nebeneinander bestehen. Die Nutzerinnen und Nutzer sollen den Unterschied selbst hören, sehen, ausprobieren und anhand ihrer eigenen Fortschritte erfahren.

Die neue App wird verbindlich als eigenständiges Flutter-Produkt entwickelt. Aus einer gemeinsamen Dart- und Flutter-Codebasis sollen Android, iOS, Web sowie Desktop-Systeme bedient werden. Die vorhandene Zwanzigeins-App bleibt als Forschungs- und Trainingswerkzeug mit ihren kontrollierten Übungen, Messungen, Statistiken, Experimentfunktionen und Exportmöglichkeiten erhalten.

Arbeitstitel:

> **Zwanzigeins – Entwirr die Zahlen!**

## 2. Ausgangslage

Die bestehende Zwanzigeins-App bietet bereits:

- Hören und Schreiben
- Sehen und Sprechen
- Kopfrechnen
- vordefinierte und eigene Level
- unterschiedliche Zahlensprechweisen
- Messung von Zeit und Fehlern
- lokale Profile und Statistiken
- Experimentmodus und CSV-Export
- Sprachausgabe und Spracherkennung

Sie ist funktional, übersichtlich und für Forschung sowie strukturiertes Training geeignet. Ihre Oberfläche wirkt jedoch eher sachlich und formularorientiert. Eine emotionale Spielwelt, eine Kampagne und motivierende Progression würden tiefgreifende Änderungen erfordern und könnten den methodisch stabilen Forschungscharakter beeinträchtigen.

Daher soll die gamifizierte App getrennt entstehen und nur fachlich sinnvolle Logik und Erkenntnisse übernehmen.

## 3. Ziele

Die App soll:

1. die stellenwertgerechte Zahlensprechweise verständlich machen,
2. den Unterschied zur traditionellen Sprechweise sichtbar und hörbar machen,
3. durch kurze, abwechslungsreiche Spielrunden zum Wiederkommen motivieren,
4. Wissen über Stellenwerte, Zahlwörter und deren Geschichte vermitteln,
5. einen freiwilligen Wettbewerb und einen Lernbereich ohne Leistungsdruck anbieten,
6. den Verein und seine wissenschaftliche Arbeit seriös vorstellen,
7. einen sicheren Weg zur Vereinsmitgliedschaft anbieten.
8. aus einer gemeinsamen Codebasis auf Android, iOS, Web und Desktop funktionieren,
9. Duelle mit zufälligen Abfragearten und unabhängiger Moduswahl ermöglichen,
10. gewertete Einzelversuche und Bestenlisten je Abfragekategorie anbieten.

Nicht vorgesehen sind im ersten Schritt:

- aggressive Streaks oder Bestrafung für Pausen,
- Werbung,
- verpflichtende Benutzerkonten für das lokale Lernen,
- Echtzeit-Multiplayer, Chat und komplexe Ligen im ersten Online-Ausbau,
- die vollständige Digitalisierung der Vereinsverwaltung.

## 4. Zielgruppen

### Primäre Zielgruppen

- Kinder im Alter von ungefähr 7 bis 12 Jahren
- Eltern, Lehrkräfte und Lerntherapeutinnen und Lerntherapeuten
- Menschen, die Deutsch lernen

### Weitere Zielgruppen

- Jugendliche und Erwachsene mit Interesse an Sprache und Mathematik
- Vereinsmitglieder und Unterstützende
- Personen mit Schwierigkeiten beim Verarbeiten oder Verschriften gesprochener Zahlen

Beim ersten Start kann eine Ansprache gewählt werden:

- „Ich möchte eine Challenge spielen“
- „Ich möchte spielerisch lernen“
- „Ich lerne Deutsch“
- „Ich begleite ein Kind oder eine Lerngruppe“
- „Ich bin einfach neugierig“

Die Spielmechanik bleibt gleich, während Erklärungen, Tonalität und Hilfen angepasst werden können. Die Gestaltung darf freundlich und verspielt sein, sollte Erwachsene aber nicht durch eine ausschließlich kindliche Ansprache ausschließen.

## 5. Spielwelt

Im Lernbereich betreten die Spielerinnen und Spieler eine **Zahlenstadt**. In dieser Stadt werden Zahlen auf Stellenwert-Gleisen transportiert:

```text
Hunderter → Zehner → Einer
    1     →   2    →   3
```

Die Ziffern werden von links nach rechts geschrieben. In der traditionellen deutschen Zahlensprechweise nehmen Zehner und Einer aber häufig eine andere Route:

```text
geschrieben:  2 → 1
gesprochen:   1 → 2
              ein-und-zwanzig
```

Die alternative Route lautet:

```text
geschrieben:  2 → 1
gesprochen:   2 → 1
              zwanzig-eins
```

Die traditionelle Sprechweise wird dabei nicht als Gegner oder Fehler dargestellt. Zwei sympathische Figuren könnten die unterschiedlichen Wege repräsentieren und gemeinsam entdecken, wann welche Reihenfolge leichter zu verstehen ist.

Richtlinien für die Spielwelt:

- neugierig statt belehrend,
- freundlich statt konfrontativ,
- verständlich statt wissenschaftlich trocken,
- persönliche Verbesserung im Lernen und fairer, freiwilliger Wettbewerb in Challenges,
- Fehler als Hinweise statt Bestrafung.

### 5.1 Gestaltungsrichtung nach dem Vorbild von Duolingo

Das Bedien- und Motivationsdesign darf sich deutlich an den Stärken von Duolingo orientieren: kurze Lerneinheiten, große eindeutige Bedienelemente, eine gut sichtbare Lernroute, unmittelbares Feedback und eine freundliche, lebendige Inszenierung. Die neue App soll diese Prinzipien übernehmen, aber eine eigenständige visuelle Identität für Zwanzigeins entwickeln.

#### Zu übernehmende Designprinzipien

- pro Bildschirm eine klar erkennbare Hauptaktion,
- große, abgerundete Schaltflächen und Karten,
- kurze Texte und starke visuelle Erklärungen,
- eine vertikale Lernroute mit gut sichtbaren Etappen,
- Fortschrittsbalken innerhalb jeder Lektion,
- sofortiges positives Feedback nach einer richtigen Antwort,
- hilfreiches, nicht beschämendes Feedback bei Fehlern,
- lebendige Mikroanimationen, Sounds und optional haptisches Feedback,
- sympathische Figuren mit unterschiedlichen Reaktionen,
- klare, kräftige Farben und großzügige Weißräume,
- kurze Lektionen, die jederzeit abgeschlossen werden können,
- Belohnungsbildschirme mit einer eindeutigen nächsten Aktion.

#### Eigenständige Zwanzigeins-Identität

Die App soll nicht wie ein Duolingo-Klon aussehen. Insbesondere werden Maskottchen, Illustrationen, exakte Farbgebung, charakteristische Formulierungen und konkrete Bildschirmkompositionen nicht kopiert.

Stattdessen erhält Zwanzigeins ein eigenes Designsystem:

- das vorhandene Zwanzigeins-Grün als zentrale Markenfarbe,
- eigene ergänzende Farben für Hunderter, Zehner und Einer,
- Gleise, Stellenwertfelder, Zahlbausteine und Wegweiser als wiederkehrende Formen,
- eigene Figuren aus der Zahlenstadt,
- eine Bildsprache zwischen freundlichem Lernspiel und moderner Wissens-App,
- gut lesbare Ziffern als wichtigstes visuelles Element.

Eine mögliche Stellenwert-Farblogik wäre:

```text
Hunderter = Violett
Zehner    = Grün
Einer     = Orange
```

Diese Farben dienen immer nur als zusätzliche Hilfe. Stellenwerte müssen auch durch Position, Beschriftung und Form unterscheidbar bleiben.

#### Aufbau eines typischen Aufgabenbildschirms

```text
┌─────────────────────────────────┐
│ ←        Fortschritt 4/7    ♫  │
│ ████████████░░░░                │
│                                 │
│ Wie klingt die Zahl 46          │
│ auf der direkten Route?         │
│                                 │
│       [ vierzig ] [ sechs ]     │
│                                 │
│      Stellenwert-Animation      │
│                                 │
│        [ Antwort prüfen ]       │
└─────────────────────────────────┘
```

Nach einer richtigen Antwort erscheinen Farbe, Bewegung, kurzer Klang und eine knappe Erklärung gemeinsam. Nach einer falschen Antwort bleibt der Fortschritt erhalten; die App zeigt beispielsweise, welcher Baustein zum Zehner und welcher zum Einer gehört.

#### Tonalität

Die Texte sollen kurz, direkt und freundlich sein:

- „Genau – erst der Zehner, dann der Einer!“
- „Fast! Die 4 steht hier für vierzig.“
- „Du hast die direkte Route gemeistert.“
- „Noch eine kurze Runde?“

Die App darf humorvoll sein, sollte aber weder traditionelle Sprecherinnen und Sprecher abwerten noch Schwierigkeiten beim Rechnen oder Deutschlernen lächerlich machen.

## 6. Kern-Spielschleife

### 6.1 Challenge-Schleife als Einstieg

1. Ein Duell starten/annehmen oder eine Ranglistenkategorie wählen.
2. Die eigene Sprechweise wählen und Regeln sowie Wertung vor dem Start sehen.
3. Eine kurze Runde mit standardisierten Aufgaben spielen.
4. Das vom Server bestätigte Ergebnis, den Duellstatus oder die Platzierung sehen.
5. Eine Revanche anbieten, eine weitere Kategorie testen oder passende Inhalte lernen.

Ein Lernabschluss ist keine Voraussetzung zum Antreten. Lernenergie, kosmetische
Belohnungen und Ranglistenpunkte bleiben getrennt; Übungswiederholungen kaufen
keinen Wettbewerbsvorteil.

### 6.2 Lern-Schleife

Eine typische Lernsitzung soll ungefähr zwei bis vier Minuten dauern:

1. Eine Tagesmission oder ein Kapitel auswählen.
2. Fünf bis zehn kurze Aufgaben lösen.
3. Direkt sehen, wie Zahl, Stellenwert und Sprechreihenfolge zusammenhängen.
4. Eine Belohnung oder einen Wissensbaustein erhalten.
5. Einen Teil der Zahlenstadt aufbauen oder verbessern.
6. Den eigenen Fortschritt betrachten oder freiwillig weiterspielen.

Richtige Lösungen erzeugen beispielsweise **Klarheitsenergie**. Damit können Gebäude, Gleise oder Stationen der Zahlenstadt freigeschaltet werden. Der Fortschritt wird dadurch sichtbar, ohne ausschließlich auf abstrakten Punkten zu beruhen.

## 7. Spielmodi

### 7.1 Hörspur

Die App spricht eine Zahl. Die spielende Person tippt die passenden Ziffern oder zieht sie auf Stellenwertfelder.

Beispiel:

- gehört: „zwanzigeins“
- Eingabe: `2` auf Zehner, `1` auf Einer

Lernziel: Gesprochene Zahlwörter in eine Zifferndarstellung übersetzen.

### 7.2 Zahlenwerkstatt

Die Ziffernfolge oder eine Menge wird gezeigt. Sprachbausteine müssen in die passende Reihenfolge gezogen werden.

Beispiel:

- Zahl: `46`
- Bausteine: „vierzig“ und „sechs“
- Lösung: „vierzigsechs“

Optional kann anschließend die traditionelle Form „sechsundvierzig“ gezeigt und verglichen werden.

Lernziel: Struktur und Bildung der Zahlwörter verstehen.

### 7.3 Gleiswechsel

Ziffern und Wortbausteine fahren animiert über Gleise. Die Person muss erkennen oder auswählen, welche Route stellenwertgerecht ist.

Lernziel: Die Inversion von Zehnern und Einern unmittelbar sichtbar machen.

### 7.4 Sprechstudio

Eine Zahl wird angezeigt und soll in der vorgegebenen Sprechweise ausgesprochen werden. Die App gibt unmittelbares, freundliches Feedback.

Lernziel: Die neue Sprechweise aktiv bilden und aussprechen.

Technischer Hinweis: Standard-Spracherkennung kann ungewohnte Formen wie „vierzigsechs“ falsch transkribieren. Die Erkennung benötigt deshalb eine eigene Normalisierung, alternative Auswertung oder eine angepasste Strategie. Dieser Modus sollte nach den robusteren Kernspielen umgesetzt werden.

### 7.5 Blitzrunde

Eine kurze Runde wird gegen die eigene frühere Zeit gespielt. Vergleichbar sind nur gleichartige Aufgaben und Einstellungen.

Zwei klar getrennte Varianten: freies Training gegen die eigene Bestzeit und
ein standardisierter gewerteter Einzelversuch für die Kategorien-Rangliste.
Hilfen und frei angepasste Einstellungen gehören zum ungewerteten Training.

### 7.6 Alltagsmissionen

Spielerische Aufgaben mit:

- Preisen,
- Hausnummern,
- Telefonnummern,
- Maßen und Entfernungen,
- Jahreszahlen,
- Uhrzeiten.

Lernziel: Übertragung in alltagsnahe Situationen.

### 7.7 Kopfrechen-Reise

Rechenaufgaben werden gezeigt oder vorgelesen. Das Ergebnis wird eingegeben oder gesprochen. Dieser Modus baut auf den Erfahrungen der bestehenden App auf und eignet sich für eine spätere Ausbaustufe.

### 7.8 Spieler-Challenges

**Verbindlicher Umfang:** Zwei Spieler treten mit einem zufällig zusammengestellten
Mix geeigneter Abfragearten gegeneinander an. Jeder wählt unabhängig
„traditionell / verdreht“ oder „stellenwertgerecht / links nach rechts“.
Die Auswahl gilt für die ganze Runde und wird vor der ersten Aufgabe gespeichert.
Auch gemischte Duelle zwischen den beiden Modi sind ausdrücklich möglich.

**Vorgeschlagener erster Ausbau, noch keine beschlossene Live-Architektur:**
zeitversetzte 1-gegen-1-Duelle per Einladungscode/Link und über zufällige
Gegnerzuordnung. Keine gleichzeitige Anwesenheit erforderlich. Bei fehlendem
Gegner zeigt die App einen wartenden Status und bietet Einzeltraining an;
Bots oder erfundene Gegner werden nicht als echte Spieler dargestellt.
Live-Duelle können auf den gleichen fachlichen Regeln später aufbauen.

Vorgeschlagene Rundenregel: zehn Aufgaben, Zahlbereich zunächst 11–99, gleicher
Mix, gleiche Zahlen, Schwierigkeit und Reihenfolge für beide Teilnehmer.
Die Darstellung und Audioausgabe folgen der jeweiligen Sprechweise. Zufall wird
serverseitig festgelegt und versioniert; lokale Zufallsrunden sind kein gewertetes
Duell. Der Client erhält weder Lösungsschlüssel noch den Seed für künftige Aufgaben.

Geeignete erste Abfragearten:

- Zahl hören und Ziffern eingeben/auswählen (Hörspur),
- Ziffern sehen und das passende Zahlwort wählen (Zahlwort-Zuordnung),
- Wortbausteine passend zum gewählten Modus ordnen (Zahlenwerkstatt).

Die bisherige Lernfrage „Welche Form ist stellenwertgerecht?“ wird nicht
unverändert zum Duell: Sie würde die freie Moduswahl unterlaufen. Jede
Wettbewerbsvariante benötigt ihre eigene fachlich geprüfte Antwortlogik.
Spracherkennung, Kopfrechnen und Alltagsaufgaben folgen erst mit geeigneter
Validierung und fairen Regeln für beide Modi.

Zustände: erstellt → eingeladen/wartend → angenommen → in Bearbeitung →
beide Ergebnisse bestätigt → abgeschlossen. Hinzu kommen abgelehnt, abgelaufen,
abgebrochen und technisch ungültig. Ergebnisse des Gegners erscheinen erst nach
dem eigenen abgeschlossenen Versuch. Ein Versuch pro Teilnehmer; eine Revanche
ist ein neues Duell mit neuen Aufgaben. Ablaufzeit, Abbruchwertung, technische
Wiederaufnahme und Begrenzung offener Einladungen werden vor Umsetzung festgelegt.

### 7.9 Kategorien-Ranglisten und gewertete Einzelversuche

Jede freigegebene Abfrageart erhält einen eigenen Einstieg „Gewertet spielen“
und eine Bestenliste mit eigener Position und persönlichem Bestwert. Freies
Training bleibt daneben jederzeit verfügbar. Nur vom Server bestätigte Versuche
erscheinen in öffentlichen Ranglisten; pro Spieler zählt der beste gültige
Versuch innerhalb des jeweiligen Wertungszeitraums.

Eine Rangliste wird nicht nur nach Kategorie getrennt, sondern auch nach
Sprechweise, Zahlbereich/Schwierigkeitsstufe, Eingabeart und Regelversion.
Bei Hörabfragen gehört das standardisierte Audioprofil dazu. Zeiträume
(z. B. Saison oder Gesamtwertung) müssen sichtbar sein. Eine übergreifende
Ansicht beider Modi kann ergänzend angeboten werden, zeigt aber den Modus
jedes Ergebnisses und darf nicht ungeprüft als fairer Leistungsvergleich gelten.

**Wertungsvorschlag zur Erprobung:** zuerst Anzahl richtiger Antworten, dann
Gesamtzeit; eine unbeantwortete Aufgabe zählt als falsch. Eine Zeitüberschreitung
kann nicht durch Überspringen zu einer Bestzeit führen. Bei gleicher Wertung
teilen Spieler den Rang. Punktedarstellung, Zeitlimit und Messgenauigkeit werden
vor dem Online-MVP verbindlich definiert und versioniert. Die gemischten
Spielerduelle verwenden eine gemeinsame, vorab sichtbare Regel trotz
unterschiedlicher Sprechweisen; Ergebnisse sind kein wissenschaftlicher
Wirksamkeitsnachweis einer Sprechweise.

Neue Aufgaben pro Versuch müssen einem äquivalenten, getesteten Schwierigkeitsprofil
folgen. Ein reiner Zufallsmix ohne kontrollierte Schwierigkeit ist für eine
Kategorie-Bestenliste ungeeignet. Antwortoptionen, Eingabeverfahren, Audiohilfen
und Wiederholungen werden ebenfalls standardisiert. Beliebige lokale TTS-Stimmen
und frei wählbares Sprechtempo eignen sich fürs Training, aber nicht ohne weitere
Regeln für plattformübergreifende Zeitranglisten. Für gewertete Hörabfragen sind
identische geprüfte Audiodateien pro Zahl/Modus und ein definiertes Verfahren für
Ladezeit, Abspielstart, Wiederholungen und Antwortzeit vorzusehen.

## 8. Kampagne und Lernprogression

### Kapitel 1: Die ersten Dreher

- Zahlen 11 bis 19
- Vergleich von „dreizehn“ und „zehndrei“
- Einführung der Stellenwertfelder

### Kapitel 2: Zehnerstadt

- Zahlen 21 bis 99
- Vergleich von „einundzwanzig“ und „zwanzigeins“
- Fokus auf Zehner und Einer

### Kapitel 3: Das Stellenwertwerk

- Hunderter, Zehner und Einer
- Aufbau mehrstelliger Zahlen
- Animation der Sprechreihenfolge

### Kapitel 4: Zahlen im Alltag

- Preise, Maße, Telefonnummern und Adressen
- wechselnde Darstellungsformen

### Kapitel 5: Die Zeitreise der Zahlen

- Geschichte der Zahlwörter
- historische Personen und Reformideen
- andere Sprachen und Zahlwortsysteme

### Kapitel 6: Forscherlabor

- freie Übungen
- direkter Vergleich beider Sprechweisen
- persönliche Zeit- und Fehlerentwicklung
- optional ein methodisch sauberer Experimentmodus

## 9. Adaptive Schwierigkeit

Der Lernbereich soll lokal ein Kompetenzmodell pro Zahlenbereich und Aufgabentyp führen. Häufig verwechselte Zahlen erscheinen öfter, sicher beherrschte Zahlen seltener.

Mögliche Stufen:

1. mit sichtbaren Stellenwertfeldern,
2. mit farblichen Hilfen,
3. ohne Hilfen,
4. mit höherer Sprechgeschwindigkeit,
5. gemischt mit traditioneller Sprechweise,
6. in alltagsnahen Aufgaben.

Fehler kosten keine Leben. Stattdessen wird die Zahl zerlegt, animiert erklärt und später erneut angeboten. Eine Pause darf eine Serie nicht vollständig zerstören.

Gewertete Challenges verwenden keine individuell erleichterten oder adaptiven
Aufgaben innerhalb derselben Wertung. Für sie gelten die standardisierten
Schwierigkeitsprofile aus Abschnitt 7.9.

## 10. Geschichte und Wissensvermittlung

Die Geschichte soll in einem spielbaren **Zahlenmuseum** vermittelt werden. Kurze Karten, Animationen und kleine Quizfragen ersetzen lange Textseiten.

Wichtige Inhalte:

- Zahlwörter entstanden bereits vor dem heutigen indo-arabischen Stellenwertsystem.
- Die invertierte Sprechreihenfolge ist älter als die heutige Ziffernschreibweise.
- Das indo-arabische Stellenwertsystem verbreitete sich später in Europa.
- Die ältere Sprechgewohnheit blieb im Deutschen weitgehend bestehen.
- Jakob Köbel zeigte bereits um 1520 Formen wie „zwanzigeins“ und „zwanzigzwei“.
- Auch Adam Ries beschäftigte sich mit einer hörbaren Darstellung der Stellenwerte.
- Das Englische entwickelte sich langfristig von invertierten zu Zehner-Einer-Formen.
- In einigen Sprachen können traditionelle und reformierte Formen nebeneinander bestehen.
- Der Verein Zwanzigeins wurde 2004 gegründet.

Die Herkunft der Inversion sollte nicht als abschließend geklärte, einfache Geschichte dargestellt werden. Es gibt sprachgeschichtliche Erklärungen und Hypothesen. Die App sollte deutlich zwischen belegter Chronologie, plausibler Erklärung und nicht abschließend gesicherter Ursache unterscheiden.

Beispiel für eine freigeschaltete Karte:

> Schon vor mehr als fünfhundert Jahren zeigte Jakob Köbel Zahlen wie „zwanzigeins“ in seinen Rechenbüchern.

## 11. Wissenschaftliche Inhalte

Ein Bereich „Was wurde untersucht?“ stellt Forschung verständlich und quellenbasiert dar.

Geeignete Inhalte:

- Was bedeutet „Zahlwort in Ziffern übertragen“?
- Wie werden Bearbeitungszeit und Fehler gemessen?
- Warum werden Reihenfolgen in Studien zufällig variiert?
- Was ist eine Einübungsphase?
- Welche Ergebnisse wurden in den bisherigen Untersuchungen berichtet?
- Welche Fragen sind noch offen?

Die App sollte konkrete Studienergebnisse präzise und begrenzt formulieren. Eine passende Aussage wäre:

> In diesen Zahlendiktat-Studien kamen die teilnehmenden Kinder mit der stellenwertgerechten Ansage schneller und mit weniger Fehlern zum Ergebnis.

Zu vermeiden sind pauschale Versprechen wie:

> Zwanzigeins macht jeden Menschen automatisch besser in Mathematik.

Auch Gegenargumente und die sprachwissenschaftliche Debatte können als optionale Wissenskarten aufgenommen werden. Dies passt zum Anspruch, den Unterschied ergebnisoffen erfahrbar zu machen.

## 12. Navigation und Screens

Geplante Hauptnavigation für das erweiterte Produkt:

```text
Challenges | Lernen | Ranglisten | Profil | Mehr
```

### Challenges – primärer Einstieg

- gleichwertig sichtbare Zugänge „Gegen Spieler“ und „Kategorie testen“
- Duell erstellen, Einladung annehmen, zufälligen Gegner finden
- eigene Sprechweise vor jeder gewerteten Runde wählen
- offene Duelle, Ergebnisse und Revanche
- klarer Online-/Wartestatus; Zugang zum lokalen Lernen bei fehlender Verbindung

### Lernen

- bisherige Lernroute/Zahlenstadt, freies Üben und Zahlenlabor
- Lernfortschritt und Erklärungen ohne Ranglistendruck
- direkter Einstieg auch ohne Konto; keine Pflichtlektionen vor Challenges

### Ranglisten

- Kategorien und sichtbare Filter für Modus, Schwierigkeit und Zeitraum
- beste Spieler, eigene Position und eigener Bestwert
- nur bestätigte Ergebnisse; laufende Prüfung transparent kennzeichnen
- Direktstart eines gewerteten Versuchs mit den Regeln der gewählten Liste

### Profil

- Pseudonym und Kontoverwaltung für Online-Spiel
- Duellhistorie, persönliche Bestwerte und privater Lernfortschritt
- Datenverwaltung sowie Blockieren und Melden

### Mehr

- Geschichte, Forschung, Verein und Mitmachen
- Barrierefreiheit, Datenschutz und Einstellungen

Die neue Produktnavigation ist im lokalen Prototyp umgesetzt. Der Ranglistenbereich
zeigt bis zur Online-Anbindung persönliche Bestwerte, das Profil lokale Einstellungen.

## 13. Verein und Mitgliedschaft

Der Vereinsbereich sollte auffindbar sein, aber das Spiel nicht unterbrechen. Nach dem Abschluss eines größeren Kapitels kann einmalig und dezent auf „Zwanzigeins mitgestalten“ hingewiesen werden.

### Inhalt des aktuellen Aufnahmeantrags

- Name und Vorname
- Straße
- PLZ und Wohnort
- Telefon
- E-Mail
- Ort und Datum
- Unterschrift
- optionaler jährlicher Spendenbetrag
- optional IBAN, Kreditinstitut und BIC
- gesonderte Unterschrift für die Einzugsermächtigung

### Empfohlene Umsetzung

#### MVP

- den Verein und die Mitgliedschaft erklären,
- aktuellen offiziellen Antrag anzeigen oder herunterladen,
- Versandmöglichkeiten per E-Mail und Post nennen,
- keine persönlichen Daten innerhalb der App speichern.

#### Ausbaustufe

- geführtes Formular,
- lokale PDF-Erzeugung auf dem Gerät,
- Unterschrift über die systemeigenen Möglichkeiten,
- bewusster Export beziehungsweise Versand durch die antragstellende Person.

#### Spätere Online-Aufnahme

Nur nach gesonderter Konzeption:

- abgesichertes Backend,
- verschlüsselte Übertragung,
- klare Einwilligung und Datenschutzhinweise,
- definierte Aufbewahrung und Löschung,
- sichere Verarbeitung der Bankdaten,
- Schutz vor Spam und automatisierten Einsendungen,
- organisatorisch geklärter Bearbeitungsprozess im Verein.

Bankdaten dürfen niemals im normalen Spielstand oder in Analytics gespeichert werden. Für Kinder sollte der Mitgliedschaftsbereich deutlich als Erwachsenenbereich gekennzeichnet sein.

## 14. Gamification-Grundsätze

Empfohlen:

- sichtbarer Aufbau der Zahlenstadt,
- klar inszenierte Lernroute mit kurzen Etappen,
- persönliche Meisterschaft,
- kurze Missionen,
- freiwillige Herausforderungen,
- Sammlungen historischer Karten,
- adaptive Wiederholungen,
- wertschätzendes Feedback,
- unmittelbare Kombination aus visueller Rückmeldung, Animation und Klang,
- kosmetische Freischaltungen,
- private Lernfortschrittsanzeige,
- freiwillige Duelle und nachvollziehbare Kategorien-Ranglisten.

Nicht empfohlen:

- ungefilterte Gesamt-Ranglisten über nicht vergleichbare Regeln hinweg,
- harte tägliche Streaks,
- Verlust von Fortschritt nach Pausen,
- begrenzte Leben bei Fehlern,
- manipulative Benachrichtigungen,
- Belohnungen ausschließlich für lange Nutzungsdauer,
- Werbung oder In-App-Käufe im Lernfluss.

## 15. Technologieentscheidung und technisches Konzept mit Flutter

Flutter ist die verbindliche Technologie für die neue App. Das Framework unterstützt Anwendungen für Android, iOS, Web, Windows, macOS und Linux aus einer gemeinsamen Codebasis. Dies passt zum Ziel, das Spiel möglichst breit verfügbar zu machen und Spiellogik, Lerninhalte und Gestaltung nur einmal zu entwickeln.

Flutter eignet sich zugleich für das geplante rundenbasierte Casual Game. Standard-Widgets, Custom Painting und Flutter-Animationen sollten für das MVP ausreichen. Flame wird erst benötigt, wenn echte Echtzeitmechaniken wie eine frei steuerbare Figur, Kollisionen, Kamerafahrten oder eine kontinuierlich simulierte Spielwelt hinzukommen.

„Eine Codebasis“ bedeutet nicht, dass jede Plattform ohne zusätzliche Arbeit identisch veröffentlicht werden kann. Bedienung, Fenstergrößen, Berechtigungen, Spracherkennung, Dateidownloads, Signierung und Store-Veröffentlichung unterscheiden sich. Die Architektur muss diese Unterschiede gezielt kapseln, während Zahlenlogik, Lernmodell, Inhalte und der größte Teil der Oberfläche gemeinsam bleiben.

### 15.1 Zielplattformen

| Plattform | Rolle | Besondere Anforderungen |
|---|---|---|
| Android | primäre Veröffentlichungsplattform | Touch-Bedienung, viele Bildschirmgrößen, Mikrofonberechtigung, Play Store |
| iOS | primäre Veröffentlichungsplattform | Touch-Bedienung, Mikrofon- und Spracherkennungsberechtigung, App Store |
| Web | niedrigschwelliger Einstieg ohne Installation | responsive Oberfläche, Tastatur und Touch, Browserunterschiede, Deep Links, optional installierbare PWA |
| Windows | Desktop-Ausgabe | Maus, Tastatur, skalierbare Fenster, Installer beziehungsweise Microsoft Store |
| macOS | Desktop-Ausgabe | Maus, Tastatur, Fensterverhalten, Signierung, Notarisierung beziehungsweise Mac App Store |
| Linux | zusätzliche Desktop-Ausgabe | unterschiedliche Distributionen und Paketformate, zunächst direkter Download oder ausgewähltes Paketformat |

Alle Plattformziele werden beim Projektstart angelegt und regelmäßig gebaut. So werden plattformspezifische Probleme nicht erst am Ende entdeckt.

### 15.2 Veröffentlichungspriorität

Empfohlene Reihenfolge:

1. **Android und iOS:** vollständiges, touchoptimiertes Spielerlebnis.
2. **Web:** inhaltlich gleichwertiger, responsiver Einstieg parallel zum mobilen MVP.
3. **Windows und macOS:** optimierte Desktop-Veröffentlichung nach Stabilisierung des MVP.
4. **Linux:** technisch lauffähig halten und veröffentlichen, sobald Paketierung und Supportweg festgelegt sind.

Damit wird nicht verhindert, früh Test-Builds für alle Desktop-Systeme zu erzeugen. Die Reihenfolge beschreibt das gewünschte Veröffentlichungs- und QA-Niveau, nicht getrennte Neuentwicklungen.

### 15.3 Adaptives Bedienkonzept

Die App soll nicht lediglich eine schmale Smartphone-Oberfläche auf einen großen Bildschirm strecken. Sie reagiert auf den tatsächlich verfügbaren Platz und die Eingabemethode.

#### Smartphone

- einspaltige Aufgabenansicht,
- große Touch-Ziele,
- Navigation am unteren Bildschirmrand,
- Fokus auf kurze Sitzungen im Hoch- oder Querformat.

#### Tablet und Web mit mittlerer Breite

- größere Spielillustration,
- Aufgaben- und Hilfebereich gegebenenfalls nebeneinander,
- weiterhin touchfreundliche Bedienung.

#### Desktop und breites Webfenster

- begrenzte Inhaltsbreite statt übermäßig gestreckter Elemente,
- seitliche Navigation oder ergänzende Informationsfläche,
- vollständige Tastaturbedienung,
- sichtbare Hover- und Fokuszustände,
- optionale Tastenkürzel für wiederkehrende Aktionen,
- korrekte Wiederherstellung des Spielstands nach Fensteränderungen.

Layouts werden anhand von Fensterbreite und verfügbaren Fähigkeiten entschieden, nicht anhand einer starren Abfrage „Smartphone oder Desktop“.

### 15.4 Gemeinsamer Kern und Plattformadapter

Folgende Bestandteile bleiben vollständig gemeinsam:

- Zahlen- und Zahlwortlogik,
- lokale Aufgaben- und Levelgenerierung für das Training; Wettbewerbsaufgaben kommen vom Backend,
- Kampagne und Lernroute,
- adaptives Kompetenzmodell,
- Inhalte und Übersetzungen,
- Belohnungen und Fortschritt,
- Designsystem und wiederverwendbare Widgets,
- grundlegende lokale Datenmodelle.

Plattformabhängige Funktionen werden hinter klaren Dart-Schnittstellen gekapselt:

| Fähigkeit | Gemeinsame Schnittstelle | Mögliche Unterschiede |
|---|---|---|
| Sprachausgabe | `SpeechOutput` | native Stimmen, Browserstimmen, Verfügbarkeit |
| Spracherkennung | `SpeechInput` | mobile Systemdienste, Browserunterstützung, Desktop-Verfügbarkeit |
| lokaler Speicher | `ProgressStore` | App-Datenbank, Browser-Speicher, Sicherungsregeln |
| PDF und Export | `DocumentExport` | Teilen-Dialog, Browserdownload, Speichern-Dialog |
| externe Links | `ExternalLinkService` | Browsernavigation oder Systembrowser |
| Benachrichtigungen | `ReminderService` | Web- und Desktop-Unterstützung, Berechtigungen |

Wenn eine Fähigkeit nicht zuverlässig verfügbar ist, erhält die Plattform eine verständliche Alternative. Beispielsweise kann das Sprechstudio auf einem nicht unterstützten Browser durch eine Hör- und Auswahlaufgabe ersetzt werden. Das Kernspiel darf nicht von Spracherkennung abhängen.

### 15.5 Web-Ausgabe

Die Web-App dient als besonders zugänglicher Einstieg:

- ohne Store-Installation direkt ausprobierbar,
- responsive für Smartphone, Tablet und Desktop,
- verlinkbare Einstiegs- und Informationsseiten,
- optional als PWA installierbar,
- Lerninhalte nach dem ersten Laden offline nutzbar; Wettbewerb benötigt Verbindung,
- klare Aktualisierungsstrategie für neue Versionen.

SEO-relevante Vereins- und Erklärungstexte bleiben vorzugsweise auch als normale Webseiten auf `zwanzigeins.jetzt` verfügbar. Das Flutter-Spiel kann diese Inhalte ergänzen, sollte die indexierbare Vereinswebsite aber nicht ersetzen.

### 15.6 Desktop-Ausgaben

Die Desktop-App verwendet dieselbe Kampagne und Spiellogik, bietet aber eine für Maus und Tastatur optimierte Bedienung. Besonders sinnvoll ist sie für:

- Schulen und Lerntherapie,
- Präsentationen und Veranstaltungen,
- längere freie Übungseinheiten,
- barrierefreie Nutzung mit Tastatur und größeren Darstellungen.

Vor einer Veröffentlichung müssen je Betriebssystem Installer, Signierung, Updates und Supportweg festgelegt werden. Eine technisch erzeugbare Desktop-Datei ist noch kein ausreichend betreutes Desktop-Produkt.

### 15.7 Empfohlene Projektstruktur

```text
lib/
├── app/              Navigation, Theme, Konfiguration
├── presentation/     Screens, Widgets, Animationen
├── game/             Missionen, Regeln, Belohnungen
├── number_domain/    Zahlen, Stellenwerte, Sprechweisen
├── learning/         Kompetenzmodell, Wiederholungen
├── content/          Kapitel, Texte, Quellen, Wissenskarten
├── audio/            Aufnahmen und Text-to-Speech
├── speech/           Spracherkennung und Normalisierung
├── storage/          lokaler Fortschritt und Einstellungen
├── membership/       Vereinsinformationen und PDF-Ablauf
└── analytics/        optionale, datensparsame Ereignisse
```

### 15.8 Zahlen-Domain

Die Umwandlung zwischen Zahlen, Stellenwerten und Sprechweisen muss ein eigenständiges, UI-unabhängiges Dart-Modul sein.

Es sollte unter anderem abbilden:

- traditionell verdrehte Sprechweise,
- „zehneins“ gemäß dem Vereinsvorschlag,
- gegebenenfalls weitere dokumentierte Varianten,
- Sonderformen und Nullbehandlung,
- später Ordnungszahlen, Brüche und Kommazahlen.

Die fachlichen Regeln werden aus dem jeweils freigegebenen Positionspapier des Vereins übernommen und mit umfangreichen Beispielen getestet.

### 15.9 Inhalte

Kapitel, Aufgabenparameter, Erklärtexte, Quellen und Wissenskarten sollten datengetrieben vorliegen. Dadurch können sie redaktionell aktualisiert werden, ohne die Spiellogik umzubauen.

### 15.10 Offline-Betrieb

Der Lern- und Entdeckungsbereich funktioniert weiterhin offline und ohne Konto.
Lernfortschritt wird lokal gespeichert; verfügbare Basisinhalte bleiben nutzbar.
Die aktuelle Sprachausgabe hängt von der Unterstützung des Zielsystems ab.

Duelle, Matchmaking, gewertete Versuche und gemeinsame Ranglisten benötigen eine
Online-Verbindung. Offline gespielte Runden sind Training und werden nicht
nachträglich als verifizierte Wettbewerbsleistungen hochgeladen. Bereits
bestätigte Ergebnisse können mit Stand-Zeitpunkt zwischengespeichert werden.
Verbindungsabbrüche müssen als eigener Zustand sichtbar sein; Regeln zur
Wiederaufnahme dürfen weder zusätzliche Versuche noch doppelte Wertungen zulassen.

### 15.11 Multiplattform-Qualitätssicherung

Die kontinuierliche Integration soll mindestens Folgendes prüfen:

- statische Dart-Analyse und Unit-Tests,
- Android-Build,
- iOS-Build auf macOS,
- Web-Build und Browser-Tests,
- Windows-Build auf Windows,
- macOS-Build auf macOS,
- Linux-Build auf Linux,
- Widget- und Golden Tests für mehrere Fenstergrößen,
- Tastatur-, Touch- und Screenreader-Grundabläufe.

Native Store-Pakete müssen auf den jeweiligen Betriebssystemen gebaut und signiert werden. Insbesondere erfordern iOS und macOS eine macOS-Buildumgebung; Windows-Pakete werden unter Windows gebaut.

### 15.12 Online-Backend und Betrieb

**Ja: Für diesen Produktumfang ist ein zentraler Serverdienst mit dauerhafter
Datenbank erforderlich. Eine zusätzliche eigene Servermaschine ist nicht zwingend.**
Der Dienst kann nach gesonderter Auswahl auf geeigneter vorhandener Infrastruktur,
einem verwalteten Dienst oder eigener Infrastruktur laufen. Hosting, Anbieter,
Region, Stack und Kosten sind noch offen; es wird jetzt nichts provisioniert.

Die Flutter-App zeigt Inhalte und erfasst Eingaben. Das Backend ist die maßgebliche
Instanz für Identität, Duellstatus, Aufgabenvergabe, Antwortprüfung, Wertung und
Ranglisten. Ein vom Client gesendeter Endscore ist keine vertrauenswürdige Leistung.

Erforderliche Funktionen:

- pseudonyme Spieleridentität, sichere Sitzungen, Kontowiederherstellung und Löschung,
- Einladungscodes/Links, zufällige Gegnerzuordnung und Duell-Zustandsautomat,
- versionierte Aufgabenvorlagen, serverseitige Erzeugung und gespeicherte Moduswahl,
- authentifizierte, schrittweise Ausgabe von Aufgaben und Annahme von Antworten,
- serverseitige Prüfung von Antworten, Reihenfolge, Fristen und Teilnehmerrechten,
- atomarer Abschluss und idempotente Wiederholungsanfragen gegen Doppelwertungen,
- standardisierte Einzelversuche und Kategorien-Ranglisten mit Pagination,
- Hintergrundverarbeitung für Ablaufzeiten und optional gewählte Benachrichtigungen,
- Melden, Blockieren, Namensmoderation und nachvollziehbare Korrektur falscher Scores.

Ein erstes Datenmodell umfasst Spieler, Regelversionen, Kategorien, Duelle,
Teilnahmen mit Sprechweise, Versuche, ausgegebene Aufgaben, Antworten und bestätigte
Ergebnisse. Ranglisten werden daraus abgeleitet; Lernfortschritt bleibt zunächst
lokal und wird nicht automatisch Teil eines öffentlichen Profils.

**Fairness und Manipulationsschutz:** Serverzeit, einmalige Aufgaben-/Versuchskennungen,
begrenzte Anfrageraten, Schutz gegen wiederholtes Einreichen und unmögliche
Antwortfolgen. Geheimnisse und korrekte Antworten bleiben auf dem Server.
Eine gemeinsame fachliche Testsammlung prüft Dart-Darstellung und Backend-Auswertung.
Client-Zeitangaben dürfen nur ergänzende Plausibilitätsdaten sein. Servermessung
enthält Netzlatenz; für seriöse Zeitvergleiche werden Messbeginn, Netzbedingungen,
Zeitauflösung und Ungültigkeitsregeln vor dem Start getestet und veröffentlicht.
Ein Backend verhindert nicht jeden Bot oder jede Hilfe durch Dritte. Verdächtige
Leistungen brauchen Prüfung und einen Umgang mit Einsprüchen.

**Minimaler Betrieb:** zunächst API und Datenbank, Hintergrundjobs und Audioauslieferung;
für zeitversetzte Duelle sind keine dauerhaften Echtzeitverbindungen notwendig.
Separate Test- und Produktionsumgebungen, TLS, geschützte Zugangsdaten,
Datenbankmigrationen, Fehlerüberwachung, Kosten-/Kapazitätskontrolle,
Aufbewahrungsregeln sowie gesicherte Backups mit Restore-Test gehören vor den
öffentlichen Online-Start dazu. Eine eventuelle Nutzung bestehender Infrastruktur
wird anhand ihrer tatsächlichen Kapazität und Isolation geprüft.

Ein neuer Backend-Stack oder die Anwendung des gemeinsamen Architekturstandards
wird erst bei einer späteren Umsetzung ausdrücklich abgestimmt. Diese Planung
legt keinen Anbieter und keinen Architekturstandard fest.

## 16. Datenschutz und Schutz von Kindern

Für den bestehenden lokalen Lern-MVP gilt:

- keine Registrierung,
- keine Klarnamen im Spielprofil,
- keine Werbung,
- keine Standortdaten,
- keine Kontaktlisten,
- keine Cloud-Synchronisierung,
- Mikrofonzugriff erst beim bewussten Start des Sprechstudios,
- verständliche Begründung jeder Berechtigung,
- lokale Daten vollständig löschbar,
- Analytics nur optional, datensparsam und nach gesonderter Prüfung.

Für das geplante Online-Spiel kommen pseudonyme Konten, Spielteilnahmen und
bestätigte Ergebnisse hinzu. Öffentlich erscheinen nur das gewählte Pseudonym,
die für die Wertung nötigen Angaben und der Rang, keine E-Mail-Adressen,
Klarnamen, Geburtsdaten oder Lernfehlerprofile. Teilnahme und Sichtbarkeit werden
vor dem gewerteten Start erklärt; Training bleibt ohne Veröffentlichung möglich.

Da Kinder zur Zielgruppe gehören, sind Alterskonzept, gegebenenfalls erforderliche
Einwilligungen, zulässige Kontomethoden, öffentliche Sichtbarkeit und Lösch-/
Aufbewahrungsregeln vor dem Online-Release fachlich und rechtlich zu klären.
Das ist eine offene Freigabevoraussetzung, keine bereits erfolgte Rechtsprüfung.
Kein Chat, keine Kontaktbuchübernahme und keine Standortfunktion im ersten Ausbau;
zufällige Pseudonyme sowie Melden und Blockieren reduzieren soziale Risiken.
Einladungscodes müssen begrenzt gültig und gegen massenhaftes Erraten geschützt sein.
Kontolöschung und deren Auswirkungen auf Duelle und Ranglisten werden festgelegt.
Cloud-Synchronisierung des Lernfortschritts und Online-Mitgliedschaft bleiben
separate Vorhaben.

## 17. Barrierefreiheit

Barrierefreiheit soll von Beginn an berücksichtigt werden:

- skalierbare Schrift,
- ausreichend große Berührungsflächen,
- hohe Kontraste,
- Informationen nicht nur durch Farbe vermitteln,
- Screenreader-Beschriftungen,
- Untertitel beziehungsweise sichtbare Zahlwörter zu Audioinhalten,
- reduzierbare Animationen,
- abschaltbare Musik und getrennt regelbare Effekte,
- einstellbare Sprechgeschwindigkeit,
- kein Zeitdruck in den Standard-Lernmissionen.

Gewertete Versuche erklären, welche Hilfen und Zeitregeln für Vergleichbarkeit
feststehen. Unterstützende Einstellungen bleiben im Training verfügbar;
Wettbewerbsvarianten mit wesentlich anderen Regeln erhalten eine eigene Wertung.

## 18. Qualitätssicherung

### Automatisierte Tests

- Unit-Tests für alle Zahlwortregeln und Grenzfälle
- Tests der Aufgaben- und Levelgenerierung
- Tests des adaptiven Wiederholungsmodells
- Widget-Tests für zentrale Abläufe
- Golden Tests für wichtige Bildschirmgrößen
- Integrationstests für Onboarding, Mission und lokalen Fortschritt
- Tests des Offline-Verhaltens

### Fachliche Prüfung

- Freigabe der Zahlwortregeln durch den Verein
- Prüfung historischer Texte und Quellen
- Prüfung wissenschaftlicher Aussagen durch fachkundige Mitglieder
- regelmäßiger Abgleich mit dem aktuellen Positionspapier

### Nutzertests

- Kinder aus der vorgesehenen Altersgruppe
- Erwachsene und Deutschlernende
- Lehrkräfte und Lerntherapeutinnen beziehungsweise Lerntherapeuten
- Tests ohne vorherige Erklärung, um Verständlichkeit zu überprüfen

### Online-Abnahmekriterien

- Zwei Spieler können dasselbe Duell jeweils in unterschiedlicher Sprechweise abschließen.
- Jede freigegebene Abfrageart funktioniert fachlich korrekt in beiden Modi.
- Einladungen, Gegnerzuordnung, fehlende Gegner, Ablehnung und Ablauf sind getestet.
- Verbindungsabbruch, App-Neustart, Doppelsenden und gleichzeitiger Abschluss erzeugen keine Doppelwertung.
- Antworten/Seeds künftiger Aufgaben und fremde private Daten werden nicht offengelegt.
- Manipulierte Endscores, fremde Versuch-IDs und Antworten nach Frist werden abgewiesen.
- Ranglisten trennen ihre Regelvarianten und zeigen die eigene Platzierung korrekt.
- Lernfortschritt bestehender Installationen bleibt erhalten; Offline-Lernen benötigt kein Konto.
- Zeit-/Audiovergleichbarkeit wird auf iOS, Android und Web praktisch geprüft.
- Löschung, Blockieren, Melden, Lasttests, Monitoring und Backup-Wiederherstellung sind überprüft.

## 19. Erfolgskriterien

Wichtige Produktkennzahlen sind:

- Anteil gestarteter und abgeschlossener erster Challenges,
- angenommene Duelle, Wartezeiten bei Gegnerzuordnung und Revanchen,
- gültige Einzelversuche je Kategorie und freiwillige Rückkehr zur Rangliste,
- Wechsel zwischen Challenges und Lernen,
- Anteil abgeschlossener erster Lernmissionen,
- Rückkehr nach einem und sieben Tagen,
- Entwicklung von Fehlerzahl und Bearbeitungszeit,
- freiwillig absolvierte Vergleichsrunden,
- häufig verwechselte Zahlen und Aufgabentypen,
- Anteil der Personen, die nach einigen Missionen stellenwertgerechte Zahlwörter ohne Hilfe bilden können,
- qualitative Rückmeldungen von Kindern, Eltern, Lehrkräften und Deutschlernenden,
- Nutzung des Wissens- und Vereinsbereichs.

Bei Analysen muss zwischen lokal dargestelltem persönlichem Lernfortschritt und optional erhobenen Produktdaten unterschieden werden.

## 20. Umsetzungsphasen

Die bisherigen Aufwandsschätzungen bezogen sich auf eine lokale Lern-App. Sie
gelten nicht für den erweiterten Online-Umfang. Eine neue Aufwandsschätzung folgt
nach Festlegung von Wertungsregeln, Kontokonzept und Backend.

### Phase 0: Challenge-Konzept festlegen

- Konten/Alterskonzept, Wettbewerbsregeln und Kategoriegrenzen definieren
- Zufallsmix, gleiche Schwierigkeit und beide Sprechweisen fachlich erproben
- Audio- und Zeitmessung, Abbruch- und Gleichstandsregeln bestimmen
- asynchrone Duelle bestätigen oder Live-Anforderung gesondert spezifizieren
- Einstieg und Navigation mit zwei gleichwertigen Produkthälften prototypisieren

### Phase 1: Lokaler Challenge-Prototyp

- gemeinsame Aufgabenmodelle um beide Modi erweitern
- geeignete Abfragearten mit gemischten Runden und Kategorie-Einzeltraining bauen
- Wertung und Feedback lokal testen; noch keine vermeintlich echte Online-Rangliste
- bestehende Lernroute und gespeicherten Lernfortschritt erhalten

### Phase 2: Geschlossene Online-Beta

- Backend, Datenbank, Sitzungen und pseudonyme Spielerprofile
- zeitversetzte Duelle per Einladung und zufällige Gegnerzuordnung
- serverbestätigte Ergebnisse und gewertete Einzelversuche je Kategorie
- Regeln, Ranglistenfilter, Wiederaufnahme und Manipulationsschutz testen
- Melden/Blockieren, Löschung, Monitoring und Backups vorbereiten

### Phase 3: Öffentliches Produkt mit beiden Hälften

- Challenges als primären Einstieg, Lernen als gleichwertigen Bereich veröffentlichen
- Balance-, Geräte-, Browser-, Last- und Barrierefreiheitstests abschließen
- Datenschutz-/Alterskonzept und Betriebsbereitschaft freigeben
- TestFlight-/Google-Play-Testphase und Web-Abnahme
- Store-Auftritt auf Challenge-Hook und Lern-/Entdeckungsangebot ausrichten

### Phase 4: Weiterer Ausbau

- Live-Duelle bei bestätigtem Bedarf
- zusätzliche Abfragearten, Saisons und gegebenenfalls Ligen
- Desktop-Veröffentlichungen nach gesonderter Plattformabnahme
- weitere Lernkapitel, Lernbegleitung und optionale Lernfortschritts-Synchronisierung

## 21. MVP-Zuschnitt für das erweiterte Produkt

Das erste vollständige Produkt mit Challenge-Hook umfasst:

- eigenständige Flutter-App mit Challenge- und Lernbereich,
- Zahlen 11–99 in beiden frei wählbaren Sprechweisen,
- drei fachlich geeignete Wettbewerbs-Abfragearten (Hören, Zuordnen, Bausteine),
- gemischte Duelle mit unabhängigem Modus je Spieler,
- zeitversetzte Einladungsduelle und zufällige Gegnerzuordnung als Planungsvorschlag,
- gewertete Einzelversuche und Bestenlisten je Kategorie und Regelvariante,
- pseudonyme Online-Identität und serverseitig geprüfte Wertung,
- sechs vorhandene Lernstationen, freies Üben und Zahlenlabor als lokale Grundlage,
- privater Lernfortschritt, Zahlenmuseum und Vereinsinformationen,
- Offline-Lernen ohne Konto sowie grundlegende Barrierefreiheit,
- Android, iOS und Web als erste Veröffentlichungsziele,
- Betrieb, Datenschutz, Missbrauchsmeldung und Kontolöschung für den Online-Teil.

Bewusst spätere Funktionen:

- Live-Duelle, Chat und komplexe soziale Netzwerke,
- Sprechstudio/Spracherkennung im gewerteten Wettbewerb,
- Kopfrechnen, große Zahlen und besondere Zahlwortarten,
- Lehrkraftmodus und Cloud-Synchronisierung des Lernfortschritts,
- vollständig digitaler Mitgliedsantrag,
- umfangreiche oder wissenschaftliche Datenerhebung,
- adaptive lokale Wiederholung anhand einzelner Fehlermuster.

## 22. Offene Entscheidungen vor der Umsetzung

1. Wie lautet der endgültige Produktname?
2. Wie verspielt soll die Duolingo-inspirierte Gestaltung gegenüber einer sachlicheren Wissens-App wirken?
3. Welche Figuren tragen die Geschichte, ohne die traditionelle Sprechweise abzuwerten?
4. Welche Zielgruppe bestimmt Ton und Schwierigkeitskurve des ersten Releases?
5. Welche Regeln und Varianten aus dem Positionspapier gehören verbindlich in das MVP?
6. Werden professionelle Sprachaufnahmen verwendet oder zunächst Text-to-Speech?
7. Soll der Lernfortschritt später optional synchronisiert werden? Online-Wettbewerbsdaten liegen auf dem Backend.
8. Welche Nutzungsdaten wären für Produktverbesserung wirklich erforderlich?
9. Wer im Verein gibt historische, wissenschaftliche und sprachliche Inhalte frei?
10. Soll der Mitgliedsantrag im MVP nur verlinkt oder bereits lokal als PDF erzeugt werden?
11. Sollen Windows, macOS und Linux gemeinsam oder gestaffelt veröffentlicht werden?
12. Über welche Stores beziehungsweise Downloadwege werden die Desktop-Ausgaben angeboten?
13. Werden zeitversetzte Duelle für den ersten Online-Ausbau bestätigt oder ist gleichzeitiges Live-Spielen erforderlich?
14. Welche zehn Aufgaben, Zeitlimits, Punkte-, Gleichstands- und Abbruchregeln gelten zunächst?
15. Welche Modi-/Schwierigkeitsfilter und Wertungszeiträume bietet jede Bestenliste?
16. Welche Konto- und Alterslösung ist für Kinder und Erwachsene geeignet?
17. Wie werden Hör-Audio, Eingabeart und Netzlatenz für gewertete Versuche standardisiert?
18. Welche vorhandene oder neue Infrastruktur trägt API, Datenbank und Audioauslieferung?
19. Wer betreibt den Dienst und bearbeitet Moderation, Löschanfragen und Score-Einsprüche?
20. Wie funktionieren Duellablauf, Wiederaufnahme, Einladungsgrenzen und Gegnerzuordnung im Detail?

## 23. Inhaltliche Quellenbasis

- Website und Selbstdarstellung von Zwanzigeins e. V.: <https://zwanzigeins.jetzt/>
- Vereinsziele: <https://zwanzigeins.jetzt/infos/was-will-der-verein>
- Chronik: <https://zwanzigeins.jetzt/infos/chronik>
- Vorschlag zur Zahlensprechweise: <https://zwanzigeins.jetzt/aktivitaeten/projekte/vorschlag-zahlensprechweise>
- Unterrichtsversuche: <https://zwanzigeins.jetzt/aktivitaeten/projekte/unterrichtsversuche>
- Literatur und Debatte: <https://zwanzigeins.jetzt/infos/literatur>
- Mitgliedschaft: <https://zwanzigeins.jetzt/verein/mitgliedschaft>
- Flutter Casual Games Toolkit: <https://docs.flutter.dev/resources/games-toolkit>
- Flutter Offline-first: <https://docs.flutter.dev/app-architecture/design-patterns/offline-first>
- Flutter Accessibility: <https://docs.flutter.dev/ui/accessibility>
- Unterstützte Flutter-Plattformen: <https://docs.flutter.dev/reference/supported-platforms>
- Flutter-Plattformintegration: <https://docs.flutter.dev/platform-integration>
- Adaptives und responsives Flutter-Design: <https://docs.flutter.dev/ui/adaptive-responsive>
- Best Practices für adaptive Flutter-Oberflächen: <https://docs.flutter.dev/ui/adaptive-responsive/best-practices>
