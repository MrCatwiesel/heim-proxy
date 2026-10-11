# Dienst eintragen: Piwigo (Fotogalerie)

Ziel: Piwigo ist statt über `name.goip.de:<Port>` unter einer eigenen Adresse mit HTTPS erreichbar, z. B. **`name-fotos.goip.de`**.

## 1. Name anlegen

Bei GoIP eine weitere Subdomain anlegen, z. B. `name-fotos.goip.de`, und sie demselben Router zuordnen ([EINRICHTUNG.md](EINRICHTUNG.md#mit-goip-goipde)).

## 2. Proxy Host

*Hosts → Proxy Hosts → Add Proxy Host*

| Feld | Wert |
| --- | --- |
| Domain Names | `name-fotos.goip.de` |
| Scheme | `http` |
| Forward Hostname / IP | interne IP des Piwigo-Servers, z. B. `192.168.5.40` |
| Forward Port | Port, auf dem Piwigo **im Heimnetz** läuft (meist `80`, nicht der bisherige Router-Port, falls der umgesetzt war) |
| Block Common Exploits | an |
| Websockets Support | aus |

Reiter **SSL**: *Request a new SSL Certificate*, Force SSL, HTTP/2 und HSTS an.

Reiter **Advanced** (große Fotos beim Hochladen):

```nginx
client_max_body_size 100m;
proxy_request_buffering off;
proxy_read_timeout 300s;
```

Liegt Piwigo in einem Unterordner (z. B. `http://192.168.5.40/piwigo/`): unter *Custom Locations* `/` → `192.168.5.40` und als Pfad `/piwigo/` eintragen. Oder Piwigo direkt auf die oberste Ebene des Webservers legen.

## 3. Piwigo auf HTTPS einstellen

Piwigo erkennt hinter dem Proxy über den Header `X-Forwarded-Proto` selbst, dass es per HTTPS aufgerufen wird. Der Nginx Proxy Manager schickt diesen Header mit.

Zeigen Links oder Bilder trotzdem noch `http://…:Port`:
- Im Piwigo-Admin unter *Konfiguration → Optionen* nach einer fest eingetragenen Adresse sehen.
- Oder in `local/config/config.inc.php` des Piwigo-Servers ergänzen:
  ```php
  <?php
  if (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https') { $_SERVER['HTTPS'] = 'on'; $_SERVER['SERVER_PORT'] = 443; }
  ```

## 4. Upload-Grenze im Piwigo-Server

Für Originalfotos vom Handy, in der `php.ini` des Piwigo-Servers (danach Webserver bzw. PHP-FPM neu starten):

```ini
upload_max_filesize = 50M
post_max_size = 50M
memory_limit = 512M
```

## 5. Testen und alte Freigabe löschen

1. Im Mobilfunk `https://name-fotos.goip.de` öffnen. Die Galerie muss mit Schloss-Symbol erscheinen.
2. Anmelden, ein Foto öffnen und prüfen, ob die Bilder laden.
3. In der FRITZ!Box die **alte Portfreigabe** für Piwigo löschen.
4. In [DIENSTE.md](DIENSTE.md) eintragen.

## 6. Für Nix wie weg

Die Reise-App spricht Piwigo **über ihren Abgleich-Server im Heimnetz** an, nicht über diese öffentliche Adresse. Deshalb braucht es hier keine CORS-Einstellungen. Die öffentliche Adresse dient nur für die Links „In Piwigo öffnen“.

Einrichtung im Projekt *Nix wie weg*: `server/README.md` → „Piwigo anbinden“:
- `NWW_PIWIGO_URL=http://192.168.5.40` (interne Adresse)
- `NWW_PIWIGO_PUBLIC_URL=https://name-fotos.goip.de`
- API-Schlüssel eines Piwigo-Administrators (Piwigo → Profil → API-Schlüssel)
