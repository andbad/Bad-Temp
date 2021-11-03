#!/bin/bash
VER="3.43"

# Reset
CO='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

DELAY=2
TMOUT=1
TMAXCPU=75
TMAXHD=34
FSBBASE=400
LOOP=2                    #Default 2
ETHNAME=enp1s0		  #Il nome della scheda di rete (ricavare da ifconfig)
GPUS=0                    #Default 1
RAIDS=1                   #Default 1
HDS=1                     #Default 1
MEMS=1                    #Default 1
CPUS=1                    #Default 1
SENSORSS=1                #Default 1
ETHS=1                    #Default 1
TIMES=1                   #Default 1

for i in $@; do
  case $i in
       -l|--loop)
            LOOP=0       #Se si passa il parametro -l, viene eseguito una volta, poi esce. Di default va in loop.
       ;;
       -g|--gpu)
            GPUS=0       #Disattiva la gestione della GPU
       ;;
       -r|--raid)
            RAIDS=0      #Disattiva la gestione del RAID
       ;;
       -d|--disk)
            HDS=0        #Disattiva la gestione dei dischi
       ;;
       -m|--memory)
            MEMS=0       #Disattiva la gestione della memoria
       ;;
       -c|--cpu)
            CPUS=0       #Disattiva la gestione della CPU
       ;;
       -s|--sensors)
            SENSORSS=0   #Disattiva la gestione dei sensori di temperatura e voltaggio
       ;;
       -e|--ethernet)
            ETHS=0       #Disattiva la gestione della scheda ETH
       ;;
       -t|--time)
            TIMES=0       #Disattiva la visualizzazione di data/ora e uptime
       ;;
       -h|--help)
		echo ""
		echo "Uso: temp.sh [OPZIONE]..."
		echo "Mostra informazioni sull'hardware e sulle prestazioni utilizzando le seguenti utility (che devono essere installate manualmente nel sistema):"
		echo "date, uptime, ifconfig, ethtool, ifstat, sensors, mpstat, dmidecode, hddtemp, smartctl, free, iostat, mdadm, nvidia-smi."
		echo ""
                echo "--------------------------------------------------"
		echo ""
		echo "Aggiungere l'alias seguente:"
		echo ""
		echo "echo \"alias temp='/home/username/temp.sh 2> /dev/null'\" >> ~/.bash_aliases"
		echo "source ~/.bashrc"
		echo ""
                echo "--------------------------------------------------"
		echo ""
                echo "Per evitare la richiesta di password di root all'avvio, aggiungere le seguenti righe al file sudoers (sudo visudo)"
                echo "username ALL=NOPASSWD: /sbin/ethtool"
                echo "usernane ALL=NOPASSWD: /usr/sbin/dmidecode"
                echo "username ALL=NOPASSWD: /usr/sbin/hddtemp"
                echo "username ALL=NOPASSWD: /usr/sbin/smartctl"
                echo "username ALL=NOPASSWD: /sbin/mdadm"
                echo "username ALL=NOPASSWD: /usr/bin/iostat"
                echo "username ALL=NOPASSWD: /usr/bin/iotop"
                echo "username ALL=NOPASSWD: /usr/sbin/iftop"
                echo "username ALL=NOPASSWD: /usr/bin/htop"
                echo "username ALL=NOPASSWD: /usr/bin/atop"
		echo ""
                echo "--------------------------------------------------"
		echo ""
		echo "Opzioni:"
		echo "-l, --loop      Esegue lo script una volta sola ed esce (di default viene eseguito in loop)."
		echo "-g, -- gpu      Disattiva la visualizzazione della info sulla GPU"
		echo "-r, --raid      Disattiva la visualizzazione della info sui RAID"
		echo "-d, --disk      Disattiva la visualizzazione della info sui dischi"
		echo "-m, --memory    Disattiva la visualizzazione della info sulla memoria"
		echo "-c, --cpu       Disattiva la visualizzazione della info sulla/e CPU"
		echo "-s, --sensors   Disattiva la visualizzazione della info sui sensori di temperatura e voltaggio"
		echo "-e, --ethernet  Disattiva la visualizzazione della info sulla scheda Ethernet"
		echo "-t, --time      Disattiva la visualizzazione di data/ora e uptime"
		echo ""
		exit
       ;;
  esac
done
rm /tmp/traffic.tmp
rm /tmp/raid.tmp

cat <<EOF > /tmp/traffic.tmp
0
0
0
EOF

cat <<EOF > /tmp/raid.tmp
0
0
EOF

HD0SMART="Load.."
HD1SMART="Load.."
HD2SMART="Load.."
HD3SMART="Load.."
HD4SMART="Load.."
HD5SMART="Load.."

