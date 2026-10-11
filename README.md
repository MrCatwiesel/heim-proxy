# Heim-Proxy

Ein zentraler **Reverse-Proxy** für die Server zu Hause auf Proxmox. Er ist von außen über DynDNS erreichbar.

Statt für jeden Server einen eigenen Port im Router freizugeben, laufen **alle Webdienste über Port 443**. Der Proxy erkennt am Namen, wohin eine Anfrage gehört, und holt die **HTTPS-Zertifikate automatisch**.

```
Internet ──► Router ──(80/443)──► Heim-Proxy (LXC, Nginx Proxy Manager)
                                     ├── reise.example.de  ──► 192.168.178.50:8787  (Nix wie weg)
                                     ├── cloud.example.de  ──► 192.168.178.60:80
                                     └── …                 ──► weitere Server
```

**Warum Nginx Proxy Manager?**
- Bedienung im Browser, auch am iPad. Neue Dienste sind in einer Minute eingetragen.
- Let's Encrypt eingebaut, Zertifikate verlängern sich selbst.
- Zugriffslisten, Weiterleitungen und Sperrseiten ohne Konfigurationsdateien.

## Einrichtung in 4 Schritten

| Schritt | Was | Anleitung |
| --- | --- | --- |
| 1 | Container auf Proxmox anlegen (Skript) | [docs/EINRICHTUNG.md](docs/EINRICHTUNG.md#1-container-anlegen) |
| 2 | Namen (DynDNS) und Router-Weiterleitung | [docs/EINRICHTUNG.md](docs/EINRICHTUNG.md#2-namen-dyndns) |
| 3 | Anmelden, absichern | [docs/SICHERHEIT.md](docs/SICHERHEIT.md) |
| 4 | Dienste eintragen, z. B. Nix wie weg | [docs/NIX-WIE-WEG.md](docs/NIX-WIE-WEG.md) |

Kurzfassung: In der Proxmox-Oberfläche → Knoten → **Shell**:

```bash
curl -fsSL https://raw.githubusercontent.com/MrCatwiesel/heim-proxy/main/proxmox/create-ct.sh -o create-ct.sh
bash create-ct.sh
```

## Dateien

```
proxmox/create-ct.sh   läuft auf dem Proxmox-Host: legt den Container an und startet install.sh darin
install.sh             läuft im Container: Docker + Nginx Proxy Manager
update.sh              Aktualisieren
docker-compose.yml     Definition des Proxys
docs/
  EINRICHTUNG.md       Container, DynDNS, Router, Umzug bestehender Weiterleitungen
  SICHERHEIT.md        Erste Anmeldung, was nie nach außen darf
  NIX-WIE-WEG.md       Abgleich-Server der Reise-App eintragen
  DIENSTE.md           Liste aller Dienste hinter dem Proxy (hier pflegen!)
  PFLEGE.md            Update, Sicherung, Fehlersuche
```

## Verwandte Projekte

- [Nix wie weg](https://github.com/MrCatwiesel/nix-wie-weg-): die Reise-App. Ihr Abgleich-Server läuft hinter diesem Proxy.
