#!/bin/bash

# Define colors for convenience
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

# 1) Display the logo at the start
curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/main/evenorlogo.sh | bash
echo ""

# Function for loading animation
animate_loading() {
    for ((i = 1; i <= 5; i++)); do
        printf "\r${GREEN}Loading the menu${NC}."
        sleep 0.3
        printf "\r${GREEN}Loading the menu${NC}.."
        sleep 0.3
        printf "\r${GREEN}Loading the menu${NC}..."
        sleep 0.3
        printf "\r${GREEN}Loading the menu${NC}"
        sleep 0.3
    done
    echo ""
}

# 2) Show the menu
echo -e "${CYAN}Choose an action:${NC}"
echo "1) Install node"
echo "2) Check node status"
echo "3) Check node points"
echo "4) Remove node"
echo "5) Update node"
echo "6) Obtain referral code"
echo "7) Exit"
read -p "Enter your choice: " CHOICE

# -------------------------------------------------------------------------------
# Functions definitions
# -------------------------------------------------------------------------------

# Function to install required packages
install_dependencies() {
    echo -e "${GREEN}Installing required packages...${NC}"
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
}

# Function to install the node
install_node() {
    echo -e "${BLUE}Starting node installation...${NC}"

    install_dependencies

    mkdir -p ~/pipe/download_cache
    cd ~/pipe || exit

    curl -L -o pop "https://dl.pipecdn.app/v0.2.8/pop"
    chmod +x pop

    # Create detached screen session for pop process
    screen -S pipe2 -dm

    echo -e "${YELLOW}Enter your Solana public key:${NC}"
    read -r SOLANA_PUB_KEY

    echo -e "${YELLOW}Enter the amount of RAM in GB (integer):${NC}"
    read -r RAM

    echo -e "${YELLOW}Enter the max disk size in GB (integer):${NC}"
    read -r DISK

    # Start pop with provided parameters
    screen -S pipe2 -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"
    sleep 3

    # Привязка ноды к рефералке
    screen -S pipe2 -X stuff "./pop --signup-by-referral-route 90ef3e76fb967d41\n"
    sleep 3

    # Отправка кода (например, подтверждение или ключ)
    screen -S pipe2 -X stuff "e4313e9d866ee3df\n"

    echo -e "${GREEN}Installation and launch process completed!${NC}"
}

# Function to check node status
check_status() {
    echo -e "${BLUE}Checking node status...${NC}"
    cd ~/pipe || exit
    ./pop --status
    cd ~ || exit
}

# Function to check node points
check_points() {
    echo -e "${BLUE}Checking node points...${NC}"
    cd ~/pipe || exit
    ./pop --points
    cd ~ || exit
}

# Function to update the node
update_node() {
    echo -e "${BLUE}Updating node to version 0.2.8...${NC}"

    # Stop pop process
    echo -e "${YELLOW}Stopping pop service...${NC}"
    ps aux | grep '[p]op' | awk '{print $2}' | xargs kill

    cd ~/pipe || exit

    echo -e "${YELLOW}Removing old version of pop...${NC}"
    rm -f pop

    echo -e "${YELLOW}Downloading new version of pop...${NC}"
    wget -O pop "https://dl.pipecdn.app/v0.2.8/pop"

    chmod +x pop

    sudo systemctl daemon-reload

    screen -S pipe2 -X quit
    sleep 2

    screen -S pipe2 -dm ./pop
    sleep 3
    screen -S pipe2 -X stuff "y\n"

    echo -e "${GREEN}Update completed!${NC}"
}

# Function to remove the node
remove_node() {
    echo -e "${BLUE}Removing the node...${NC}"

    pkill -f pop
    screen -S pipe2 -X quit

    sudo rm -rf ~/pipe

    echo -e "${GREEN}The node was successfully removed!${NC}"
}

# Function to generate referral code
generate_referral() {
    echo -e "${BLUE}Generating referral code...${NC}"
    cd ~/pipe || exit
    ./pop --gen-referral-route
    cd ~ || exit
}

# -------------------------------------------------------------------------------
# Menu execution
# -------------------------------------------------------------------------------

case $CHOICE in
    1)
        install_node
        ;;
    2)
        check_status
        ;;
    3)
        check_points
        ;;
    4)
        remove_node
        ;;
    5)
        update_node
        ;;
    6)
        generate_referral
        ;;
    7)
        echo -e "${CYAN}Exiting the program.${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting the program.${NC}"
        ;;
esac
