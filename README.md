# Bad Temp
Dashboard per avere sott'occhio tutte le informazioni della macchina.

# Installazione
Uso: temp.sh [OPZIONE]...
Mostra informazioni sull'hardware e sulle prestazioni utilizzando le seguenti utility (che devono essere installate manualmente nel sistema):
date, uptime, ifconfig, ethtool, ifstat, sensors, mpstat, dmidecode, hddtemp, smartctl, free, iostat, mdadm, nvidia-smi.

--------------------------------------------------

Aggiungere l'alias seguente:

echo "alias temp='/home/username/temp.sh 2> /dev/null'" >> ~/.bash_aliases
source ~/.bashrc

--------------------------------------------------

Per evitare la richiesta di password di root all'avvio, aggiungere le seguenti righe al file sudoers (sudo visudo)
username ALL=NOPASSWD: /sbin/ethtool
usernane ALL=NOPASSWD: /usr/sbin/dmidecode
username ALL=NOPASSWD: /usr/sbin/hddtemp
username ALL=NOPASSWD: /usr/sbin/smartctl
username ALL=NOPASSWD: /sbin/mdadm
username ALL=NOPASSWD: /usr/bin/iostat
username ALL=NOPASSWD: /usr/bin/iotop
username ALL=NOPASSWD: /usr/sbin/iftop
username ALL=NOPASSWD: /usr/bin/htop
username ALL=NOPASSWD: /usr/bin/atop

--------------------------------------------------

Opzioni:
-l, --loop      Esegue lo script una volta sola ed esce (di default viene eseguito in loop).
-g, -- gpu      Disattiva la visualizzazione della info sulla GPU
-r, --raid      Disattiva la visualizzazione della info sui RAID
-d, --disk      Disattiva la visualizzazione della info sui dischi
-m, --memory    Disattiva la visualizzazione della info sulla memoria
-c, --cpu       Disattiva la visualizzazione della info sulla/e CPU
-s, --sensors   Disattiva la visualizzazione della info sui sensori di temperatura e voltaggio
-e, --ethernet  Disattiva la visualizzazione della info sulla scheda Ethernet
-t, --time      Disattiva la visualizzazione di data/ora e uptime


# Screenshot

![temp1](https://user-images.githubusercontent.com/7837288/140042552-47e686d4-e179-44f1-8ca5-0695c59e3554.png)
![temp2](https://user-images.githubusercontent.com/7837288/140042562-47c8f3b7-8171-444a-95f0-84da1c322ebe.png)
![temp3](https://user-images.githubusercontent.com/7837288/140042571-cb001a10-646a-4478-bb5a-9a434030b04f.png)
