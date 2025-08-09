#!/usr/bin/env bash

# Utility Functions for dotfiles installer

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "\n${PURPLE}=== $1 ===${NC}\n"
}

# System detection and setup
detect_system() {
    log_header "System Detection"
    
    if [[ ! "${CODESPACES}" == true ]]; then
        local os_options=("Linux (Ubuntu)" "Linux" "MacOS")
        show_menu "Select your operating system:" "${os_options[@]}"
        local os_choice=$(get_choice ${#os_options[@]})
        
        case $os_choice in
            0)
                PLATFORM="linux"
                UBUNTU=true
                ;;
            1)
                PLATFORM="linux"
                ;;
            2)
                PLATFORM="macos"
                ;;
        esac
        
        local domain_options=("Personal" "Work")
        show_menu "Select domain:" "${domain_options[@]}"
        local domain_choice=$(get_choice ${#domain_options[@]})
        
        case $domain_choice in
            0) DOMAIN="personal" ;;
            1) DOMAIN="work" ;;
        esac
        
        if [[ "${DOMAIN}" == "work" ]]; then
            read -p "What email address should be used for git? " work_email
            EMAIL=$work_email
        fi
        
        if [[ "${PLATFORM}" == "linux" ]]; then
            if get_yes_no "Is this a WSL linux installation?"; then
                WSL=true
            fi
        fi
    fi
    
    log_info "Platform: $PLATFORM"
    log_info "Domain: $DOMAIN"
    log_info "Email: $EMAIL"
    if [[ "$PLATFORM" == "linux" ]]; then
        log_info "Ubuntu: $UBUNTU"
        log_info "WSL: $WSL"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_header "Checking Prerequisites"
    
    # Check for homebrew on macOS
    if [[ "${PLATFORM}" == "macos" ]] && ! command -v brew &> /dev/null; then
        log_error "Homebrew not found. Please install it first:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    
    # Check for zsh
    if ! command -v zsh &> /dev/null; then
        log_error "zsh could not be found, install it first"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Post-installation recommendations
show_recommendations() {
    log_header "Post-Installation Setup"
    
    # Set git email
    log_info "Setting git email to ${EMAIL}"
    git config --global user.email "${EMAIL}"
    
    log_info "Additional setup scripts you may want to run:"
    echo "  scripts/wezterm.sh"
    echo "  scripts/bat-theme.sh"
    echo "  scripts/zsh-plugins.sh"
    echo "  cp loopy.zsh-theme \${ZSH_CUSTOM}/themes/loopy.zsh-theme"
    echo "  ln -s \${BASEDIR}/espanso \$(espanso path config)"
}