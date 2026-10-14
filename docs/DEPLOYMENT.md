# Test-Deployment auf baer-software.com

Die Flutter-Web-App wird als eigener statischer Virtual Host bereitgestellt:

- URL: `https://zwanzigeins.baer-software.com`
- Server: `165.245.251.172`
- Deployment-Pfad: `/var/www/zwanzigeins-game`
- Quellcode: ausschließlich `https://github.com/A-Baer/zwanzigeins-game.git`
- Flutter: `3.47.4`, auf dem Server aus dem offiziellen, SHA-256-geprüften Archiv
- Datenbank: keine

Der bestehende Virtual Host für `baer-software.com`, `www.baer-software.com` und
`dashboard.baer-software.com` bleibt unverändert. Das Spiel erhält eine eigene
Nginx-Datei und ein eigenes Let's-Encrypt-Zertifikat.

## Erstinstallation

1. Das geprüfte `infrastructure/server-setup.sh` nach `/tmp` auf den Server
   übertragen, die lokale und entfernte SHA-256-Prüfsumme vergleichen und als
   `root` ausführen.
2. Den ersten exakten Git-Commit über `deploy.sh` veröffentlichen. Der lokale
   Health-Check läuft zunächst über HTTP mit fest gesetztem Host-Header.
3. Den Porkbun-A-Record `zwanzigeins` mit TTL 600 auf `165.245.251.172` anlegen.
4. Warten, bis ausschließlich diese IPv4-Adresse aufgelöst wird.
5. Das geprüfte `infrastructure/server-enable-tls.sh` ebenso übertragen,
   vergleichen und als `root` ausführen.

Beide Setup-Skripte sind wiederholbar. Das TLS-Skript prüft, dass Certbot die
vorhandene Website-Konfiguration nicht verändert hat.

## Deployment

Nur ein vollständiger Commit-SHA, der exakt `origin/main` und dem sauberen lokalen
`HEAD` entspricht, darf veröffentlicht werden:

```bash
DEPLOY_REVISION=<40-stelliger-SHA> ./deploy.sh
```

Die Anwendung wird aus Git in ein neues Release geklont und auf dem Server gebaut.
Der Symlink `current` wird erst nach erfolgreichem Build atomar umgestellt. Scheitert
der Health-Check, wird der vorherige Symlink wiederhergestellt. Drei Releases bleiben
für Rollbacks erhalten.

## Rollback

```bash
./rollback.sh
```

Der Rollback schaltet atomar auf das jüngste andere Release zurück, prüft die
öffentliche HTTPS-Anwendung lokal mit korrektem Hostnamen/SNI und stellt bei einem
Fehler wieder das Ausgangsrelease her. Er verändert keine Datenbank, da die App
keine verwendet.
