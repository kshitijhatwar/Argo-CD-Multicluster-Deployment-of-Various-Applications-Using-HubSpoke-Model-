#!/bin/bash
<< task
IP
HOstname
Zabbix
patchmanager
AV
PAM

task

function InstallZabbix {
    echo "Downloading Zabbix5.4"
    sudo wget -O /var/tmp/zabbix-release_5.4-1+ubuntu20.04_all.deb https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
    echo "Installing Zabbix5.4"
    sudo dpkg -i /var/tmp/zabbix-release_5.4-1+ubuntu20.04_all.deb
    sudo apt update
    sudo apt install zabbix-agent
    sudo systemctl enable zabbix-agent
    sudo systemctl start zabbix-agent
    echo "macking changes in Zabbix.config"
    sed -i 's/Server=127.0.0.1/Server=10.0.2.163,10.0.4.103,10.0.4.133,103.148.160.71,10.0.4.216,10.0.4.150,10.0.4.217,10.0.4.179/' /etc/zabbix/zabbix_agentd.conf;
    sed -i 's/ServerActive=127.0.0.1/ServerActive=10.0.2.163,10.0.4.103,10.0.4.133,103.148.160.71,10.0.4.216,10.0.4.150,10.0.4.217,10.0.4.179/' /etc/zabbix/zabbix_agentd.conf;
    sed -i "s/Hostname=Zabbix\ server/Hostname=${HostName}/" /etc/zabbix/zabbix_agentd.conf;
    sed -i "s/#\ Timeout=3/Timeout=30/" /etc/zabbix/zabbix_agentd.conf;
    sed -i "s/#\ ListenPort=10050/ListenPort=10050/" /etc/zabbix/zabbix_agentd.conf;
    echo "UserParameter=cpu.tasks,ps -eo comm,%cpu --sort=-%cpu | head -6 | awk '{if (NR!=1) printf(\"%s | \", \$1\":\"\$2\"%\")}'" | sudo tee -a /etc/zabbix/zabbix_agentd.conf > /dev/null
    echo "UserParameter=memory.tasks,ps -eo comm,%mem --sort=-%mem | head -6 | awk '{if (NR!=1) printf(\"%s | \", \$1\":\"\$2\"%\")}'" | sudo tee -a /etc/zabbix/zabbix_agentd.conf > /dev/null

}

function ChangeHostName {
    echo "Changing HostName"
    read -p "Enter new HostName: " HostName
    sudo hostnamectl set-hostname ${HostName}
}

function ChangeIP {
    echo "Changing DataIP"
    # Prompt user for input
    read -p "Enter the number of interface you have(e.g., 1 or 2):" VLAN
    
    # Backup existing netplan configuration
    sudo cp /etc/netplan/*.yaml /etc/netplan/backup-$(date +%F-%T).yaml

    # Create new netplan configuration
    for ((i=1; i<=VLAN; i++))
    do
    echo "Enter details for Interface $i"
    read -p "Enter the network interface name (e.g., eth0 or ens33): " INTERFACE
    read -p "Enter new IP address (e.g., 192.168.1.100): " IP
    read -p "Enter subnet mask in CIDR (e.g., 24 for 255.255.255.0): " MASK
    read -p "Enter gateway address (e.g., 192.168.1.1): " GATEWAY
    sudo tee /home/ubuntu/50-cloud-init.yaml > /dev/null <<EOF
    network:
    version: 2
    ethernets:
        ${INTERFACE}:
        dhcp4: no
        addresses:
            - ${IP}/${MASK}
        gateway4: ${GATEWAY}
        nameservers:
            addresses:
                - 8.8.8.8
                - 8.8.4.4

EOF
done

    #Apply the new configuration
    #sudo netplan apply
    #ping ${GATEWAY}

    echo "Network configuration updated successfully."

}

function InstallPatchManager {
    echo "installing PatchManager..........."
    sudo apt-get install zip unzip
    cd /var/tmp
    sudo unzip....
    sudo chmmod 700......
    sudo .\UEMS.....
}

function EssentialCommands {

    echo "Deleting machine ID $(rm /etc/machine-id)"
    echo "ReGenrating machine ID $(rm /etc/machine-id)"
    echo "ReConfiguring Open-SSH-Server $(dpkg-reconfigure openssh-server)"
}

function InstallQualys {

    echo "Installing Qualis VA Agent......."
    cd /var/tmp


}

function Verification {

    #Variables
    FWSTATUS=$(sudo ufw status | grep -i "Status" | awk '{print $2}')
    GWS=$(ip route | grep default | awk '{print $3}')

    echo "Your Hostname is $(hostname)"
    echo "Your IP is $(hostname -I)"
    echo "Your Gatway is $(ip route | awk '/default/ {print $3}')"

    #Gateway Ping
    j = 1
    for GW in $GWS
    do
        echo "Cheking Ping Status for $GW : $GWS "
        if ping -c 3 -W 2 "$GW" &> /dev/null; then
            echo "Gateway $GW is reachable."
        else
            echo "Gateway $GW is Not Reachable."
        fi
        j = $((j + 1))
    done

    #Zabbix IP Ping
    echo "Cheking Zabbix Ip Ping Status"
    if ping -c 3 -W 2 10.0.4.133 &> /dev/null; then
        echo "Able to ping Zabbix IP- 10.0.4.133 successfully"
    else
        echo "Not able to ping Zabbix IP- 10.0.4.133"
    fi

    #FW STATUS
    if [ "$FWSTATUS" = "active" ]; then
        echo "Firewall is Active"
    else
        echo "Firewall is InActive"
    fi

    #SSH STATUS
    if systemctl is-active --quiet ssh; then
        echo "SSH is Active"
    else
        echo "SSH is InActive"
    fi

    #ZABBIX STATUS
    if systemctl is-active --quiet zabbix-agent; then
        echo "Zabbix is Active"
    else
        echo "Zabbix is InActive"
    fi

    #ZABBIX CONFIG FILE CHANGES
    echo "--------Zabbix config file -----------"
    egrep -v '^(#|$)' /etc/zabbix/zabbix_agentd.conf;
    echo "--------------------------------------"

}


ChangeHostName
ChangeIP
InstallZabbix
EssentialCommands
Verification
