# Einrichtung

## 1. Container anlegen

In der Proxmox-Oberfläche den Knoten (linke Spalte) auswählen, dann **Shell** öffnen:

```bash
curl -fsSL https://raw.githubusercontent.com/MrCatwiesel/heim-proxy/main/proxmox/create-ct.sh -o create-ct.sh
bash create-ct.sh
```

Das Skript fragt:

| Frage | Hinweis |
| --- | --- |
| Container-Nummer | Vorschlag übernehmen |
| Feste IP | Freie Adresse **außerhalb** des DHCP-Bereichs des Routers (FRITZ!Box: Heimnetz → Netzwerk → IPv4) |
| Gateway | IP des Routers, meist `.1` |
| Speicher | wie bei deinen anderen Containern (`local-lvm`, `local-zfs` …) |
| Root-Passwort | für die Konsole des Containers |

Danach läuft ein unprivilegierter Debian-12-Container mit 1 Kern, 1 GB RAM und 8 GB Festplatte. Er startet automatisch mit Proxmox. Darin arbeiten Docker und Nginx Proxy Manager, und Sicherheits-Updates werden automatisch eingespielt.

> Ohne Skript: CT von Hand anlegen (Debian 12, unprivilegiert, unter *Options → Features* „nesting“ und „keyctl“ an), dann in der Konsole `apt install -y curl && curl -fsSL https://raw.githubusercontent.com/MrCatwiesel/heim-proxy/main/install.sh | bash`.

## 2. Namen (DynDNS)

Jeder Dienst bekommt einen **eigenen Namen**, alle zeigen auf deine Heim-IP. Je nach DynDNS-Anbieter gibt es drei Wege:

| Weg | Beispiel | Geht bei |
| --- | --- | --- |
| **Unternamen der DynDNS-Adresse** (Wildcard) | `reise.meinname.ddnss.de` | z. B. ddnss.de, DuckDNS (`*.meinname.duckdns.org`), dynv6 – Wildcard in der Verwaltung einschalten |
| **Weitere DynDNS-Namen** | `meinname-reise.ddns.net` | jeder Anbieter; jeden Namen im Router-Update eintragen oder als CNAME |
| **Eigene Domain** (ca. 1 €/Monat) | `reise.meinname.de` | beim Domain-Anbieter `*.meinname.de` als **CNAME** auf die DynDNS-Adresse |

Am pflegeleichtesten ist eine eigene Domain mit Wildcard-CNAME. Neue Dienste brauchen dann keine DNS-Änderung mehr.

### Mit GoIP (goip.de)

GoIP vergibt Namen der Form `name.goip.de`. Unternamen wie `reise.name.goip.de` oder eine Wildcard bietet GoIP laut seiner Hilfe nicht an. Dafür kann ein Konto **mehrere Subdomains** haben, und alle lassen sich mit einer einzigen Aktualisierung des Routers auf die neue IP setzen.

1. Bei goip.de anmelden → **weitere Subdomain anlegen** je Dienst, z. B. `name-reise.goip.de`, und sie **demselben Router** zuordnen wie die bisherige.
2. FRITZ!Box → *Internet → Freigaben → DynDNS*:
   - DynDNS-Anbieter: **Benutzerdefiniert**
   - Update-URL (ohne `subdomain`, dann aktualisiert GoIP **alle** Subdomains des Routers auf einmal):
     ```
     https://www.goip.de/setip?username=<username>&password=<pass>&ip=<ipaddr>
     ```
     `<username>`, `<pass>` und `<ipaddr>` genau so stehen lassen, die FRITZ!Box setzt sie ein.
   - Domainname: die bisherige Subdomain (`name.goip.de`), Benutzername und Kennwort von GoIP
3. Nach ein paar Minuten testen: `getent hosts name-reise.goip.de` zeigt dieselbe IP wie `name.goip.de`.

Die bisherige Subdomain kann für die Dienste mit eigenen Portfreigaben weiterlaufen. Neue Webdienste bekommen je eine eigene Subdomain und laufen über den Proxy.

> Später bequemer: eine eigene Domain (ca. 1 €/Monat) mit `*.meinname.de` als CNAME auf `name.goip.de`. Dann braucht ein neuer Dienst keine neue Subdomain mehr bei GoIP.

Allgemein testen (z. B. auf dem Proxmox-Host): `getent hosts reise.meinname.de` muss deine öffentliche IP zeigen.

## 3. Router

Weiterleitungen **auf den Proxy-Container** (FRITZ!Box: Internet → Freigaben → Portfreigaben → Gerät → Neue Freigabe):

| Extern | Intern | Zweck |
| --- | --- | --- |
| TCP 443 | Proxy-IP : 443 | alle Webdienste |
| TCP 80 | Proxy-IP : 80 | Zertifikate (Let's Encrypt) und Umleitung auf https |

**Nicht** weiterleiten: Port 81 (Verwaltung), Datenbank-Server, Proxmox-Oberfläche (8006), SSH.

### Bestehende Weiterleitungen umziehen

Für jeden Webdienst, der bisher einen eigenen Port im Router hatte:

1. Im Proxy einen *Proxy Host* anlegen (Name → interne IP:Port, siehe [NIX-WIE-WEG.md](NIX-WIE-WEG.md) als Beispiel).
2. Prüfen, ob er unter `https://name` erreichbar ist.
3. Die alte Portfreigabe im Router **löschen**.
4. In [DIENSTE.md](DIENSTE.md) eintragen.

Keine Webdienste (Spieleserver, VPN wie WireGuard, Mail) bleiben bei ihrer eigenen Portfreigabe. Der Proxy ist nur für HTTP/HTTPS zuständig.

### IPv4 oder nur IPv6?

In der FRITZ!Box unter *Internet → Online-Monitor* nachsehen: Steht bei IPv4 „DS-Lite“ oder eine Adresse, die mit `100.64.` bis `100.127.` beginnt, ist der Anschluss von außen per IPv4 **nicht** erreichbar. Dann:
- im DynDNS einen **AAAA-Eintrag** mit der IPv6-Adresse des Proxy-Containers setzen und in der FRITZ!Box für den Container eine IPv6-Freigabe (443, 80) anlegen. Das reicht für Handys im Mobilfunk, die fast alle IPv6 haben, oder
- beim Anbieter eine echte IPv4 anfragen (oft kostenlos auf Nachfrage), oder
- einen Tunnel nutzen (z. B. Cloudflare Tunnel). Das ist eine andere Einrichtung und nicht Teil dieses Projekts.

## 4. Weiter

- [SICHERHEIT.md](SICHERHEIT.md): erste Anmeldung
- [NIX-WIE-WEG.md](NIX-WIE-WEG.md): ersten Dienst eintragen
