#!/bin/bash
# Dagster Manager Script
# This script helps manage Dagster operations locally

# Set color variables
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
NC="\033[0m" # No Color

# Change to project root directory
cd "$(dirname "$0")/.." || { echo -e "${RED}Failed to change to project root directory${NC}"; exit 1; }

# Load environment variables from .env file
source .env
DAGSTER_SERVER_PORT=${DAGSTER_SERVER_PORT:-3003}

# Function to start Dagster
start_dagster() {
    echo -e "${CYAN}Starting Dagster...${NC}"
    dagster dev
}

# Function to stop Dagster
stop_dagster() {
    echo -e "${CYAN}Stopping Dagster...${NC}"
    pkill -f "dagster dev"
}

# Function to check Dagster status
status_dagster() {
    echo -e "${CYAN}Checking Dagster status...${NC}"
    if pgrep -f "dagster dev" > /dev/null; then
        echo -e "${GREEN}Dagster is running.${NC}"
    else
        echo -e "${RED}Dagster is not running.${NC}"
    fi
}

# Function to view Dagster logs
logs_dagster() {
    echo -e "${CYAN}Displaying Dagster logs...${NC}"
    tail -f /Users/lark/files/learning/mlops-sandbox/dagster_home/logs/dagster.log
}

# Function to follow Dagster logs
follow_logs_dagster() {
    echo -e "${CYAN}Following Dagster logs... Press [CTRL+C] to stop.${NC}"
    tail -f /Users/lark/files/learning/mlops-sandbox/dagster_home/logs/dagster.log
}

# Function to check port status
port_status_dagster() {
    echo -e "${CYAN}Checking status of port ${DAGSTER_SERVER_PORT}...${NC}"
    if lsof -i :${DAGSTER_SERVER_PORT} > /dev/null; then
        echo -e "${GREEN}Port ${DAGSTER_SERVER_PORT} is in use.${NC}"
    else
        echo -e "${RED}Port ${DAGSTER_SERVER_PORT} is not in use.${NC}"
    fi
}

# Function to display current status line
display_status_line() {
    echo -e "${YELLOW}Dagster Status:${NC} $(status_dagster)"
    echo -e "${YELLOW}Port ${DAGSTER_SERVER_PORT}:${NC} $(port_status_dagster)"
    echo
}

# Function to show usage for command line mode
show_usage() {
    echo -e "\n${YELLOW}Usage:${NC} $0 [command]"
    echo -e "\n${YELLOW}Commands:${NC}"
    echo -e "  ${GREEN}start${NC}      - Start Dagster server"
    echo -e "  ${GREEN}stop${NC}       - Stop Dagster server"
    echo -e "  ${GREEN}restart${NC}    - Restart Dagster server"
    echo -e "  ${GREEN}status${NC}     - Show Dagster server status"
    echo -e "  ${GREEN}logs${NC}       - Show Dagster server logs"
    echo -e "  ${GREEN}follow-logs${NC} - Follow Dagster server logs"
    echo -e "  ${GREEN}port${NC}       - Check if port ${DAGSTER_SERVER_PORT} is in use"
    echo -e "  ${GREEN}help${NC}       - Show this help message"
    echo -e "\n${YELLOW}Or run without arguments for interactive menu${NC}"
}

# Function for interactive menu
interactive_menu() {
    local choice
    while true; do
        display_status_line
        echo -e "${BOLD}Dagster Manager${NC}"
        echo -e "${GREEN}1. Start Dagster${NC}"
        echo -e "${YELLOW}2. Stop Dagster${NC}"
        echo -e "${BLUE}3. Restart Dagster${NC}"
        echo -e "${CYAN}4. Status${NC}"
        echo -e "${CYAN}5. Logs${NC}"
        echo -e "${CYAN}6. Follow Logs${NC}"
        echo -e "${CYAN}7. Port Status${NC}"
        echo -e "${RED}8. Exit${NC}"
        read -rp "Choose an option: " choice

        case $choice in
            1) start_dagster ;;
            2) stop_dagster ;;
            3) restart_dagster ;;
            4) status_dagster ;;
            5) logs_dagster ;;
            6) follow_logs_dagster ;;
            7) port_status_dagster ;;
            8) exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
    done
}

# Main execution
if [[ $# -eq 0 ]]; then
    interactive_menu
else
    show_usage
fi
