puppet-apagado-terminales
=========================

Módulo puppet para instalar scripts que apagan los terminales al apagar, reiniciar o cerrar sesión en el servidor LTSP

BREVE DESCRIPCION DE LA EJECUCION DEL MODULO
--------------------------------------------

Destino: Servidores de aula.

Acción:   * Copia el script apagaterminales.sh con permisos 750 a /usr/sbin
   	  * Instala el paquete dsh, necesarios para que el script funcione.
   	  * Crea las claves pública y privada de root en cada servidor de terminales, 
            si no han sido creadas aún, dejando vacía la "passphrase".
	  * Añade la clave pública de root en el servidor de terminales (/root/.ssh/id_rsa.pub)
	    al fichero authorized_keys de la imagen de los terminales y regenera la imagen.
	  * Añade la llamada al script apagaterminales.sh al fichero /etc/gdm/PostSession/Default
	    para que los terminales de alumno se apagen cuando el profesor cierre la sesión.
	  * Añade un script de inicio llamado "halt-terminales" a /etc/init.d y crea dos enlaces en:
            /etc/rc0.d/K01aapaga-terminales y /etc/rc6.d/K01aapaga-terminales para apagar los terminales
            cuando se apague o reinicie el servidor.

Función:  * apagaterminales.sh -> Apaga los terminales de un aula
	  * El script hace uso de dsh y ssh-keyscan para cumplir con su función.
	  * Está pensado para ejecutar el comando de apagado tan sólo sobre las máquinas que se detecten encendidas
	  * pero al mismo tiempo, va construyendo una lista con las ips de los terminales que se van detectando en cada uso.
	  * Hace uso de ssh-keyscan para obtener las claves rsa de los terminales encendidos y añadirlas al fichero 
	    /root/.ssh/known_hosts del servidor de terminales. 

Notas:    El script apagaterminales.sh se ejecuta:
          * Cuando el profesor cierra la sesión.
          * Cuando se reinicia el servidor de terminales.
          * Cuando se apaga el servidor de terminales.

IMPORTANTE: Incluir el paquete dsh en el fichero mayhave del ltspserver:
            /etc/puppet/files/mayhave.ltspserver
            

INSTRUCCIONES DE INSTALACION DEL MODULO
---------------------------------------

1) Desempaquetar en /etc/puppet/modules

2) Incluir la linea include "nombre_modulo" en /etc/puppet/manifests/classes/clase-especifica.pp

------------------------------------------------


Creado por:

Esteban M. Navas Martín
Administrador informático 
IES Valle del Jerte
Plasencia
03-Febrero-2011
