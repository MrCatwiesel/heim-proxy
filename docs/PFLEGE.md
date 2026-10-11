# Pflege

## Aktualisieren

Konsole des Containers (Proxmox → Container → *Console*):

```bash
/opt/heim-proxy/update.sh
```

Wer nicht automatisch die neueste Version will: in `/opt/heim-proxy/docker-compose.yml` statt `latest` eine feste Versionsnummer eintragen (siehe [Releases](https://github.com/NginxProxyManager/nginx-proxy-manager/releases)) und zum Aktualisieren die Nummer erhöhen.

## Sicherung

- Proxmox: Container in die geplante Sicherung aufnehmen (*Datacenter → Backup → Add*, Modus **Snapshot**).
- Wichtig sind nur `/opt/heim-proxy/data` (Einstellungen) und `/opt/heim-proxy/letsencrypt` (Zertifikate).

## Fehlersuche

| Problem | Ursache / Lösung |
| --- | --- |
| Zertifikat lässt sich nicht holen | Name zeigt nicht auf deine IP (`getent hosts name`), oder Port 80 ist nicht auf den Proxy weitergeleitet |
| Von außen nichts erreichbar, im WLAN schon | Test im Mobilfunk machen; sonst Portfreigabe und DS-Lite prüfen ([EINRICHTUNG.md](EINRICHTUNG.md#ipv4-oder-nur-ipv6)) |
| Im WLAN nichts erreichbar, von außen schon | Router kann kein NAT-Loopback. FRITZ!Box kann es, sonst im lokalen DNS den Namen auf die Proxy-IP zeigen lassen |
| „502 Bad Gateway“ | Ziel-Server aus oder falsche IP/Port im Proxy Host. Im Proxy-Container testen: `curl http://IP:PORT` |
| „413 Request Entity Too Large“ | Upload-Grenze im Reiter *Advanced* anheben (`client_max_body_size`) |
| Verwaltung startet nicht | `cd /opt/heim-proxy && docker compose logs --tail 50` |
| Docker startet im Container nicht | Container-Optionen: *Features* „nesting“ und „keyctl“ müssen an sein |
