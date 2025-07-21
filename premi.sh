#!/bin/bash

# Color definitions
Green="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
purple="\e[0;33m"

# Clear screen
clear
clear && clear && clear
clear; clear; clear

# Export IP Address
export IP=$(curl -sS icanhazip.com)

# Get server information
ipsaya=$(curl -sS ipv4.icanhazip.com)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")

# Banner
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo -e " WELCOME TO XYR TUNNELING SCRIPT ${YELLOW}(${NC}${green}Stable Edition${NC}${YELLOW})${NC}"
echo -e " PROSES PENGECEKAN IP ADDRESS ANDA !!"
echo -e "${purple}----------------------------------------------------------${NC}"
echo -e " ›AUTHOR : ${green}XYR STORE® ${NC}${YELLOW}(${NC}${green}V 3.2${NC}${YELLOW})${NC}"
echo -e " ›TEAM : XYR STORE ${YELLOW}(${NC} 2023 ${YELLOW})${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo ""
sleep 2

# Check OS Architecture
if [[ $(uname -m) != "x86_64" ]]; then
    echo -e "${ERROR} Your Architecture Is Not Supported ( ${YELLOW}$(uname -m)${NC} )"
    exit 1
else
    echo -e "${OK} Your Architecture Is Supported ( ${green}$(uname -m)${NC} )"
fi

# Check OS and Version
source /etc/os-release
OS=$ID
VER=$VERSION_ID

if [[ "$OS" == "ubuntu" ]]; then
    if [[ "$VER" == "20.04" || "$VER" == "22.04" ]]; then
        echo -e "${OK} Your OS Is Supported ( ${green}$PRETTY_NAME${NC} )"
    else
        echo -e "${ERROR} Your OS Version Is Not Supported ( ${YELLOW}$PRETTY_NAME${NC} )"
        exit 1
    fi
elif [[ "$OS" == "debian" ]]; then
    if [[ "$VER" == "10" || "$VER" == "11" ]]; then
        echo -e "${OK} Your OS Is Supported ( ${green}$PRETTY_NAME${NC} )"
    else
        echo -e "${ERROR} Your OS Version Is Not Supported ( ${YELLOW}$PRETTY_NAME${NC} )"
        exit 1
    fi
else
    echo -e "${ERROR} Your OS Is Not Supported ( ${YELLOW}$PRETTY_NAME${NC} )"
    exit 1
fi

# IP Address Validation
if [[ -z "$IP" ]]; then
    echo -e "${ERROR} IP Address ( ${YELLOW}Not Detected${NC} )"
    exit 1
else
    echo -e "${OK} IP Address ( ${green}$IP${NC} )"
fi

# Validate Successfull
echo ""
read -p "$(echo -e "Press ${GRAY}[ ${NC}${green}Enter${NC} ${GRAY}]${NC} For Starting Installation") "
echo ""
clear

# Check Root
if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

# Check Virtualization
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported"
    exit 1
fi

# Install initial packages
apt update -y
apt install ruby -y
gem install lolcat
apt install wondershaper -y
clear

# Define Repository
REPO="https://raw.githubusercontent.com/xyoruz/X/main/"

# Timer
start=$(date +%s)
secs_to_human() {
    echo "Installation time : $((${1} / 3600)) hours $(((${1} / 60) % 60)) minute's $((${1} % 60)) seconds"
}

# Status functions
function print_ok() {
    echo -e "${OK} ${BLUE} $1 ${FONT}"
}

function print_install() {
    echo -e "${green} =============================== ${FONT}"
    echo -e "${YELLOW} # $1 ${FONT}"
    echo -e "${green} =============================== ${FONT}"
    sleep 1
}

function print_error() {
    echo -e "${ERROR} ${REDBG} $1 ${FONT}"
}

function print_success() {
    if [[ 0 -eq $? ]]; then
        echo -e "${green} =============================== ${FONT}"
        echo -e "${Green} # $1 berhasil dipasang"
        echo -e "${green} =============================== ${FONT}"
        sleep 2
    fi
}

# Check root
function is_root() {
    if [[ 0 == "$UID" ]]; then
        print_ok "Root user Start installation process"
    else
        print_error "The current user is not the root user, please switch to the root user and run the script again"
    fi
}

# [Rest of your functions remain the same, but ensure they are compatible with Ubuntu 20/22 and Debian 10/11]
# [Include all your other functions here: make_folder_xray, first_setup, nginx_install, etc.]

# Main installation function
function instal() {
    clear
    first_setup
    nginx_install
    base_package
    make_folder_xray
    pasang_domain
    password_default
    pasang_ssl
    install_xray
    ssh
    udp_mini
    ssh_slow
    ins_udpSSH
    ins_SSHD
    ins_dropbear
    ins_vnstat
    ins_openvpn
    ins_backup
    ins_swab
    ins_Fail2ban
    ins_epro
    noobzvpn
    ins_restart
    menu
    profile
    enable_services
    restart_system
}

# Execute installation
instal

# Cleanup
echo ""
history -c
rm -rf /root/menu
rm -rf /root/*.zip
rm -rf /root/*.sh
rm -rf /root/LICENSE
rm -rf /root/README.md
rm -rf /root/domain

# Completion message
secs_to_human "$(($(date +%s) - ${start}))"
sudo hostnamectl set-hostname $username
echo ""
echo "------------------------------------------------------------"
echo ""
echo "   >>> Service & Port" | tee -a log-install.txt
echo "   - OpenSSH                 : 22, 53, 2222, 2269" | tee -a log-install.txt
echo "   - SSH Websocket           : 80" | tee -a log-install.txt
# [Include the rest of your service information]
echo ""
echo "===============-[ SCRIPT BY XYR TUNNEL ]-==============="
echo -e ""

read -p "Installation completed. Reboot now? (y/n)? " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    reboot
else
    exit 0
fi
