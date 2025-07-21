#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Variables
NS=$(cat /etc/xray/dns 2>/dev/null)
PUB=$(cat /etc/slowdns/server.pub 2>/dev/null)
domain=$(cat /etc/xray/domain 2>/dev/null)
grenbo="\e[92;1m"
NC='\e[0m'
BOT_DIR="/usr/bin/kyt"
LOG_FILE="/var/log/kyt_install.log"

# Initialize log file
echo "=== KYT Bot Installation Log ===" > $LOG_FILE
date >> $LOG_FILE

# Function to log and execute commands
run_cmd() {
  echo -e "\n$ $@" >> $LOG_FILE
  "$@" 2>&1 | tee -a $LOG_FILE
  return ${PIPESTATUS[0]}
}

# Update system
echo -e "${grenbo}[*] Updating system packages...${NC}"
run_cmd apt update && run_cmd apt upgrade -y
if [ $? -ne 0 ]; then
  echo -e "${grenbo}[!] Failed to update system packages${NC}"
  exit 1
fi

# Install dependencies
echo -e "${grenbo}[*] Installing dependencies...${NC}"
run_cmd apt install -y python3 python3-pip git unzip wget
if [ $? -ne 0 ]; then
  echo -e "${grenbo}[!] Failed to install dependencies${NC}"
  exit 1
fi

# Install additional Python packages
echo -e "${grenbo}[*] Installing Python dependencies...${NC}"
run_cmd pip3 install --upgrade pip
run_cmd pip3 install setuptools wheel

# Download and extract bot files
echo -e "${grenbo}[*] Downloading bot files...${NC}"
cd /usr/bin
run_cmd wget -q --show-progress https://raw.githubusercontent.com/xyoruz/X/main/bot/bot.zip
run_cmd unzip -o bot.zip
run_cmd chmod +x /usr/bin/*
run_cmd rm -f bot.zip

# Download and extract kyt files
echo -e "${grenbo}[*] Downloading kyt files...${NC}"
run_cmd wget -q --show-progress https://raw.githubusercontent.com/xyoruz/X/main/bot/kyt.zip
run_cmd unzip -o kyt.zip -d $BOT_DIR
if [ $? -ne 0 ]; then
  echo -e "${grenbo}[!] Failed to extract kyt files${NC}"
  exit 1
fi

# Install Python requirements
echo -e "${grenbo}[*] Installing Python requirements...${NC}"
run_cmd pip3 install -r $BOT_DIR/requirements.txt
if [ $? -ne 0 ]; then
  echo -e "${grenbo}[!] Failed to install Python requirements${NC}"
  exit 1
fi

# Get user input for bot configuration
clear
echo ""
echo -e "\033[1;36m‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ\033[0m"
echo -e " \e[1;97;101m          ADD BOT PANEL          \e[0m"
echo -e "\033[1;36m‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ\033[0m"
echo -e "${grenbo}Tutorial Creat Bot and ID Telegram${NC}"
echo -e "${grenbo}[*] Creat Bot and Token Bot : @BotFather${NC}"
echo -e "${grenbo}[*] Info Id Telegram : @MissRose_bot , perintah /info${NC}"
echo -e "\033[1;36m‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ‚îÅ\033[0m"

# Validate bot token input
while true; do
  read -e -p "[*] Input your Bot Token : " bottoken
  if [[ -z "$bottoken" ]]; then
    echo -e "${grenbo}[!] Bot Token cannot be empty${NC}"
  else
    break
  fi
done

# Validate admin ID input
while true; do
  read -e -p "[*] Input Your Id Telegram : " admin
  if [[ -z "$admin" ]]; then
    echo -e "${grenbo}[!] Admin ID cannot be empty${NC}"
  elif ! [[ "$admin" =~ ^[0-9]+$ ]]; then
    echo -e "${grenbo}[!] Admin ID must be a number${NC}"
  else
    break
  fi
done

# Create configuration file
echo -e "${grenbo}[*] Creating configuration file...${NC}"
cat > $BOT_DIR/var.txt << END
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$domain"
PUB="$PUB"
HOST="$NS"
END

# Create systemd service
echo -e "${grenbo}[*] Creating systemd service...${NC}"
cat > /etc/systemd/system/kyt.service << END
[Unit]
Description=Simple kyt - @kyt
After=network.target

[Service]
WorkingDirectory=$BOT_DIR
ExecStart=/usr/bin/python3 -m kyt
Restart=always
RestartSec=5
User=root
Group=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
END

# Reload and enable service
echo -e "${grenbo}[*] Starting bot service...${NC}"
run_cmd systemctl daemon-reload
run_cmd systemctl enable kyt.service
run_cmd systemctl start kyt.service
run_cmd systemctl restart kyt.service

# Verify service status
if ! systemctl is-active --quiet kyt.service; then
  echo -e "${grenbo}[!] Failed to start kyt service${NC}"
  journalctl -u kyt.service -n 10 --no-pager
  exit 1
fi

# Clean up
echo -e "${grenbo}[*] Cleaning up...${NC}"
run_cmd rm -f /root/kyt.sh

# Display installation summary
clear
echo -e "${grenbo}[*] Installation completed successfully!${NC}"
echo -e "\nYour Data Bot"
echo -e "==============================="
echo -e "Token Bot   : $bottoken"
echo -e "Admin       : $admin"
echo -e "Domain      : $domain"
echo -e "Pub         : $PUB"
echo -e "Host        : $NS"
echo -e "==============================="
echo -e "\nBot service status: $(systemctl is-active kyt.service)"
echo -e "To check logs: journalctl -u kyt.service -f"
echo -e "\nInstallations complete, type /menu on your bot"
