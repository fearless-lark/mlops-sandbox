#!/bin/bash
# MLflow Manager Script
# This script helps manage MLflow operations in Docker

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
MLFLOW_SERVER_PORT=${MLFLOW_SERVER_PORT:-5005}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
}

# Display header
display_header() {
    clear
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}             MLflow Manager Script            ${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${CYAN}            Port: ${MLFLOW_SERVER_PORT} | Date: $(date '+%Y-%m-%d')${NC}"
    echo
}

# Function to show usage for command line mode
show_usage() {
    echo -e "\n${YELLOW}Usage:${NC} $0 [command]"
    echo -e "\n${YELLOW}Commands:${NC}"
    echo -e "  ${GREEN}start${NC}      - Start MLflow server"
    echo -e "  ${GREEN}stop${NC}       - Stop MLflow server"
    echo -e "  ${GREEN}restart${NC}    - Restart MLflow server"
    echo -e "  ${GREEN}status${NC}     - Show MLflow server status"
    echo -e "  ${GREEN}logs${NC}       - Show MLflow server logs"
    echo -e "  ${GREEN}follow-logs${NC} - Follow MLflow server logs"
    echo -e "  ${GREEN}rebuild${NC}    - Rebuild MLflow Docker image"
    echo -e "  ${GREEN}clean${NC}      - Remove MLflow Docker container, network and prune system"
    echo -e "  ${GREEN}port${NC}       - Check if port ${MLFLOW_SERVER_PORT} is in use"
    echo -e "  ${GREEN}help${NC}       - Show this help message"
    echo -e "\n${YELLOW}Or run without arguments for interactive menu${NC}"
}

# Function to display current status line
display_status_line() {
    echo -e "${YELLOW}MLflow Status:${NC} $(get_mlflow_status)"
    echo -e "${YELLOW}Port ${MLFLOW_SERVER_PORT}:${NC} $(get_port_status)"
    echo
}

# Function for interactive menu
interactive_menu() {
    local choice
    
    while true; do
        display_header
        
        # Check and display MLflow status
        display_status_line
        
        echo -e "${BOLD}Select an option:${NC}"
        echo -e "${CYAN}1)${NC} Start MLflow server"
        echo -e "${CYAN}2)${NC} Stop MLflow server"
        echo -e "${CYAN}3)${NC} Restart MLflow server"
        echo -e "${CYAN}4)${NC} Show detailed status"
        echo -e "${CYAN}5)${NC} View logs"
        echo -e "${CYAN}6)${NC} Follow logs in real-time"
        echo -e "${CYAN}7)${NC} Rebuild Docker image"
        echo -e "${CYAN}8)${NC} Clean Docker resources"
        echo -e "${CYAN}9)${NC} Check port ${MLFLOW_SERVER_PORT} usage"
        echo -e "${CYAN}0)${NC} Exit"
        echo
        read -p "Enter your choice [0-9]: " choice
        
        case $choice in
            1) 
                clear
                start_mlflow
                
                # Show updated status after starting
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            2) 
                clear
                stop_mlflow
                
                # Show updated status after stopping
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            3) 
                clear
                restart_mlflow
                
                # Show updated status after restarting
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            4) 
                clear
                status_mlflow
                echo
                read -p "Press Enter to continue..."
                ;;
            5) 
                clear
                logs_mlflow
                echo
                read -p "Press Enter to continue..."
                ;;
            6) 
                clear
                echo -e "${YELLOW}Following logs in real-time. Press Ctrl+C to return to menu.${NC}"
                echo
                follow_logs_mlflow
                ;;
            7) 
                clear
                rebuild_mlflow
                echo
                read -p "Press Enter to continue..."
                ;;
            8) 
                clear
                clean_mlflow
                
                # Show updated status after cleaning
                echo -e "\n${BOLD}Updated Status:${NC}"
                display_status_line
                
                echo
                read -p "Press Enter to continue..."
                ;;
            9) 
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

# Get short MLflow status for menu display
get_mlflow_status() {
    # Give Docker a moment to update container status
    sleep 1
    
    if docker-compose ps 2>/dev/null | grep -q "mlflow.*Up"; then
        echo -e "${GREEN}Running${NC}"
    else
        # Double check with docker ps to be sure
        if docker ps --filter "name=mlops-sandbox-mlflow" --format "{{.Status}}" 2>/dev/null | grep -q "Up"; then
            echo -e "${GREEN}Running${NC}"
        else
            echo -e "${RED}Stopped${NC}"
        fi
    fi
}

# Get short port status for menu display
get_port_status() {
    # Give system a moment to update port status
    sleep 0.5
    
    if lsof -i :${MLFLOW_SERVER_PORT} > /dev/null 2>&1; then
        echo -e "${YELLOW}In Use${NC}"
    else
        echo -e "${GREEN}Available${NC}"
    fi
}

# Check if port 5005 is in use
check_port() {
    if lsof -i :${MLFLOW_SERVER_PORT} > /dev/null 2>&1; then
        echo -e "${YELLOW}Port ${MLFLOW_SERVER_PORT} is currently in use:${NC}"
        lsof -i :${MLFLOW_SERVER_PORT}
        return 0
    else
        echo -e "${GREEN}Port ${MLFLOW_SERVER_PORT} is available.${NC}"
        return 1
    fi
}