for ((j=$LOOP; j!=1; j++))
do
	sleep $DELAY
	command=""
	if [ $TIMES -gt 0 ]
	then
		DATE=$( date +"%a %d/%m/%y, %H.%M.%S")
		UPTIMEO=$(uptime -p | cut -c3-25)
		SIZEUPTIME=${#UPTIMEO}
		SPACE=$[ 29-$SIZEUPTIME ]
		SPACE=$[ $SPACE/2 ]
		UPTIME=""
		for ((i = 0; i < $SPACE; i++))
		do
		   UPTIME=$(echo -e " $UPTIME")
		done
		SPACE=$[ 29-$SIZEUPTIME ]
		SPACE=$[$SPACE%2]
		if [ $SPACE -eq 0 ]
		then
		 UPTIME=$(echo -e "$UPTIME$UPTIMEO$UPTIME")
		else
		 UPTIME=$(echo -e " $UPTIME$UPTIMEO$UPTIME")
		fi
	fi

	if [ $ETHS -gt 0 ]
	then
		PING=$(ping 8.8.8.8 -c 1 | tail -n 1 | cut -d "/" -f4 | cut -d"=" -f2 | cut -d" " -f2 | cut -d"." -f1)
                if [ $PING -lt 100 ]
                then
                 if [ $PING -lt 10 ]
                 then
                  PING=$(echo "  $PING")
                 else
                  PING=$(echo " $PING")
                 fi
                fi
                if [ ${PING} -gt 50 ]
                then
                        PING=$(echo "$BRed$PING"$CO)
                fi

		readarray TRAFFIC < /tmp/traffic.tmp
		if [ ${TRAFFIC[0]} -eq 0 ]
	        then
                        TRANSFERRED=$(ifconfig $ETHNAME)
                        ETH=$(sudo ethtool $ETHNAME)
        	        if [ $LOOP -eq 0 ]
			then
				/home/andbad/traffic.sh $ETHNAME
				readarray TRAFFIC < /tmp/traffic.tmp
			else
				/home/andbad/traffic.sh $ETHNAME &
			fi

                        UP=${TRAFFIC[1]}
                        if [ $UP -lt 10000 ]
                        then
                                if [ $UP -lt 1000 ]
                                then
                                        if [ $UP -lt 100 ]
                                        then
                                                if [ $UP -lt 10 ]
                                                then
                                                        UP=$(echo "    $UP")
                                                else
                                                        UP=$(echo "   $UP")
                                                fi
                                        else
                                                UP=$(echo "  $UP")
                                        fi
                                else
                                        UP=$(echo -n " $UP")
                                fi
                        else
                                UP=$(echo -n "$UP")
                        fi

	                DOWN=${TRAFFIC[2]}
			if [ $DOWN -lt 10000 ]
			then
				if [ $DOWN -lt 1000 ]
				then
					if [ $DOWN -lt 100 ]
					then
						if [ $DOWN -lt 10 ]
						then
							DOWN=$(echo "    $DOWN")
						else
							DOWN=$(echo "   $DOWN")
						fi
				 	else
				  		DOWN=$(echo "  $DOWN")
					fi
				else
					DOWN=$(echo -n " $DOWN")
				fi
			else
				DOWN=$(echo -n "$DOWN")
			fi


			TOTUPD=$(echo "$TRANSFERRED" | tail -n5 | awk '/RX p/ && $1 ~ /[A-Z]/ {print $6}'|cut -d"(" -f2 | cut -d" " -f1 | cut -d "." -f2)
			TOTUPKMG=$(echo "$TRANSFERRED" | tail -n5 | awk '/RX p/ && $1 ~ /[A-Z]/ {print $7}' | cut -d")" -f1)
			TOTUP=$(echo "$TRANSFERRED" | tail -n5 | awk '/RX p/ && $1 ~ /[A-Z]/ {print $6}'|cut -d"(" -f2 | cut -d "." -f1)
			if [ $TOTUP -lt 1000 ]
			then
			 if [ $TOTUP -lt 100 ]
			 then
			  if [ $TOTUP -lt 10 ]
			  then
			   TOTUP=$(echo "   $TOTUP")
			  else
			   TOTUP=$(echo "  $TOTUP")
			  fi
			  else
			  TOTUP=$(echo " $TOTUP")
			 fi
			fi

			TOTDOWND=$(echo "$TRANSFERRED" | tail -n5 | awk '/TX p/ && $1 ~ /[A-Z]/ {print $6}'|cut -d"(" -f2 | cut -d" " -f1 | cut -d "." -f2)
			TOTDOWNKMG=$(echo "$TRANSFERRED" | tail -n2 | awk '/TX p/ && $1 ~ /[A-Z]/ {print $7}' | cut -d")" -f1)
			TOTDOWN=$(echo "$TRANSFERRED" | tail -n2 | awk '/TX p/ && $1 ~ /[A-Z]/ {print $6}'|cut -d"(" -f2 | cut -d "." -f1)
			if [ $TOTDOWN -lt 1000 ]
			then
			 if [ $TOTDOWN -lt 100 ]
			 then
			  if [ $TOTDOWN -lt 10 ]
				  then
			   TOTDOWN=$(echo "   $TOTDOWN")
			  else
			   TOTDOWN=$(echo "  $TOTDOWN")
			  fi
			  else
			  TOTDOWN=$(echo " $TOTDOWN")
			 fi
			fi

			ETHSPEED=$(echo "$ETH" | grep Speed | awk '/Speed/ && $1 ~ /[A-Z]/ {print $2}')
			case $ETHSPEED in
			 1000Mb/s)
			  ETHSPEED="  1Gbit "
			  ;;
			 100Mb/s)
			  ETHSPEED="100Mbit "
			  ;;
			 10Mb/s)
			  ETHSPEED=" 10Mbit "
			  ;;
			esac
		fi
	fi
	if [ $SENSORSS -gt 0 ]
	then
		SENSORS=$(sensors)

		CPU0=$(echo -e "$SENSORS" | awk '/Core 0:/ && $2 ~ /[0-9]/ {print $3}'| cut -d "+" -f 2|cut -d "." -f 1)
		if [ $CPU0 -gt $TMAXCPU ]
		then
		 CPU0=$BRed$CPU0$CO
		fi

		CPU1=$(echo -e "$SENSORS" | awk '/Core 1:/ && $2 ~ /[0-9]/ {print $3}'| cut -d "+" -f 2|cut -d "." -f 1)
		if [ $CPU1 -gt $TMAXCPU ]
		then
		 CPU1=$BRed$CPU1$CO
		fi

		CPU2=$(echo -e "$SENSORS" | awk '/Core 2:/ && $2 ~ /[0-9]/ {print $3}'| cut -d "+" -f 2|cut -d "." -f 1)
		if [ $CPU2 -gt $TMAXCPU ]
		then
		 CPU2=$BRed$CPU2$CO
		fi

		CPU3=$(echo -e "$SENSORS" | awk '/Core 3:/ && $2 ~ /[0-9]/ {print $3}'| cut -d "+" -f 2|cut -d "." -f 1)
		if [ $CPU3 -gt $TMAXCPU ]
		then
		 CPU3=$BRed$CPU3$CO
		fi

		MB=$(echo -e "$SENSORS" | awk '/MB/ && $2 ~ /[A-Z]/ {print $3}'| cut -d "+" -f 2|cut -d "." -f 1)

		CPUFAN=$(echo -e "$SENSORS" | awk '/CPU FAN/ && $2 ~ /[A-Z]/ {print $4}'| cut -d "+" -f 2|cut -d "." -f 1)
		if [ $CPUFAN -lt 1000 ]
		then
		 if [ $CPUFAN -lt 100 ]
		 then
		  if [ $CPUFAN -lt 10 ]
		  then
		   CPUFAN=$(echo "   $CPUFAN")
		  else
		   CPUFAN=$(echo "  $CPUFAN")
		  fi
		  else
		  CPUFAN=$(echo " $CPUFAN")
		 fi
		fi

		CASEFAN=$(echo -e "$SENSORS" | awk '/CHASSIS/ && $2 ~ /[A-Z]/ {print $4}' | cut -d "+" -f 2|cut -d "." -f 1)
                if [ -z $CASEFAN ]
                then
                        CASEFAN=0
                fi
	        if [ $CASEFAN -lt 100000 ]
                then
 		 if [ $CASEFAN -lt 10000 ]
                 then
                  if [ $CASEFAN -lt 1000 ]
		  then
		   if [ $CASEFAN -lt 100 ]
		   then
		    if [ $CASEFAN -lt 10 ]
		    then
		     CASEFAN=$(echo "     $CASEFAN")
		    else
		     CASEFAN=$(echo "    $CASEFAN")
		    fi
		   else
		   CASEFAN=$(echo "   $CASEFAN")
		   fi
                  else
		  CASEFAN=$(echo "  $CASEFAN")
  		  fi
		  else
 		  CASEFAN=$(echo " $CASEFAN")
		  fi
                 fi

		POWERFAN=$(echo -e "$SENSORS" | awk '/POWER FAN/ && $2 ~ /[A-Z]/ {print $4}'| cut -d "+" -f 2|cut -d "." -f 1)
		if [ -z $POWERFAN ]
		then
			POWERFAN=0
		fi
                if [ $POWERFAN -lt 10000 ]
                then
                 if [ $POWERFAN -lt 1000 ]
                 then
                  if [ $POWERFAN -lt 100 ]
                  then
                   if [ $POWERFAN -lt 10 ]
                   then
                    POWERFAN=$(echo "   $POWERFAN")
                   else
                    POWERFAN=$(echo "  $POWERFAN")
                   fi
                  else
                  POWERFAN=$(echo " $POWERFAN")
                  fi
                 else
                 POWERFAN=$(echo "$POWERFAN")
                 fi
                fi


		VCORE=$(echo -e "$SENSORS" | awk '/Vcore/ && $2 ~ /[A-Z]/ {print $3$4}' | awk -F '.00' ' {print $1$2}')
		V33=$(echo -e "$SENSORS" | awk '/+3.3/ && $2 ~ /[A-Z]/ {print $3$4}'| awk -F '.00' ' {print $1$2}')
		V5=$(echo -e "$SENSORS" | awk '/+5 V/ && $2 ~ /[A-Z]/ {print $3$4}'| awk -F '.00' ' {print $1$2}')
		V12=$(echo -e "$SENSORS" | awk '/+12/ && $2 ~ /[A-Z]/ {print $3$4}'| awk -F '.00' ' {print $1$2}')

	fi

	if [ $CPUS -gt 0 ]
	then
		CPUINFO=$(cat /proc/cpuinfo)
		GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
		LOADS=($(mpstat -P ALL 1 1 | awk '/Media:/ && $2 ~ /[0-9]/ {print $12}'| cut -d "," -f 1))
		FSB=$(sudo dmidecode -t 4 | grep External | awk '/External/ && $2 ~ /[A-Z]/ {print $3}')
		case $GOVERNOR in
		 powersave)
		  GOVERNOR="    $Green$GOVERNOR$CO    "
		  ;;
		 conservative)
		  GOVERNOR="   $Green$GOVERNOR$CO  "
		  ;;
		 ondemand)
		  GOVERNOR="     $Yellow$GOVERNOR$CO    "
		  ;;
		 performance)
		  GOVERNOR="   $BRed$GOVERNOR$CO   "
		  ;;
		 userspace)
                  GOVERNOR="    $BYellow$GOVERNOR$CO    "


		esac

		SPEED0=$(echo -e "$CPUINFO" | awk '/cpu MHz/ && $2 ~ /[A-Z]/ {print $4}' | sed "1q;d" | cut -d "." -f1)
		SPEED1=$(echo -e "$CPUINFO" | awk '/cpu MHz/ && $2 ~ /[A-Z]/ {print $4}' | sed "2q;d" | cut -d "." -f1)
		SPEED2=$(echo -e "$CPUINFO" | awk '/cpu MHz/ && $2 ~ /[A-Z]/ {print $4}' | sed "3q;d" | cut -d "." -f1)
		SPEED3=$(echo -e "$CPUINFO" | awk '/cpu MHz/ && $2 ~ /[A-Z]/ {print $4}' | sed "4q;d" | cut -d "." -f1)

		#SPEED0=$[SPEED0/FSBBASE*FSB]
		#SPEED1=$[SPEED1/FSBBASE*FSB]
		#SPEED2=$[SPEED2/FSBBASE*FSB]
		#SPEED3=$[SPEED3/FSBBASE*FSB]

		LOAD0=$[100-${LOADS[0]}]
		if [ $LOAD0 -lt 100 ]
		then
		 if [ $LOAD0 -lt 10 ]
		 then
		  LOAD0=$(echo "  $LOAD0")
		 else
		  LOAD0=$(echo " $LOAD0")
		 fi
		fi
                if [ ${LOADS[0]} -lt 10 ]
                then
                        LOAD0=$(echo "$BRed$LOAD0"$CO)
                fi

		LOAD1=$[100-${LOADS[1]}]
		if [ $LOAD1 -lt 100 ]
		then
		 if [ $LOAD1 -lt 10 ]
		 then
		  LOAD1=$(echo "  $LOAD1")
		 else
		  LOAD1=$(echo " $LOAD1")
		 fi
		fi
		if [ ${LOADS[1]} -lt 10 ]
		then
			LOAD1=$(echo "$BRed$LOAD1"$CO)
		fi

		LOAD2=$[100-${LOADS[2]}]
		if [ $LOAD2 -lt 100 ]
		then
		 if [ $LOAD2 -lt 10 ]
		 then
		  LOAD2=$(echo "  $LOAD2")
		 else
		  LOAD2=$(echo " $LOAD2")
		 fi
		fi
                if [ ${LOADS[2]} -lt 10 ]
                then
                        LOAD2=$(echo "$BRed$LOAD2"$CO)
                fi

		LOAD3=$[100-${LOADS[3]}]
		if [ $LOAD3 -lt 100 ]
		then
		 if [ $LOAD3 -lt 10 ]
		 then
		  LOAD3=$(echo "  $LOAD3")
		 else
		  LOAD3=$(echo " $LOAD3")
		 fi
		fi
                if [ ${LOADS[3]} -lt 10 ]
                then
                        LOAD3=$(echo "$BRed$LOAD3"$CO)
                fi

	fi

	if [ $HDS -gt 0 ]
	then
		HD0TEMP=$(sudo hddtemp --debug /dev/sda | grep "field(190)" | cut -f 2 | cut -c 4,5)
		if [ -z $HD0TEMP ]
		then
			HD0TEMP=0
		fi
		if [ "$HD0TEMP" = "0" ]
		then
		 HD0TEMP=" 0"
		else
		 if [ $HD0TEMP -gt $TMAXHD ]
		 then
		  HD0TEMP=$(echo "$BRed$HD0TEMP"$CO)
		 fi
		fi


		HD1TEMP=$(sudo hddtemp --debug /dev/sdb | grep "field(194)" | cut -f 2 | cut -c 4,5)
		if [ -z $HD1TEMP ]
		then
			HD1TEMP=0
		fi
		if [ "$HD1TEMP" = "0" ]
		then
		 HD1TEMP=" 0"
		else
		 if [ $HD1TEMP -gt $TMAXHD ]
		 then
		  HD1TEMP=$(echo "$BRed$HD1TEMP"$CO)
		 fi
		fi

                HD2TEMP=$(sudo hddtemp --debug /dev/sdd | grep "field(194)" | cut -f 2 | cut -c 4,5)
		if [ -z $HD2TEMP ]
		then
			HD2TEMP=0
		fi
		if [ "$HD2TEMP" = "0" ]
		then
		 HD2TEMP=" 0"
		else
		 if [ $HD2TEMP -gt $TMAXHD ]
		 then
		  HD2TEMP=$(echo "$BRed$HD2TEMP"$CO)
		 fi
		fi

                HD3TEMP=$(sudo hddtemp --debug /dev/sde | grep "field(194)" | cut -f 2 | cut -c 4,5)
		if [ -z $HD3TEMP ]
		then
			HD3TEMP=0
		fi
		if [ "$HD3TEMP" = "0" ]
		then
		 HD3TEMP=" 0"
		else
		 if [ $HD3TEMP -gt $TMAXHD ]
		 then
		  HD3TEMP=$(echo "$BRed$HD3TEMP"$CO)
		 fi
		fi

                HD4TEMP=$(sudo hddtemp --debug /dev/sdf | grep "field(194)" | cut -f 2 | cut -c 4,5)
                if [ -z $HD4TEMP ]
                then
                        HD4TEMP=0
                fi
                if [ "$HD4TEMP" = "0" ]
                then
                 HD4TEMP=" 0"
                else
                 if [ $HD4TEMP -gt $TMAXHD ]
                 then
                  HD4TEMP=$(echo "$BRed$HD4TEMP"$CO)
                 fi
                fi

                HD5TEMP=$(sudo hddtemp --debug /dev/sdg | grep "field(194)" | cut -f 2 | cut -c 4,5)
                if [ -z $HD5TEMP ]
                then
                        HD5TEMP=0
                fi
                if [ "$HD5TEMP" = "0" ]
                then
                 HD5TEMP=" 0"
                else
                 if [ $HD5TEMP -gt $TMAXHD ]
                 then
                  HD5TEMP=$(echo "$BRed$HD5TEMP"$CO)
                 fi
                fi

		DATA=$(date +"%S" | cut -c1)
		if [ $LOOP -eq 0 ]
		then
			DATA=0
		fi
		if [ $DATA -eq 0 ]
		then
			HD0SMART=$(sudo smartctl -H /dev/sda 2>/dev/null | grep self | cut -c51- )
			if [ -z "$HD0SMART" ]
			then
			 HD0SMART="  na  "
			elif  [ "$HD0SMART" != "PASSED" ]
			then
			 HD0SMART=$BRed$HD0SMART$CO
			fi

			HD1SMART=$(sudo smartctl -H /dev/sdb 2>/dev/null | grep self | cut -c51-)
			if [ -z "$HD1SMART" ]
			then
			 HD1SMART="  na  "
				elif  [ "$HD1SMART" != "PASSED" ]
			then
			 HD1SMART=$BRed$HD1SMART$CO
			fi

			HD2SMART=$(sudo smartctl -H /dev/sdd 2>/dev/null | grep self | cut -c51-)
			if [ -z "$HD2SMART" ]
			then
				 HD2SMART="  na  "
			elif  [ "$HD2SMART" != "PASSED" ]
			then
				 HD2SMART=$BRed$HD2SMART$CO
			fi

			HD3SMART=$(sudo smartctl -H /dev/sde 2>/dev/null | grep self | cut -c51-)
			if [ -z "$HD3SMART" ]
			then
			 HD3SMART="  na  "
			elif  [ "$HD3SMART" != "PASSED" ]
			then
			 HD3SMART=$BRed$HD3SMART$CO
			fi

                        HD4SMART=$(sudo smartctl -H /dev/sdf 2>/dev/null | grep self | cut -c51-)
                        if [ -z "$HD4SMART" ]
                        then
                         HD4SMART="  na  "
                        elif  [ "$HD4SMART" != "PASSED" ]
                        then
                         HD4SMART=$BRed$HD4SMART$CO
                        fi

                        HD5SMART=$(sudo smartctl -H /dev/sdg 2>/dev/null | grep self | cut -c51-)
                        if [ -z "$HD5SMART" ]
                        then
                         HD5SMART="  na  "
                        elif  [ "$HD5SMART" != "PASSED" ]
                        then
                         HD5SMART=$BRed$HD5SMART$CO
                        fi

		fi
	fi

	if [ $MEMS -gt 0 ]
	then
		MEM=$(free -w)
		MEMSPEED=$(sudo dmidecode -t 17 2>/dev/null | grep "Speed: " | tail -n 1 | awk '/Speed:/ && $2 ~ /[0-9]/ {print $2}')
		MEMTOTAL=($(echo "$MEM"| awk '/Mem:/ && $2 ~ /[0-9]/ {print $2}'))
		MEMTOTAL=$[$MEMTOTAL/1024]
		if [ $MEMTOTAL -lt 1000 ]
		then
		 if [ $MEMTOTAL -lt 100 ]
		 then
		  if [ $MEMTOTAL -lt 10 ]  
		  then
		   MEMTOTAL=$(echo "   $MEMTOTAL")
		  else
		   MEMTOTAL=$(echo "  $MEMTOTAL")
		  fi
		  else
		  MEMTOTAL=$(echo " $MEMTOTAL")
		 fi
		fi


		MEMUSED=($(echo "$MEM"| awk '/Mem:/ && $2 ~ /[0-9]/ {print $3}'))
		MEMUSED=$[$MEMUSED/1024]
		if [ $MEMUSED -lt 1000 ]
		then
		 if [ $MEMUSED -lt 100 ]
		 then
		  if [ $MEMUSED -lt 10 ] 
		  then
		   MEMUSED=$(echo "   $MEMUSED")
		  else
		   MEMUSED=$(echo "  $MEMUSED")
		  fi
		  else
		  MEMUSED=$(echo " $MEMUSED")
		 fi
		fi

		MEMAVAL=($(echo "$MEM"| awk '/Mem:/ && $2 ~ /[0-9]/ {print $8}'))
		MEMAVAL=$[$MEMAVAL/1024]
		if [ $MEMAVAL -lt 1000 ]
		then
		 if [ $MEMAVAL -lt 100 ]
		 then
		  if [ $MEMAVAL -lt 10 ]  
		  then

		   MEMAVAL=$(echo "   $MEMAVAL")
		  else
		   MEMAVAL=$(echo "  $MEMAVAL")
		  fi
		  else
		  MEMAVAL=$(echo " $MEMAVAL")
		 fi
		fi
		MEMPERCT=($(echo "$MEM"| awk '/Mem:/ && $2 ~ /[0-9]/ {print $2}'))
		MEMPERCA=($(echo "$MEM"| awk '/Mem:/ && $2 ~ /[0-9]/ {print $8}'))
		MEMPERC=$[ $MEMPERCA * 100 / $MEMPERCT ]
		if [ $MEMPERC -lt 100 ]
		then
		 if [ $MEMPERC -lt 10 ]  
		 then
		  MEMPERC=$(echo "  $Bred$MEMPERC$CO")
		 else
		  MEMPERC=$(echo " $MEMPERC")
		 fi
		 else
		 MEMPERC=$(echo $BRed$MEMPERC$CO)
		fi

		SWAPTOTAL=($(echo "$MEM"| awk '/Swap:/ && $2 ~ /[0-9]/ {print $2}'))
		SWAPTOTAL=$[$SWAPTOTAL/1024]
		if [ $SWAPTOTAL -lt 1000 ]
		then
		 if [ $SWAPTOTAL -lt 100 ]
		 then
		  if [ $SWAPTOTAL -lt 10 ]  
		  then
		   SWAPTOTAL=$(echo "   $SWAPTOTAL")
		  else
		   SWAPTOTAL=$(echo "  $SWAPTOTAL")
		  fi
		  else
		  SWAPTOTAL=$(echo " $SWAPTOTAL")
		 fi
		fi


		SWAPUSED=($(echo "$MEM"| awk '/Swap:/ && $2 ~ /[0-9]/ {print $3}'))
		SWAPUSED=$[$SWAPUSED/1024]
		if [ $SWAPUSED -lt 1000 ]
		then
		 if [ $SWAPUSED -lt 100 ]
		 then
		  if [ $SWAPUSED -lt 10 ]  
		  then
		   SWAPUSED=$(echo "   $SWAPUSED")
		  else
		   SWAPUSED=$(echo "  $SWAPUSED")
		  fi
		  else
		  SWAPUSED=$(echo " $SWAPUSED")
		 fi
		fi

		SWAPAVAL=($(echo "$MEM"| awk '/Swap:/ && $2 ~ /[0-9]/ {print $4}'))
		SWAPAVAL=$[$SWAPAVAL/1024]
		if [ $SWAPAVAL -lt 1000 ]
		then
		 if [ $SWAPAVAL -lt 100 ]
		 then
		  if [ $SWAPAVAL -lt 10 ]  
		  then
		   SWAPAVAL=$(echo "   $SWAPAVAL")
		  else
		   SWAPAVAL=$(echo "  $SWAPAVAL")
		  fi
		  else
		  SWAPAVAL=$(echo " $SWAPAVAL")
		 fi
		fi
		SWAPPERCT=($(echo "$MEM"| awk '/Swap:/ && $2 ~ /[0-9]/ {print $2}'))
		SWAPPERCA=($(echo "$MEM"| awk '/Swap:/ && $2 ~ /[0-9]/ {print $4}'))
		SWAPPERC=$[ $SWAPPERCA * 100 / $SWAPPERCT ]
		if [ $SWAPPERC -lt 100 ]
		then
		 if [ $SWAPPERC -lt 10 ]  
		 then
		  SWAPPERC=$(echo "  $BRed$SWAPPERC$CO")
		 else
		  SWAPPERC=$(echo " $SWAPPERC")
		 fi
		fi
	fi

	if [ $RAIDS -gt 0 ]
	then
		readarray RAID < /tmp/raid.tmp
		if [ ${RAID[0]} -eq 0 ]
                then
			if [ $LOOP -eq 0 ]
			then
				/home/andbad/raid.sh
			else
				/home/andbad/raid.sh &
			fi

			IOSTATSDA=${RAID[2]}
                        IOSTATMD2=${RAID[4]}

			#echo -e "0, "${RAID[0]}
                        #echo -e "1, "${RAID[1]}
                        #echo -e "2, "${RAID[2]}
                        #echo -e "3, "${RAID[3]}
                        #echo -e "4, "${RAID[4]}

			RAID2=$(sudo mdadm --detail /dev/md2 2>/dev/null)
	                SIZE=$(df)

			MD2STATE=$(echo "$RAID2" | awk '/State :/ && $1 ~ /[A-Z]/ {print $3}' )
			if [ "$MD2STATE" = "clean" ]
			then
			 MD2STATE=" clean"
			elif [ "$MD2STATE" != "active" ]
			then
			 MD2STATE=$BRed"ALERT!"$CO
			fi

			MD2LEVEL=$(echo "$RAID2" | awk '/Level :/ && $1 ~ /[A-Z]/ {print $4}')
			MD2SIZE=$(echo "$SIZE" | awk '/md2/ && $1 ~ /[1-9]/ {print $2}')
			if [ -z $MD2SIZE ]
			then
				MD2SIZE=0
			fi
			MD2SIZE=$[ $MD2SIZE / 1024 / 1024 ]
			if [ $MD2SIZE -lt 1000 ]
			then
			 if [ $MD2SIZE -lt 100 ]
			 then
			  if [ $MD2SIZE -lt 10 ]  
			  then
			   MD2SIZE=$(echo "   $MD2SIZE")
			  else
			   MD2SIZE=$(echo "  $MD2SIZE")
			  fi
			  else
			  MD2SIZE=$(echo " $MD2SIZE")
			 fi
			fi

                       SDASIZE=$(echo "$SIZE" | awk '/sda2/ && $1 ~ /[1-9]/ {print $2}')
                        if [ -z $SDASIZE ]
                        then
                                SDASIZE=0
                        fi
                        SDASIZE=$[ $SDASIZE / 1024 / 1024 ]
                        if [ $SDASIZE -lt 1000 ]
                        then
                         if [ $SDASIZE -lt 100 ]
                         then
                          if [ $SDASIZE -lt 10 ]  
                          then
                           SDASIZE=$(echo "   $SDASIZE")
                          else
                           SDASIZE=$(echo "  $SDASIZE")
                          fi
                          else
                          SDASIZE=$(echo " $SDASIZE")
                         fi
                        fi

			MD2USED=$(echo "$SIZE" | awk '/md2/ && $1 ~ /[1-9]/ {print $3}')
			if [ -z $MD2USED ]
			then
				MD2USED=0
			fi
			MD2USED=$[ $MD2USED / 1024 / 1024 ]
			if [ $MD2USED -lt 1000 ]
			then
			 if [ $MD2USED -lt 100 ]
			 then
			  if [ $MD2USED -lt 10 ]  
			  then
			   MD2USED=$(echo "   $MD2USED")
			  else
			   MD2USED=$(echo "  $MD2USED")
			  fi
			  else
			  MD2USED=$(echo " $MD2USED")
			 fi
			fi

			SDAUSED=$(echo "$SIZE" | awk '/sda2/ && $1 ~ /[1-9]/ {print $3}')
                        if [ -z $SDAUSED ]
                        then
                                SDAUSED=0
                        fi
                        SDAUSED=$[ $SDAUSED / 1024 / 1024 ]
                        if [ $SDAUSED -lt 1000 ]
                        then
                         if [ $SDAUSED -lt 100 ]
                         then
                          if [ $SDAUSED -lt 10 ]  
                          then
                           SDAUSED=$(echo "   $SDAUSED")
                          else
                           SDAUSED=$(echo "  $SDAUSED")
                          fi
                          else
                          SDAUSED=$(echo " $SDAUSED")
                         fi
                        fi


			MD2FREE=$(echo "$SIZE" | awk '/md2/ && $1 ~ /[1-9]/ {print $4}')
			if [ -z $MD2FREE ]
			then
				MD2FREE=0
			fi
			MD2FREE=$[ $MD2FREE / 1024 / 1024 ]
			if [ $MD2FREE -lt 1000 ]
			then
			 if [ $MD2FREE -lt 100 ]
			 then
			  if [ $MD2FREE -lt 10 ]  
			  then
			   MD2FREE=$(echo "   $MD2FREE")
			  else
			   MD2FREE=$(echo "  $MD2FREE")
			  fi
			  else
			  MD2FREE=$(echo " $MD2FREE")
			 fi
			fi

                        SDAFREE=$(echo "$SIZE" | awk '/sda2/ && $1 ~ /[1-9]/ {print $4}')
                        if [ -z $SDAFREE ]
                        then
                                SDAFREE=0
                        fi
                        SDAFREE=$[ $SDAFREE / 1024 / 1024 ]
                        if [ $SDAFREE -lt 1000 ]
                        then
                         if [ $SDAFREE -lt 100 ]
                         then
                          if [ $SDAFREE -lt 10 ]  
                          then
                           SDAFREE=$(echo "   $SDAFREE")
                          else
                           SDAFREE=$(echo "  $SDAFREE")
                          fi
                          else
                          SDAFREE=$(echo " $SDAFREE")
                         fi
                        fi

			MD2PERC=$(echo "$SIZE" | awk '/md2/ && $1 ~ /[1-9]/ {print $5}'|cut -d "%" -f1)
			if [ -z $MD2PERC ]
			then
				MD2PERC=0
			fi
			MD2PERC=$[ 100 - $MD2PERC ]
			if [ $MD2PERC -lt 100 ]
			then
			 if [ $MD2PERC -lt 10 ]  
			 then
			  MD2PERC=$(echo "  $BRed$MD2PERC$CO")
			 else
			  MD2PERC=$(echo " $MD2PERC")
			 fi
			fi

                        SDAPERC=$(echo "$SIZE" | awk '/sda2/ && $1 ~ /[1-9]/ {print $5}'|cut -d "%" -f1)
                        if [ -z $SDAPERC ]
                        then
                                SDAPERC=0
                        fi
                        SDAPERC=$[ 100 - $SDAPERC ]
                        if [ $SDAPERC -lt 100 ]
                        then
                         if [ $SDAPERC -lt 10 ]  
                         then
                          SDAPERC=$(echo "  $BRed$SDAPERC$CO")
                         else
                          SDAPERC=$(echo " $SDAPERC")
                         fi
                        fi


			MD2ACTIVE=$(echo "$RAID2" | awk '/Active/ && $1 ~ /[A-Z]/ {print $4}')
			MD2WORKING=$(echo "$RAID2" | awk '/Working/ && $1 ~ /[A-Z]/ {print $4}')
			MD2FAILED=$(echo "$RAID2" | awk '/Failed/ && $1 ~ /[A-Z]/ {print $4}')
			if [ -z $MD2FAILED ]
			then
				MD2FAILED=0
			fi
			if [ $MD2FAILED -gt 0 ]
			then
			 MD2FAILED=$(echo $BRed$MD2FAILED$CO)
			fi

			MD2SPARE=$(echo "$RAID2" | awk '/Spare/ && $1 ~ /[A-Z]/ {print $4}')
			if [ -z $MD2SPARE ]0
			then
				MD2SPARE=""
			fi

			MD2READ=$(echo "$IOSTATMD2" | awk '/md2/ && $1 ~ /[A-z]/ {print $3}' | cut -d "," -f1)
			if [ -z $MD2READ ]
			then
				MD2READ=0
			fi
			if [ $MD2READ -lt 1000 ]
			then
			 if [ $MD2READ -lt 100 ]
			 then
			  if [ $MD2READ -lt 10 ]  
			  then
			   MD2READ=$(echo "   $MD2READ")
			  else
			   MD2READ=$(echo "  $MD2READ")
			  fi
			  else
			  MD2READ=$(echo " $MD2READ")
			 fi
			fi

			MD2WRITE=$(echo "$IOSTATMD2" | awk '/md2/ && $1 ~ /[A-z]/ {print $9}' | cut -d"," -f1)
			if [ -z $MD2WRITE ]
			then
				MD2WRITE=0
			fi
			if [ $MD2WRITE -lt 1000 ]
			then
			 if [ $MD2WRITE -lt 100 ]
			 then
			  if [ $MD2WRITE -lt 10 ]  
			  then
			   MD2WRITE=$(echo "   $MD2WRITE")
			  else
			   MD2WRITE=$(echo "  $MD2WRITE")
			  fi
			  else
			  MD2WRITE=$(echo " $MD2WRITE")
			 fi
			fi

                        MD2USAGE=$(echo "$IOSTATMD2" | awk '/md2/ && $1 ~ /[A-z]/ {print $21}' | cut -d"," -f1)
                        if [ -z $MD2USAGE ]
                        then
                                MD2USAGE=0
                        fi
                        if [ $MD2USAGE -lt 1000 ]
                        then
                         if [ $MD2USAGE -lt 100 ]
                         then
                          if [ $MD2USAGE -lt 10 ]
                          then
                            MD2USAGE=$(echo " $Black $CO$MD2USAGE")
                          else
                           MD2USAGE=$(echo " $MD2USAGE")
                          fi
                          else
                          MD2USAGE=$(echo "$MD2USAGE")
                         fi
                        fi


                        SDAREAD=$(echo "$IOSTATSDA" | awk '/sda/ && $1 ~ /[A-z]/ {print $3}' | cut -d"," -f1)
                        if [ -z $SDAREAD ]
                        then
                                SDAREAD=0
                        fi
                        if [ $SDAREAD -lt 1000 ]
                        then
                         if [ $SDAREAD -lt 100 ]
                         then
                          if [ $SDAREAD -lt 10 ]  
                          then
                           SDAREAD=$(echo "   $SDAREAD")
                          else
                           SDAREAD=$(echo "  $SDAREAD")
                          fi
                          else
                          SDAREAD=$(echo " $SDAREAD")
                         fi
                        fi

                        SDAWRITE=$(echo "$IOSTATSDA" | awk '/sda/ && $1 ~ /[A-z]/ {print $9}' | cut -d"," -f1)
                        if [ -z $SDAWRITE ]
                        then
                                SDAWRITE=0
                        fi
                        if [ $SDAWRITE -lt 1000 ]
                        then
                         if [ $SDAWRITE -lt 100 ]
                         then
                          if [ $SDAWRITE -lt 10 ]  
                          then
                           SDAWRITE=$(echo "   $SDAWRITE")
                          else
                           SDAWRITE=$(echo "  $SDAWRITE")
                          fi
                          else
                          SDAWRITE=$(echo " $SDAWRITE")
                         fi
                        fi

			SDAUSAGE=$(echo "$IOSTATSDA" | awk '/sda/ && $1 ~ /[A-z]/ {print $21}' | cut -d"," -f1)
                        if [ -z $SDAUSAGE ]
                        then
                                SDAUSAGE="0"
                        fi
                        if [ $SDAUSAGE -lt 100 ]
                        then
                         if [ $SDAUSAGE -lt 10 ]
                         then
                          SDAUSAGE=$(echo " $Black $CO$SDAUSAGE")
                         else
                          SDAUSAGE=$(echo " $SDAUSAGE")
                         fi
                        fi

		fi
	fi
	if [ $GPUS -gt 0 ]
	then
		GPU=$(nvidia-smi -q)

		GPUTEMP=$(echo "$GPU" | awk '/GPU Current Temp/ && $2 ~ /[A-Z]/ {print $5}')

		GPUTOTMEM=$(echo "$GPU" | awk '/Total/ && /[1-9]/ {print $3}')
		if [ -z $GPUTOTMEM ]
		then
			GPUTOTMEM=0
		fi
		if [ $GPUTOTMEM -lt 1000 ]
		then
		 if [ $GPUTOTMEM -lt 100 ]
		 then
		  if [ $GPUTOTMEM -lt 10 ] 
		  then
		   GPUTOTMEM=$(echo "  $GPUTOTMEM")
		  else
		   GPUTOTMEM=$(echo " $GPUTOTMEM")
		  fi
		  else
		  GPUTOTMEM=$(echo "$GPUTOTMEM")
		 fi
		fi

		GPUUSEDMEM=$(echo "$GPU"  | awk '/Used/ && /[1-9]/ {print $3}')
		if [ -z $GPUUSEDMEM ]
		then
			GPUUSEDMEM=0
		fi
		if [ $GPUUSEDMEM -lt 1000 ]
		then
		 if [ $GPUUSEDMEM -lt 100 ]
		 then
		  if [ $GPUUSEDMEM -lt 10 ] 
		  then
		   GPUUSEDMEM=$(echo "  $GPUUSEDMEM")
		  else
		   GPUUSEDMEM=$(echo " $GPUUSEDMEM")
		  fi
		  else
		  GPUUSEDMEM=$(echo "$GPUUSEDMEM")
		 fi
		fi

		GPUFREEMEM=$(echo "$GPU"  | awk '/Free/ && /[1-9]/ {print $3}')
		if [ -z $GPUFREEMEM ]
		then
			GPUFREEMEM=0
		fi
		if [ $GPUFREEMEM -lt 1000 ]
		then
		 if [ $GPUFREEMEM -lt 100 ]
		 then
		  if [ $GPUFREEMEM -lt 10 ] 
		  then
		   GPUFREEMEM=$(echo "  $GPUFREEMEM")
		  else
		   GPUFREEMEM=$(echo " $GPUFREEMEM")
		  fi
		  else
		  GPUFREEMEM=$(echo "$GPUFREEMEM")
		 fi
		fi

		if [ -n $GPUTOTMEM ]
		then
			GPUFREEPERC=$[ $GPUFREEMEM * 100 / $GPUTOTMEM ]
		fi
		if [ -z $GPUFREEPERC ]
		then
			GPUFREEPERC=0
		fi
		if [ $GPUFREEPERC -lt 100 ]
		then
		 if [ $GPUFREEPERC -lt 10 ]  
		 then
		  GPUFREEPERC=$(echo "  $BRed$GPUFREEPERC$CO")
		 else
		  GPUFREEPERC=$(echo " $GPUFREEPERC")
		 fi
		 else
		 GPUFREEPERC=$(echo $BRed$GPUFREEPERC$CO)
		fi

		GPUFAN=$(echo "$GPU" | awk '/Fan Speed/ && $2 ~ /[A-Z]/ {print $4}')
		if [ -z $GPUFAN ]
		then
			GPUFAN=0
		fi
		 if [ $GPUFAN -lt 100 ]
		 then
		  if [ $GPUFAN -lt 10 ]
		  then
		   GPUFAN=$(echo "  $GPUFAN")
		  else
		   GPUFAN=$(echo " $GPUFAN")
		  fi
		  else
		  GPUFAN=$(echo "$GPUFAN")
		 fi

		GPUPERF=$(echo "$GPU" | awk '/Performance State/ && $2 ~ /[A-Z]/ {print $4}')
		if [ -z $GPUPERF ]
		then
			GPUPERF="       na       "
		fi
		case $GPUPERF in
		 P12)
		  GPUFREQ=" 50MHz| 270MHz| 101MHz"
		  ;;
		 P8)
		  GPUFREQ="405MHz| 648MHz| 810MHz"
		  ;;
		 P0)
		  GPUFREQ="594MHz|1600MHz|1189MHz"
		esac


		GPUNAME=$(echo "$GPU" | awk '/Product Name/ && $2 ~ /[A-Z]/ {print $5" "$6}')
		if [ -z "$GPUNAME" ]
		then
			GPUNAME="na"
		fi
	fi

	if [ $LOOP -gt 1 ]
 	then
 	 printf "\033c"
 	 tput cup 0 0
 	fi
	if [ $TIMES -gt 0 ]
	then
		echo -e $Cyan"|=================== Bad Temp v.$VER ==================|"$CO
		echo -e "$Cyan|$CO $DATE |$BGreen$UPTIME$CO$Cyan|$CO"
	fi
	if [ $CPUS -gt 0 ]
	then
		echo -e $Cyan"|======================================================|"$CO
		echo -e "$Cyan|$CO          |  "$BPurple"Core 0"$CO"  |  "$BPurple"Core 1"$CO"  |  "$BPurple"Core 2"$CO"  |  "$BPurple"Core 3"$CO"  $Cyan|$CO"
		if [ $SENSORSS -gt 0 ]
		then 
			echo -e "$Cyan|$CO   "$BPurple"Temp"$CO"   |   $CPU0°C   |   $CPU1°C   |   $CPU2°C   |   $CPU3°C   $Cyan|$CO"
		fi
		echo -e "$Cyan|$CO   "$BPurple"Load"$CO"   |   $LOAD0%   |   $LOAD1%   |   $LOAD2%   |   $LOAD3%   $Cyan|$CO"
		echo -e "$Cyan|$CO   "$BPurple"Freq$CO   | "$SPEED0" MHz | "$SPEED1" MHz | "$SPEED2" MHz | "$SPEED3" MHz $Cyan|$CO"
		echo -e $Cyan"|------------------------------------------------------|"$CO
		if [ $SENSORSS -gt 0 ]
		then 
			echo -e "$Cyan|$CO    "$BPurple"FAN"$CO"   |  "$CPUFAN"rpm | "$BPurple"Governor"$CO" |  $GOVERNOR  $Cyan|$CO"
		fi
	fi
	if [ $GPUS -gt 0 ]
	then
		echo -e $Cyan"|======================================================|"$CO
		echo -e "$Cyan|$CO    "$BPurple"GPU"$CO"   |   "$BPurple"Temp"$CO"   |   "$BPurple"Fan"$CO"   |  $BPurple""GPU"$CO" |  $BPurple""RAM$CO  | $BPurple""Shader$C0$Cyan|$CO"
		echo -e "$Cyan|$CO  $GPUNAME |   $GPUTEMP°C   |  $GPUFAN""%   |$GPUFREQ$Cyan|$CO"
	fi
	if [ $SENSORSS -gt 0 ]
	then
		echo -e $Cyan"|======================================================|"$CO
		echo -e "$Cyan|$CO "$BPurple"PowerFan "$CO"|  $POWERFAN""rpm |   "$BPurple"Case"$CO"   |$CASEFAN""rpm |   "$BPurple"Temp"$CO"   $Cyan|$CO"
		echo -e "$Cyan|$CO   "$BPurple"+3.3V"$CO"  |   "$V33"  |   "$BPurple"+5V"$CO"    |   "$V5"  |   "$BPurple"Case"$CO"   $Cyan|$CO"
		echo -e "$Cyan|$CO   "$BPurple"+12V"$CO"   |  "$V12"  |  "$BPurple"V-Core"$CO"  |   "$VCORE"  |   $MB°C   $Cyan|$CO"
	fi
	if [ $HDS -gt 0 ]
	then
                echo -e $Cyan"|======================================================|"$CO
                echo -e "$Cyan|$CO          | "$BPurple"Temp"$CO" | "$BPurple"SMART"$CO"  |          | "$BPurple"Temp"$CO" | "$BPurple" SMART "$CO" $Cyan|$CO"
                echo -e "$Cyan|$CO"$BPurple"SSD0(sda) "$CO"| $HD0TEMP°C | $HD0SMART |$CO" $BPurple"HD3(sdd)"$CO "| $HD3TEMP°C | $HD3SMART  $Cyan|$CO"
                echo -e "$Cyan|$CO" $BPurple"HD1(sdb) "$CO"| $HD1TEMP°C | $HD1SMART |$CO" $BPurple"HD4(sde)"$CO "| $HD4TEMP°C | $HD4SMART  $Cyan|$CO"
                echo -e "$Cyan|$CO" $BPurple"HD2(sdc) "$CO"| $HD2TEMP°C | $HD2SMART |$CO" $BPurple"HD5(sdf)"$CO "| $HD5TEMP°C | $HD5SMART  $Cyan|$CO"
	fi
	if [ $RAIDS -gt 0 ]
	then
		echo -e $Cyan"|------------------------------------------------------|"$CO
		echo -e "$Cyan|$CO"$BPurple"/dev/md2"$CO"  |  $MD2STATE  |  $MD2LEVEL   | "$BPurple"A:"$CO" $MD2ACTIVE "$BPurple"W:"$CO" $MD2WORKING "$BPurple"F:"$CO" $MD2FAILED "$BPurple"S:"$CO" $MD2SPARE $Cyan|$CO"
                echo -e $Cyan"|------------------------------------------------------|"$CO
		echo -e "$Cyan|$CO"$BPurple"/dev/md2"$CO"  |"$BPurple"Write "$CO"|$MD2WRITE""MB/s |"$BPurple"Read "$CO"|$MD2READ""MB/s |"$BPurple"Usg. "$CO"$Cyan|$CO"$MD2USAGE"%$Cyan|$CO"
                echo -e "$Cyan|$CO"$BPurple"/dev/sda2"$CO" |"$BPurple"Write "$CO"|$SDAWRITE""MB/s |"$BPurple"Read "$CO"|$SDAREAD""MB/s |"$BPurple"Usg. "$CO"$Cyan|$CO"$SDAUSAGE"%$Cyan|$CO"
	fi
	if [ $MEMS -gt 0 ]
	then
		echo -e $Cyan"|======================================================|"$CO
		echo -e "$Cyan|$CO          |   "$BPurple"Total"$CO"  |   "$BPurple"Used"$CO"   |   "$BPurple"Free"$CO"   |  "$BPurple"Free%"$CO"   $Cyan|$CO"
		echo -e "$Cyan|$CO   "$BPurple"RAM"$CO"    |  "$MEMTOTAL"MB  |  "$MEMUSED"MB  |  "$MEMAVAL"MB  |   $MEMPERC""%   $Cyan|$CO"
		echo -e "$Cyan|$CO   "$BPurple"SWAP"$CO"   |  ""$SWAPTOTAL""MB  |  ""$SWAPUSED""MB  |  ""$SWAPAVAL""MB  |   $SWAPPERC""%   $Cyan|$CO"
		if [ $GPUS -gt 0 ]
		then
			echo -e "$Cyan|$CO   "$BPurple"GPU"$CO"    |   $GPUTOTMEM""MB  |   $GPUUSEDMEM""MB  |   $GPUFREEMEM""MB  |   $GPUFREEPERC%   $Cyan|$CO"
		fi
	fi
	if [ $RAIDS -gt 0 ]
	then 
		echo -e $Cyan"|------------------------------------------------------|"$CO
		echo -e "$Cyan|$CO"$BPurple"/dev/md2"$CO"  |  $MD2SIZE""GB  |  $MD2USED""GB  |  $MD2FREE""GB  |   $MD2PERC%   $Cyan|$CO"
                echo -e "$Cyan|$CO"$BPurple"/dev/sda2"$CO" |  $SDASIZE""GB  |  $SDAUSED""GB  |  $SDAFREE""GB  |   $SDAPERC%   $Cyan|$CO"
	fi
	if [ $ETHS -gt 0 ]
	then
		echo -e $Cyan"|======================================================|"$CO
		echo -e "$Cyan|$CO   "$BPurple"UP"$CO"   |  "$BPurple"DOWN"$CO"  | "$BPurple"Tot UP"$CO" | "$BPurple"Tot DOWN"$CO" |  "$BPurple"Link""$CO  $Cyan|$CO  "$BPurple"Ping"  "$CO$Cyan|$CO"
		echo -e "$Cyan|$CO$UP""KB |$DOWN""KB |$TOTUP"."$TOTUPD$TOTUPKMG| $TOTDOWN"."$TOTDOWND$TOTDOWNKMG |$ETHSPEED| $PING""ms $Cyan|$CO"
	fi
        echo -e $Cyan"|========== Premi h per la lista dei comandi ==========|"$CO
	if [ $LOOP -gt 1 ]
	then
		read -n1 command
		command1=''
		for z in $command; do
			case $z in
			c)
				echo -e ""
                                echo -e "Imposto il governor \"conservative\""
				sudo cpupower -c all frequency-set -g conservative
			;;
                        o)
                                echo -e ""
                                echo -e "Imposto il governor \"ondemand\""
                                sudo cpupower -c all frequency-set -g ondemand
                        ;;
                        s)
                                echo -e ""
                                echo -e "Imposto il governor \"powersave\""
                                sudo cpupower -c all frequency-set -g powersave
                        ;;

                        t)
				while [ -z $command1 ]; do printf "\033c"; tput cup 0 0; date; echo; transmission-remote -n transmission:transmission -l|awk ' NR == 1 { print; next; } {if( last ) print last | "sort -k2nr,2";last = $0;} END {close( "sort -k2nr,2" ); print last;}'; sleep 1; read -n1 command1; done;
                        ;;
                        r)
				while [ -z $command1 ]; do printf "\033c"; tput cup 0 0; date; echo; cat /proc/mdstat; sudo mdadm --detail /dev/md2; sleep 1; read -n1 command1; done
                        ;;
                        y)
                                while [ -z $command1 ]; do printf "\033c"; tput cup 0 0; date; echo; sudo iostat --human; sleep 1; read -n1 command1; done
                        ;;

                        p)
                                sudo htop
                        ;;
                        u)
                                source ~/hubic.sh
				while [ -z $command1 ]; do printf "\033c"; tput cup 0 0; date; echo; hubic status; sleep 1; read -n1 command1; done
                        ;;
			i)
                                sudo iftop
                        ;;
			w)
				sudo iotop
			;;
                        v)
				printf "\033c"
				tput cup 0 0
				tail -f /home/andbad/265.log
                        ;;


			1)
                                killall -CONT HandBrakeCLI
                        ;;
			2)
                                killall -STOP HandBrakeCLI
                        ;;

                        d)
                                watch -n1 -c dropbox status
                        ;;

                        m)
				mytop -u root -p 0104193Sei -m top
                        ;;

                        a)
                                sudo atop -d
                        ;;

			h)
                                TMOUTold=TMOUT
				TMOUT=0
				printf "\033c"
				tput cup 0 0
				echo -e $Cyan"|===================================================|"$CO
				echo -e $Cyan"|"$CO$BYellow"                   Help comandi:"$CO$Cyan"                   |"
                                echo -e $Cyan"|===================================================|"$CO
                                echo -e $Cyan"|                       CPU                         "$Cyan"|"
                                echo -e $Cyan"| "$BPurple"c"$CO" -> attiva il governor \"conservative\"           " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"o"$CO" -> attiva il governor \"ondemand\"               " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"s"$CO" -> attiva il governor \"powersave\"              " $Cyan"|"
                                echo -e $Cyan"|                                                  " $Cyan"|"
                                echo -e $Cyan"|                      STATUS                      " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"t"$CO" -> torrent attivi                              " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"r"$CO" -> RAID                                        " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"d"$CO" -> Dropbox                                     " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"u"$CO" -> cloud Hubic                                 " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"p"$CO" -> processi attivi (htop)                      " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"i"$CO" -> traffico di rete (iftop)                    " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"w"$CO" -> processi accesso disco (iotop)              " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"y"$CO" -> monitor accesso disco (iostat)              " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"a"$CO" -> Riepilogo accessi disco (atop)              " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"m"$CO" -> MySQL (mytop)                               " $Cyan"|"
                                echo -e $Cyan"|                                                  " $Cyan"|"
                                echo -e $Cyan"|                CONVERSIONE VIEDO                 " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"1"$CO" -> riavvia                                     " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"2"$CO" -> sospendi                                    " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"v"$CO" -> monitor                                     " $Cyan"|"
                                echo -e $Cyan"|                                                  " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"h"$CO" -> questa schermata di help                    " $Cyan"|"
                                echo -e $Cyan"| "$BPurple"q"$CO" -> uscita                                      " $Cyan"|"
				echo -e $Cyan"|                                                   |"
                                echo -e $Cyan"| "$BCyan"Premi un tasto per tornare alla dash.            "$CO $Cyan"|"
                                echo -e $Cyan"|===================================================|"$CO
				read -n1 command
				TMOUT=TMOUTold
                        ;;
                        q)
                                exit 1
                        ;;


			esac
		done
	fi
done
