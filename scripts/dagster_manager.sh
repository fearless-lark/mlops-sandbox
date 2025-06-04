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
if [ -f .env ]; then
    source .env
else
    echo -e "${YELLOW}Warning: .env file not found. Using default values.${NC}"
fi

# Set default port if not defined in .env
DAGSTER_SERVER_PORT=${DAGSTER_SERVER_PORT:-3000}
DAGSTER_HOME=${DAGSTER_HOME:-./.dagster_home}

# Ensure DAGSTER_HOME directory exists
mkdir -p "${DAGSTER_HOME}"

# Export DAGSTER_HOME for the Dagster processes
export DAGSTER_HOME

# Display header
display_header() {
    clear
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}             Dagster Manager Script            ${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${CYAN}            Port: ${DAGSTER_SERVER_PORT} | Date: $(date '+%Y-%m-%d')${NC}"
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
    echo -e "  ${GREEN}port${NC}       - Check if port ${DAGSTER_SERVER_PORT} is in use"
    echo -e "  ${GREEN}help${NC}       - Show this help message"
    echo -e "\n${YELLOW}Or run without arguments for interactive menu${NC}"
}

# Function to display current status line
display_status_line() {
    echo -e "${YELLOW}Dagster Status:${NC} $(get_dagster_status)"
    echo -e "${YELLOW}Port ${DAGSTER_SERVER_PORT}:${NC} $(get_port_status)"
    echo
}

# Function for interactive menu
interactive_menu() {
    local choice
    
    while true; do
        display_header
        
        # Check and display Dagster status
        display_status_line
        
        echo -e "${BOLD}Select an option:${NC}"
        echo -e "${CYAN}1)${NC} Start Dagster server"
        echo -e "${CYAN}2)${NC} Stop Dagster server"
        echo -e "${CYAN}3)${NC} Restart Dagster server"
        echo -e "${CYAN}4)${NC} Show detailed status"
        echo -e "${CYAN}5)${NC} Check port ${DAGSTER_SERVER_PORT} usage"
        echo -e "${CYAN}0)${NC} Exit"
        echo
        read -p "Enter your choice [0-5]: " choice
        
        case $choice in
            1) 
                clear
                start_dagster
                
                # Show updated status after starting
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            2) 
                clear
                stop_dagster
                
                # Show updated status after stopping
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            3) 
                clear
                restart_dagster
                
                # Show updated status after restarting
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            4) 
                clear
                status_dagster
                echo
                read -p "Press Enter to continue..."
                ;;
            5) 
                clear
                check_port
                echo
                read -p "Press Enter to continue..."
                ;;
            0) 
                clear
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Get short Dagster status for menu display
get_dagster_status() {
    # Check if Dagster process is running
    if pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}" > /dev/null; then
        echo -e "${GREEN}Running${NC}"
    else
        echo -e "${RED}Stopped${NC}"
    fi
}

# Get short port status for menu display
get_port_status() {
    if lsof -i :${DAGSTER_SERVER_PORT} > /dev/null 2>&1; then
        echo -e "${YELLOW}In Use${NC}"
    else
        echo -e "${GREEN}Available${NC}"
    fi
}

# Check if port is in use
check_port() {
    if lsof -i :${DAGSTER_SERVER_PORT} > /dev/null 2>&1; then
        echo -e "${YELLOW}Port ${DAGSTER_SERVER_PORT} is currently in use:${NC}"
        lsof -i :${DAGSTER_SERVER_PORT}
        return 0
    else
        echo -e "${GREEN}Port ${DAGSTER_SERVER_PORT} is available.${NC}"
        return 1
    fi
}

# Ensure port is available before starting
ensure_port_available() {
    if check_port; then
        read -p "Would you like to free port ${DAGSTER_SERVER_PORT} (y/n)? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Attempting to free port ${DAGSTER_SERVER_PORT}...${NC}"
            
            # Try to identify and stop the process
            local pid=$(lsof -i :${DAGSTER_SERVER_PORT} -t)
            if [[ -n "$pid" ]]; then
                echo -e "Stopping process with PID ${pid}"
                kill -15 "$pid" || { echo -e "${RED}Failed to stop process, trying force kill...${NC}"; kill -9 "$pid"; }
                sleep 2
                if lsof -i :${DAGSTER_SERVER_PORT} > /dev/null 2>&1; then
                    echo -e "${RED}Failed to free port ${DAGSTER_SERVER_PORT}. Please stop the process manually.${NC}"
                    return 1
                else
                    echo -e "${GREEN}Successfully freed port ${DAGSTER_SERVER_PORT}.${NC}"
                    return 0
                fi
            else
                echo -e "${RED}Could not identify the process using port ${DAGSTER_SERVER_PORT}.${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Operation cancelled. Port ${DAGSTER_SERVER_PORT} is still in use.${NC}"
            return 1
        fi
    fi
    return 0
}

