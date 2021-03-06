#!/bin/bash

#Created by @MakMahlawat

#Changed by @Tr0nixCS 

# Step 1 = Determines the OS Distribution
# Step 2 = Determines the OS Version ID
# Step 3 = Downloads Zabbix-Agent Repository & Installs the Zabbix-Agent
# Step 4 = Update Zabbix-Agent Config, Enable Service to auto start post Boot & Restart Zabbix-Agent
# Step 5 = Installation Completion Greeting


function editzabbixconf()
{
echo ========================================================================
echo Step 3 = Downloading Zabbix Repository and Installing Zabbix-Agent	
echo !! 3 !! Zabbix-Agent Installed
echo ========================================================================

sed -i "s+Server=127.0.0.1+Server=CHANGE_THIS_TO_THE_IP_OF_THE_PROXY+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+Hostname=Zabbix server+Hostname=$(hostname -f)+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# Timeout=3+Timeout=30+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# TLSAccept=unencrypted+TLSAccept=cert+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# TLSCAFile=+TLSCAFile=/etc/zabbix/cabundle.crt+g" /etc/zabbix/zabbix_agentd.conf


echo ========================================================================
echo Step 4 = Working on Zabbix-Agent Configuration
echo !! 4 !! Updated Zabbix-Agent conf file at /etc/zabbix/zabbix_agentd.conf
echo !! 4 !! Enabled Zabbix-Agent Service to Auto Start at Boot Time
echo !! 4 !! Restarted Zabbix-Agent post updating conf file
echo ========================================================================
}


function ifexitiszero()
{
if [[ $? == 0 ]];
then editzabbixconf
else echo :-/ Failed at Step 3 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0

fi
}

#Downloades Zabbix V 6.0.1, and enables the firewall with 3 rules.

function ubuntu20()
{
sudo ufw enable -y
sudo ufw allow ssh && sudo ufw allow 10050 && sudo ufw allow 10051 && sudo ufw allow 443 && sudo ufw allow 5432 && sudo ufw allow Apache Full
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-1+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-1+ubuntu20.04_all.deb
sudo apt-get upgrade  && sudo apt-get update
sudo apt install zabbix-agent -y
sudo apt-get install postgresql-13 -y 
systemctl enable zabbix-agent
systemctl restart zabbix-agent
ifexitiszero
}

#VERSION ID FUNCTION'S LISTED BELOW

function version_id_ubuntu()
{
u1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $u1  #prints os version id like this : VERSION_ID="20.04"

u2=$(echo $u1 | cut -c13- | rev | cut -c2- |rev)
#echo $u2        #prints os version id like this : 20.04

u3=$(echo $u2 | awk '{print int($1)}')
#echo $u3       #prints os version id like this : 20

if [[ $u3 -eq 20 ]];      then ubuntu20
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}


#STEP 1 - SCRIPT RUNS FROM BELOW


echo Starting Zabbix-Agent Installation Script
echo ========================================================================
echo Step 1 = Determining OS Distribution Type

if [[ $(cat /etc/*release*) == *"ubuntu"* ]];
	then echo !! 1 !! OS Distribution determined as Ubuntu Linux
	echo Step 2 = Determining OS Version ID now
        version_id_ubuntu
else echo :-/ Failed at Step 1 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi


#STEP 5
echo ========================================================================
echo Congrats. Zabbix-Agent Installion is completed successfully.
echo Zabbix-Agent is installed, started and enabled to be up post reboot on this machine.
echo You can now add the host $(hostname -f) with IP $(hostname -i) on the Zabbix-Server Front End.
echo ========================================================================
echo To check zabbix-agent service status, you may run : service zabbix-agent status
echo To check zabbix-agent config, you may run : /etc/zabbix/zabbix_agentd.conf
echo To check zabbix-agent logs, you may run : tail -f /var/log/zabbix/zabbix_agentd.log
echo ========================================================================
