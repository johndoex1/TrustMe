# TrustMe

![TrustMe](Images/Logo.png)

**TrustMe** se trata de un programa construido en el lenguaje de programación _Bash_, ideal para conseguir credenciales de acceso a una red a través de ataques de tipo Evil Twin.

Algunas consideraciones a tener en cuenta:

* La gestión del AP se hace a través de una sesión **tmux**. Siempre podremos ver la sesión aplicando el comando '_tmux attach -t EvilTwin_'
* Para el correcto funcionamiento del ataque, es necesario elaborar un **DeAuth Attack**, cosa que he decidido no automatizar para prevenir el uso de **Script Kiddies**. Cualquiera que tenga mínimos conocimientos de la utilidad de _aircrack-ng_ sabrá cómo hacerlo.

**Importante:** Es necesario tener instaladas las herramientas _xdotool_, _tmux_ y _aircrack-ng_. Las plantillas son personalizables, pudiendo meter las mismas en el directorio _Plantilla_, posteriormente el programa se encarga de gestionar el servicio web.