# Ensure port is available before starting
ensure_port_available() {
    if check_port; then
        read -p "Would you like to free port ${MLFLOW_SERVER_PORT} (y/n)? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Attempting to free port ${MLFLOW_SERVER_PORT}...${NC}"
            
            # Try to identify and stop the process
            local pid=$(lsof -i :${MLFLOW_SERVER_PORT} -t)
            if [[ -n "$pid" ]]; then
                echo -e "Stopping process with PID ${pid}"
                kill -15 "$pid" || { echo -e "${RED}Failed to stop process, trying force kill...${NC}"; kill -9 "$pid"; }
                sleep 2
                if lsof -i :${MLFLOW_SERVER_PORT} > /dev/null 2>&1; then
                    echo -e "${RED}Failed to free port ${MLFLOW_SERVER_PORT}. Please stop the process manually.${NC}"
                    return 1
                else
                    echo -e "${GREEN}Successfully freed port ${MLFLOW_SERVER_PORT}.${NC}"
                    return 0
                fi
            else
                echo -e "${RED}Could not identify the process using port ${MLFLOW_SERVER_PORT}.${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Operation cancelled. Port ${MLFLOW_SERVER_PORT} is still in use.${NC}"
            return 1
        fi
    fi
    return 0
}

# Start MLflow server
start_mlflow() {
    echo -e "${BLUE}Starting MLflow server...${NC}"
    check_docker
    
    if ! ensure_port_available; then
        echo -e "${RED}Cannot start MLflow server while port ${MLFLOW_SERVER_PORT} is in use.${NC}"
        return 1
    fi
    
    docker-compose up -d
    if [ $? -eq 0 ]; then
        # Wait a moment to give Docker time to fully start the container
        echo -e "${YELLOW}Waiting for MLflow server to initialize...${NC}"
        sleep 3
        
        # Verify that the container is actually running
        if docker-compose ps | grep -q "mlflow.*Up"; then
            echo -e "${GREEN}MLflow server started successfully.${NC}"
            echo -e "${GREEN}You can access the MLflow UI at http://localhost:${MLFLOW_SERVER_PORT}${NC}"
            
            # Try to check if the service responds
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:${MLFLOW_SERVER_PORT} 2>/dev/null | grep -q "200"; then
                echo -e "${GREEN}MLflow UI is responding properly.${NC}"
            else
                echo -e "${YELLOW}MLflow container is running but the UI might need more time to initialize.${NC}"
            fi
            
            return 0
        else
            echo -e "${RED}MLflow container failed to start properly. Check logs for details.${NC}"
            return 1
        fi
    else
        echo -e "${RED}Failed to start MLflow server.${NC}"
        return 1
    fi
}

# Stop MLflow server
stop_mlflow() {
    echo -e "${BLUE}Stopping MLflow server...${NC}"
    check_docker
    docker-compose down
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}MLflow server stopped successfully.${NC}"
    else
        echo -e "${RED}Failed to stop MLflow server.${NC}"
        return 1
    fi
}

# Restart MLflow server
restart_mlflow() {
    echo -e "${BLUE}Restarting MLflow server...${NC}"
    stop_mlflow && start_mlflow
}

# Check MLflow server status
status_mlflow() {
    echo -e "${BLUE}Checking MLflow server status...${NC}"
    check_docker
    
    if docker-compose ps | grep -q "mlflow"; then
        echo -e "${GREEN}MLflow server is running.${NC}"
        docker-compose ps
        
        # Check if service is actually responding
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:${MLFLOW_SERVER_PORT} | grep -q "200"; then
            echo -e "${GREEN}MLflow UI is accessible at http://localhost:${MLFLOW_SERVER_PORT}${NC}"
        else
            echo -e "${YELLOW}MLflow container is running but the UI is not responding.${NC}"
        fi
    else
        echo -e "${YELLOW}MLflow server is not running.${NC}"
    fi
    
    # Also check port status
    check_port
}

# Show MLflow server logs
logs_mlflow() {
    echo -e "${BLUE}Showing MLflow server logs...${NC}"
    check_docker
    docker-compose logs
}

# Follow MLflow server logs
follow_logs_mlflow() {
    echo -e "${BLUE}Following MLflow server logs (Ctrl+C to exit)...${NC}"
    check_docker
    docker-compose logs -f
}

# Rebuild MLflow Docker image
rebuild_mlflow() {
    echo -e "${BLUE}Rebuilding MLflow Docker image...${NC}"
    check_docker
    docker-compose build --no-cache
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}MLflow Docker image rebuilt successfully.${NC}"
        echo -e "${YELLOW}You may now start the MLflow server with: $0 start${NC}"
    else
        echo -e "${RED}Failed to rebuild MLflow Docker image.${NC}"
        return 1
    fi
}

# Clean MLflow Docker resources
clean_mlflow() {
    echo -e "${BLUE}Cleaning MLflow Docker resources...${NC}"
    check_docker
    
    echo -e "${YELLOW}Stopping and removing containers...${NC}"
    docker-compose down
    
    echo -e "${YELLOW}Removing MLflow images...${NC}"
    docker rmi $(docker images | grep mlops-sandbox-mlflow | awk '{print $3}') 2>/dev/null || true
    
    echo -e "${YELLOW}Pruning unused Docker resources...${NC}"
    docker system prune -f
    
    echo -e "${GREEN}Cleanup complete.${NC}"
}

# Process command line arguments
case "$1" in
    start)
        start_mlflow
        ;;
    stop)
        stop_mlflow
        ;;
    restart)
        restart_mlflow
        ;;
    status)
        status_mlflow
        ;;
    logs)
        logs_mlflow
        ;;
    follow-logs)
        follow_logs_mlflow
        ;;
    rebuild)
        rebuild_mlflow
        ;;
    clean)
        clean_mlflow
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
