#!/usr/bin/env bash

# Tool Installation Functions for dotfiles installer

# Development tools installation
install_development_tools() {
    log_header "Development Tools Installation"
    
    if ! get_yes_no "Install development tools?"; then
        log_warn "Skipping development tools installation"
        return
    fi
    
    # Define tools with descriptions and installation methods
    declare -A tools_info
    tools_info=(
        ["zoxide"]="autojump replacement"
        ["fzf"]="fuzzy search"
        ["fd"]="fuzzy directory search (requires fzf)"
        ["bat"]="fancy cat replacement"
        ["bat-extras"]=""
        ["1password-cli"]=""
        ["wezterm"]=""
        ["less"]=""
        ["git-delta"]=""
        ["nala"]=""
    )
    
    declare -A node_tools_info
    node_tools_info=(
        ["typescript"]=""
        ["@angular/cli"]=""
        ["lorem-ipsum-cli"]=""
        ["better-commits"]=""
    )

    declare -A zsh_plugins_info
    zsh_plugins_info=(
        ["forgit"]="Fancy git tools (requires fzf)"
        ["zsh-hist"]="History manipulation (used for some git aliases)"
    )
    
    # Core shell tools selection
    local core_tools=()
    local selected_tools=()
    
    log_info "Select core development tools to install:"
    echo
    
    # Build tool options with descriptions
    local tool_options=()
    for tool in zoxide fzf fd bat bat-extras git-delta wezterm less; do
        if [[ "${tools_info[$tool]}" ]]; then
            tool_options+=("$tool - ${tools_info[$tool]}")
        else
            tool_options+=("$tool")
        fi
        core_tools+=("$tool")
    done
    
    # Add platform-specific tools
    if [[ "${PLATFORM}" == "macos" ]]; then
        tool_options+=("1password-cli")
        core_tools+=("1password-cli")
    elif [[ "$UBUNTU" == true ]]; then
        if [[ "${tools_info["nala"]}" ]]; then
            tool_options+=("nala - ${tools_info["nala"]}")
        else
            tool_options+=("nala")
        fi
        core_tools+=("nala")
    fi
    
    show_multi_select_menu "Core Development Tools:" "${tool_options[@]}"
    local -a selected_indices
    mapfile -t selected_indices < <(get_multiple_choices ${#tool_options[@]})
    
    # Convert indices to selected tools
    for index in "${selected_indices[@]}"; do
        if [ "$index" -lt ${#core_tools[@]} ]; then
            selected_tools+=("${core_tools[$index]}")
        fi
    done
    
    # Install selected core tools
    if [ ${#selected_tools[@]} -gt 0 ]; then
        install_core_tools "${selected_tools[@]}"
    fi
    
    # Essential shell setup (install first so nvm is available for Node.js tools)
    install_shell_essentials

    # zsh plugins selection
    local zsh_plugins=(forgit zsh-hist)
    local selected_zsh_plugins=()
    
    log_info "Select zsh plugins to install:"
    echo
    
    local zsh_plugin_options=()
    for tool in "${zsh_plugins[@]}"; do
        if [[ "${zsh_plugins_info[$tool]}" ]]; then
            zsh_plugin_options+=("$tool - ${zsh_plugins_info[$tool]}")
        else
            zsh_plugin_options+=("$tool")
        fi
    done
    
    show_multi_select_menu "Zsh plugins:" "${zsh_plugin_options[@]}"
    local -a selected_zsh_plugin_indices
    mapfile -t selected_zsh_plugin_indices < <(get_multiple_choices ${#zsh_plugin_options[@]})
    
    # Convert indices to selected tools
    for index in "${selected_zsh_plugin_indices[@]}"; do
        if [ "$index" -lt ${#zsh_plugins[@]} ]; then
            selected_zsh_plugins+=("${zsh_plugins[$index]}")
        fi
    done
    
    # Install selected zsh plugins
    if [ ${#selected_zsh_plugins[@]} -gt 0 ]; then
        install_zsh_plugins "${selected_zsh_plugins[@]}"
    fi
    
    # Node.js tools selection
    local node_tools=(typescript @angular/cli lorem-ipsum-cli better-commits)
    local selected_node_tools=()
    
    log_info "Select Node.js development tools to install:"
    echo
    
    local node_options=()
    for tool in "${node_tools[@]}"; do
        if [[ "${node_tools_info[$tool]}" ]]; then
            node_options+=("$tool - ${node_tools_info[$tool]}")
        else
            node_options+=("$tool")
        fi
    done
    
    show_multi_select_menu "Node.js Development Tools:" "${node_options[@]}"
    local -a selected_node_indices
    mapfile -t selected_node_indices < <(get_multiple_choices ${#node_options[@]})
    
    # Convert indices to selected tools
    for index in "${selected_node_indices[@]}"; do
        if [ "$index" -lt ${#node_tools[@]} ]; then
            selected_node_tools+=("${node_tools[$index]}")
        fi
    done
    
    # Install selected Node.js tools
    if [ ${#selected_node_tools[@]} -gt 0 ]; then
        install_node_tools "${selected_node_tools[@]}"
    fi
}

# Install core development tools based on platform
install_core_tools() {
    local tools=("$@")
    log_info "Installing core tools: ${tools[*]}"
    
    for tool in "${tools[@]}"; do
        log_info "Installing $tool..."
        
        case "$tool" in
            "zoxide")
                if [[ "${PLATFORM}" == "macos" ]]; then
                    brew install zoxide
                else
                    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
                fi
                ;;
            "fzf"|"fd"|"bat"|"less"|"git-delta"|"wezterm")
                if [[ "${PLATFORM}" == "macos" ]]; then
                    brew install "$tool"
                else
                    sudo apt update && sudo apt install -y "$tool"
                fi
                ;;
            "bat-extras")
                if [[ "${PLATFORM}" == "macos" ]]; then
                    brew install bat-extras
                else
                    log_warn "bat-extras not available via apt, skipping"
                fi
                ;;
            "1password-cli")
                if [[ "${PLATFORM}" == "macos" ]]; then
                    brew install "1password-cli"
                else
                    log_warn "1password-cli only supported on macOS"
                fi
                ;;
            "nala")
                if [[ "$UBUNTU" == true ]]; then
                    sudo apt update && sudo apt install -y nala
                else
                    log_warn "nala only supported on Ubuntu"
                fi
                ;;
            *)
                log_warn "Unknown tool: $tool"
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            log_success "$tool installed successfully"
        else
            log_error "Failed to install $tool"
        fi
    done
}

install_zsh_plugins() {
    local tools=("$@")
    log_info "Installing zsh plugins: ${tools[*]}"
        for tool in "${tools[@]}"; do
        log_info "Installing $tool..."
        
        case "$tool" in
            "forgit")
                if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit" ]]; then
                    log_info "forgit directory already exists, skipping"
                else
                    git clone https://github.com/wfxr/forgit.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit
                fi
                ;;
            "zsh-hist")
                if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-hist" ]]; then
                    log_info "zsh-hist directory already exists, skipping"
                else
                    git clone https://github.com/marlonrichert/zsh-hist.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-hist
                fi
                ;;
            *)
                log_warn "Unknown tool: $tool"
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            log_success "$tool installed successfully"
        else
            log_error "Failed to install $tool"
        fi
    done
}

# Install Node.js development tools
install_node_tools() {
    local tools=("$@")
    log_info "Installing Node.js tools: ${tools[*]}"
    
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        log_error "npm not found. Please install Node.js/nvm first"
        return 1
    fi
    
    for tool in "${tools[@]}"; do
        log_info "Installing $tool globally..."
        npm install -g "$tool"
        
        if [ $? -eq 0 ]; then
            log_success "$tool installed successfully"
        else
            log_error "Failed to install $tool"
        fi
    done
}

# Install essential shell setup tools
install_shell_essentials() {
    log_header "Essential Shell Setup"
    
    # Install Oh My Zsh
    if [ -d "$ZSH" ]; then
        log_info "Oh My Zsh already installed, skipping"
    else
        if get_yes_no "Install Oh My Zsh?"; then
            log_info "Installing Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            log_success "Oh My Zsh installed"
            
            # Remove existing zshrc if it exists (Oh My Zsh creates one)
            if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
                log_info "Removing Oh My Zsh default .zshrc"
                rm ~/.zshrc
            fi
        fi
    fi
    
    # Install nvm
    if command -v nvm &> /dev/null; then
        log_info "nvm already installed, skipping"
    else
        if get_yes_no "Install nvm (Node Version Manager)?"; then
            log_info "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
            log_success "nvm installed"
        fi
    fi
}