# Start Dagster server
start_dagster() {
    echo -e "${BLUE}Starting Dagster server...${NC}"
    
    if ! ensure_port_available; then
        echo -e "${RED}Cannot start Dagster server while port ${DAGSTER_SERVER_PORT} is in use.${NC}"
        return 1
    fi
    
    # Check if dagit is installed
    if ! command -v dagit &> /dev/null; then
        echo -e "${RED}Error: dagit command not found. Please make sure Dagster is installed.${NC}"
        echo -e "${YELLOW}You can install it with: pip install dagster dagit${NC}"
        return 1
    fi
    
    # Start Dagster in the background
    nohup dagit -p ${DAGSTER_SERVER_PORT} > "${DAGSTER_HOME}/dagster.log" 2>&1 &
    DAGSTER_PID=$!
    
    # Wait a moment to ensure Dagster has started
    echo -e "${YELLOW}Waiting for Dagster server to initialize...${NC}"
    sleep 3
    
    # Verify that Dagster is running
    if pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}" > /dev/null; then
        echo -e "${GREEN}Dagster server started successfully (PID: $DAGSTER_PID).${NC}"
        echo -e "${GREEN}You can access the Dagster UI at http://localhost:${DAGSTER_SERVER_PORT}${NC}"
        return 0
    else
        echo -e "${RED}Failed to start Dagster server. Check logs for details:${NC}"
        echo -e "${RED}${DAGSTER_HOME}/dagster.log${NC}"
        return 1
    fi
}

# Stop Dagster server
stop_dagster() {
    echo -e "${BLUE}Stopping Dagster server...${NC}"
    
    # Find Dagster processes
    local pid=$(pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}")
    
    if [[ -n "$pid" ]]; then
        echo -e "${YELLOW}Stopping Dagster process with PID ${pid}...${NC}"
        kill -15 "$pid"
        
        # Wait for process to terminate
        local max_wait=10
        local count=0
        while pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}" > /dev/null && [ $count -lt $max_wait ]; do
            echo -e "${YELLOW}Waiting for Dagster to shut down...${NC}"
            sleep 1
            ((count++))
        done
        
        if pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}" > /dev/null; then
            echo -e "${RED}Dagster server did not shut down gracefully. Forcing termination...${NC}"
            kill -9 "$pid"
            sleep 1
        fi
        
        if ! pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}" > /dev/null; then
            echo -e "${GREEN}Dagster server stopped successfully.${NC}"
            return 0
        else
            echo -e "${RED}Failed to stop Dagster server.${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}No running Dagster server found.${NC}"
        return 0
    fi
}

# Restart Dagster server
restart_dagster() {
    echo -e "${BLUE}Restarting Dagster server...${NC}"
    stop_dagster && start_dagster
}

# Check Dagster server status
status_dagster() {
    echo -e "${BLUE}Checking Dagster server status...${NC}"
    
    if pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}" > /dev/null; then
        local pid=$(pgrep -f "dagit -p ${DAGSTER_SERVER_PORT}")
        echo -e "${GREEN}Dagster server is running with PID ${pid}.${NC}"
        echo -e "${GREEN}Dagster UI is accessible at http://localhost:${DAGSTER_SERVER_PORT}${NC}"
        
        # Also check process details
        echo -e "\n${YELLOW}Process details:${NC}"
        ps -p "$pid" -o pid,ppid,user,%cpu,%mem,start,time,command
    else
        echo -e "${YELLOW}Dagster server is not running.${NC}"
    fi
    
    # Also check port status
    check_port
    
    # Check DAGSTER_HOME
    echo -e "\n${YELLOW}DAGSTER_HOME:${NC} ${DAGSTER_HOME}"
    if [ -d "${DAGSTER_HOME}" ]; then
        echo -e "${GREEN}DAGSTER_HOME directory exists.${NC}"
    else
        echo -e "${RED}DAGSTER_HOME directory does not exist.${NC}"
    fi
}

# Process command line arguments
case "$1" in
    start)
        start_dagster
        ;;
    stop)
        stop_dagster
        ;;
    restart)
        restart_dagster
        ;;
    status)
        status_dagster
        ;;
    port)
        check_port
        ;;
    help|--help|-h)
        show_usage
        ;;
    "")
        # No arguments provided, run interactive mode
        interactive_menu
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_usage
        exit 1
        ;;
esac

exit 0
