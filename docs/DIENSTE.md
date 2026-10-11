# Dienste hinter dem Proxy

Hier jeden Dienst eintragen, der über den Proxy erreichbar ist. So weißt du auch in einem Jahr noch, was wohin zeigt.

| Name (extern) | Ziel (intern) | Container / VM | Zugriff | Notiz |
| --- | --- | --- | --- | --- |
| `reise.meinname.de` | `http://192.168.178.50:8787` | CT nix-wie-weg | öffentlich (Schlüssel in der App) | Upload 40 MB, siehe [NIX-WIE-WEG.md](NIX-WIE-WEG.md) |
| `name-fotos.goip.de` | `http://<Piwigo-IP>:80` | Piwigo | öffentlich (Piwigo-Login) | Upload 100 MB, siehe [PIWIGO.md](PIWIGO.md) |
|  |  |  |  |  |

## Nicht über den Proxy (eigene Portfreigabe oder nur intern)

| Dienst | Port | Erreichbar | Notiz |
| --- | --- | --- | --- |
| Proxy-Verwaltung | 81 | nur Heimnetz | |
| Datenbank-Server |  | nur Heimnetz | nie freigeben |
| Proxmox | 8006 | nur Heimnetz / VPN | |
