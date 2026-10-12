# Dienst eintragen: Nix wie weg (Abgleich-Server)

Voraussetzung: Der Abgleich-Server läuft in einem eigenen Container. Die Anleitung steht im Projekt *Nix wie weg* unter `server/proxmox/README.md`, **Weg A**:

```bash
apt update && apt install -y curl
curl -fsSL https://raw.githubusercontent.com/MrCatwiesel/nix-wie-weg-/main/server/proxmox/install.sh | bash
```

Am Ende zeigt das Skript die Adresse (z. B. `http://192.168.178.50:8787`) und den **Schlüssel**.

## Im Nginx Proxy Manager

*Hosts → Proxy Hosts → Add Proxy Host*

**Reiter „Details“**

| Feld | Wert |
| --- | --- |
| Domain Names | `reise.meinname.de` (dein Name aus [EINRICHTUNG.md](EINRICHTUNG.md#2-namen-dyndns)) |
| Scheme | `http` |
| Forward Hostname / IP | `192.168.178.50` (IP des Nix-wie-weg-Containers) |
| Forward Port | `8787` |
| Block Common Exploits | an |
| Websockets Support | aus (nicht nötig) |
| Access List | *Publicly Accessible* |

**Reiter „SSL“**

- *Request a new SSL Certificate*
- Force SSL, HTTP/2 Support, HSTS: an
- E-Mail eintragen, den Bedingungen zustimmen → **Save**

**Reiter „Advanced“**: Fotos werden in voller Größe übertragen, deshalb die Upload-Grenze anheben:

```nginx
client_max_body_size 40m;
proxy_request_buffering off;
proxy_read_timeout 120s;
```

## Prüfen

Mit dem Handy **im Mobilfunk** (nicht im WLAN):

```
https://reise.meinname.de/api/health
```

Erwartet: `{"ok":true,...}`.

## In der App verbinden

1. App → *Einstellungen → Geräte-Abgleich*
2. Server-Adresse `https://reise.meinname.de` und Schlüssel → **Verbinden**
3. „Kopplungs-Link teilen“ an die anderen Geräte schicken → dort öffnen → **Verbinden**

## Die App selbst kommt auch vom eigenen Server

Ab Nix wie weg 1.3 liefert der Abgleich-Server die App gleich mit aus. Unter `https://reise.meinname.de` ist dann die App, unter `/api/…` der Abgleich. Am Proxy Host ändert sich nichts. Einrichtung und tägliches Update übernimmt das Installationsskript im Nix-wie-weg-Container (siehe dort `server/proxmox/README.md` → „App vom eigenen Server“).
