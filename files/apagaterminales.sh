#!/bin/bash
# Esteban M. Navas
# IES Valle del Jerte - Plasencia
# 03/02/2011
# Última modificación: 27/11/2013

# apagaterminales.sh -> Apaga los terminales de un aula
# El script hace uso de avahi-browse y ssh-keyscan para cumplir con su función.
# Está pensado para ejecutar el comando de apagado tan sólo sobre las máquinas que se detecten encendidas
# pero al mismo tiempo, va construyendo una lista con las ips de las máquinas que se van detectando.
# Hace uso de ssh-keyscan para obtener las claves rsa de los terminales encendidos y añadirlas al fichero 
# /root/.ssh/known_hosts del servidor de terminales.
# Borra los temporales de los usuarios que iniciaron sesión en los terminales y mata sus procesos

# Detectamos los terminales encendidos, tal y como está definido en ldap
avahi-browse -trpk -d local _workstation._tcp 2>/dev/null | grep 192.168.0. | grep -v '_pro\|\-pro'| cut -d";" -f8 > /tmp/terminalesUp

# Obtenemos las claves rsa de los terminales encendidos
ssh-keyscan -t rsa -f /tmp/terminalesUp > /tmp/rsaterminalesUp

# Añadimos las claves rsa de los terminales encendidos al fichero known_host de root del servidor de terminales
sort -o /root/.ssh/known_hosts -m /tmp/rsaterminalesUp /root/.ssh/known_hosts
sort -o /root/.ssh/known_hosts -u /root/.ssh/known_hosts

# Apagamos los terminales 
while read IP
do
   ssh root@$IP -a /sbin/poweroff -fp &
done < /tmp/terminalesUp

# Obtenemos la lista de usuarios que han iniciado sesión en terminales
w | grep '192.168.0' > /tmp/userstoclean

# Borramos temporales y matamos procesos de aquellos usuarios que hayan iniciado sesión en un terminal
while read SESION ; do

   USUARIO=`echo $SESION | cut -f1 -d" "`

   # Borramos los temporales creados en /tmp al iniciar sesión el usuario 
   find /tmp -not -user root -user $USUARIO -exec rm -r {} \; 2>/dev/null

   # Matamos todos los procesos del usuario
   pkill -9 -u $USUARIO
done < /tmp/userstoclean

rm /tmp/userstoclean

