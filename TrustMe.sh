#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

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
}

menu()
{
	echo -e "$yellowColour╱╭╮╱╱╱╱╱╱╱╱╭╮╭━╮╭━╮" && sleep 0.06
	echo -e "╭╯╰╮╱╱╱╱╱╱╭╯╰┫┃╰╯┃┃" && sleep 0.06
	echo -e "╰╮╭╋━┳╮╭┳━┻╮╭┫╭╮╭╮┣━━╮" && sleep 0.06
	echo -e "╱┃┃┃╭┫┃┃┃━━┫┃┃┃┃┃┃┃┃━┫ $endColoue${grayColour}Hecho por Marcelo Vázquez (${endColour}${blueColour}aka s4vitar${endColour}${grayColour})${endColour}$yellowColour" && sleep 0.06
	echo -e "╱┃╰┫┃┃╰╯┣━━┃╰┫┃┃┃┃┃┃━┫" && sleep 0.06
	echo -e "╱╰━┻╯╰━━┻━━┻━┻╯╰╯╰┻━━╯$endColour" && sleep 0.06
	echo -e "$redColour-----------------------$endColour" & sleep 1
	echo -e "${blueColour}1) ${endColour}${grayColour}Iniciar ataque${endColour}" && sleep 0.06
	echo -e "${blueColour}2) ${endColour}${grayColour}Realizar una limpieza${endColour}" && sleep 0.06
	echo -e "${blueColour}0) ${endColour}${grayColour}Salir del programa${endColour}" && sleep 0.06
	echo -e "$redColour-------------------------$endColour" & sleep 1
	echo -ne "${yellowColour}Selecciona una opción:${endColour} " && tput cnorm
	read option && tput civis
}

if [ "$(id -u)" -eq "0" ]; then

	clear && tput civis && sleep 2

	menu

	case $option in

		1) attack
			;;
		0) exit
			;;

	esac

else
	echo -e "${redColour}Es necesario correr el programa como ${endColour}${blueColour}root${endColour}"
fi
