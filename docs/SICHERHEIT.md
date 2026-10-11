# Sicherheit

## Erste Anmeldung

1. Im Heimnetz `http://<Proxy-IP>:81` öffnen.
2. Konto anlegen. Bei älteren Versionen gelten zunächst `admin@example.com` / `changeme`.
3. Sofort **eigene E-Mail und ein starkes Passwort** setzen (*Users → Edit / Change Password*). Die E-Mail nutzt Let's Encrypt auch für Hinweise zu Zertifikaten.

## Was nie nach außen darf

| Dienst | Grund |
| --- | --- |
| Proxy-Verwaltung (Port 81) | Wer hier hineinkommt, kann alle Dienste umleiten |
| Datenbank-Server | Nur Programme im Heimnetz greifen darauf zu; Angriffe auf offene Datenbanken laufen automatisiert |
| Proxmox (8006), SSH (22) | Verwaltung des ganzen Servers |

Für Zugriff von unterwegs auf diese Dinge ist ein **VPN** besser, z. B. das in der FRITZ!Box eingebaute WireGuard.

## Empfohlene Einstellungen je Proxy Host

- **SSL**: Zertifikat „Request a new SSL Certificate“, **Force SSL**, **HTTP/2** und **HSTS** an.
- **Block Common Exploits** an.
- Dienste, die nur ihr nutzt und die selbst kein Login haben: unter *Access Lists* eine Liste mit Benutzername und Passwort anlegen und dem Host zuweisen.
  - *Nicht* für den Abgleich-Server von Nix wie weg: Der hat seinen eigenen Schlüssel, und die App kann kein zusätzliches Passwort mitschicken.

## Updates

- Debian im Container: Sicherheits-Updates laufen automatisch (unattended-upgrades).
- Nginx Proxy Manager: etwa monatlich `/opt/heim-proxy/update.sh` ausführen (siehe [PFLEGE.md](PFLEGE.md)).
