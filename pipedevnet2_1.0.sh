#!/bin/bash

# Updating the system before configuration
echo "Updating the system before configuration..."
sudo apt update -y && sudo apt upgrade -y

# Define colors for convenience
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

# Function to install required packages
install_dependencies() {
    echo -e "${GREEN}Installing required packages...${NC}"
    sudo apt update && sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
}

# Display the logo
curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/main/evenorlogo.sh | bash

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

# Call the loading animation
animate_loading
echo ""

# Function to install the node
install_node() {
    echo -e "${BLUE}Starting node installation...${NC}"

    # Update and install dependencies
    install_dependencies

    # Create a directory for cache and navigate there
    mkdir -p ~/pipe/download_cache
    cd ~/pipe || exit

    # Download the pop file
    wget https://dl.pipecdn.app/v0.2.2/pop

    # Make the file executable
    chmod +x pop

    # Create a new screen session
    screen -S pipe2 -dm

    echo -e "${YELLOW}Enter your Solana public key:${NC}"
    read -r SOLANA_PUB_KEY

    echo -e "${YELLOW}Enter the amount of RAM in GB (integer):${NC}"
    read -r RAM

    echo -e "${YELLOW}Enter the max disk size in GB (integer):${NC}"
    read -r DISK

    # Run the command with parameters (Solana public key, RAM, max disk)
    screen -S pipe2 -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"
    sleep 3
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

# Function to remove the node
remove_node() {
    echo -e "${BLUE}Removing the node...${NC}"

    pkill -f pop

    # Terminate and remove the 'pipe2' screen session
    screen -S pipe2 -X quit

    # Remove node files
    sudo rm -rf ~/pipe

    echo -e "${GREEN}The node was successfully removed!${NC}"
}

# Main menu (no pop-up, just terminal input)
echo -e "${CYAN}Choose an action:${NC}"
echo "1) Install node"
echo "2) Check node status"
echo "3) Check node points"
echo "4) Remove node"
echo "5) Exit"

read -p "Enter your choice: " CHOICE

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
        echo -e "${CYAN}Exiting the program.${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting the program.${NC}"
        ;;
esac

