#!/usr/bin/env bash

# Core Dotfiles Functions for dotfiles installer

# Function to clean home directory (equivalent to dotbot clean)
clean_home() {
    log_header "Cleaning Home Directory"
    log_info "This will remove broken symlinks from your home directory"
    
    if get_yes_no "Proceed with cleaning home directory?"; then
        log_info "Removing broken symlinks from $HOME..."
        find "$HOME" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true
        log_success "Home directory cleaned"
    else
        log_warn "Skipping home directory cleaning"
    fi
}

# Function to create symlinks (equivalent to dotbot link)
create_symlinks() {
    log_header "Creating Symlinks"
    
    declare -A symlinks
    symlinks=(
        ["$HOME/.gitconfig"]="gitconfig"
        ["$HOME/.zshrc"]=".zshrc"
        ["$HOME/.better-commits.json"]=".better-commits.json"
        ["$HOME/.wezterm.lua"]=".wezterm.lua"
        ["$HOME/.oh-my-posh.json"]=".oh-my-posh.json"
        ["$HOME/.config/atuin/config.toml"]="atuin.config.toml"
    )
    
    local selected_links=()
    
    log_info "Select which configuration files to symlink:"
    echo
    
    local link_options=()
    local link_targets=()
    local link_sources=()
    
    for target in "${!symlinks[@]}"; do
        source="${symlinks[$target]}"
        link_options+=("$(basename "$target") -> $source")
        link_targets+=("$target")
        link_sources+=("$source")
    done
    
    link_options+=("All configuration files")
    link_options+=("None (skip symlinks)")
    
    show_menu "Configuration Files:" "${link_options[@]}"
    local choice=$(get_choice ${#link_options[@]})
    
    if [ $choice -eq $((${#link_options[@]}-1)) ]; then
        log_warn "Skipping symlink creation"
        return
    elif [ $choice -eq $((${#link_options[@]}-2)) ]; then
        selected_links=("${!symlinks[@]}")
    else
        selected_links=("${link_targets[$choice]}")
    fi
    
    for target in "${selected_links[@]}"; do
        source="${symlinks[$target]}"
        source_path="$BASEDIR/$source"
        
        if [ ! -f "$source_path" ]; then
            log_error "Source file $source_path does not exist, skipping $target"
            continue
        fi
        
        # Create directory if it doesn't exist
        target_dir=$(dirname "$target")
        if [ ! -d "$target_dir" ]; then
            log_info "Creating directory $target_dir"
            mkdir -p "$target_dir"
        fi
        
        # Remove existing file/link
        if [ -e "$target" ] || [ -L "$target" ]; then
            log_info "Removing existing $target"
            rm -f "$target"
        fi
        
        # Create symlink
        log_info "Creating symlink: $target -> $source_path"
        ln -s "$source_path" "$target"
        log_success "Created symlink for $(basename "$target")"
    done
}

# Function to run shell commands (equivalent to dotbot shell)
run_shell_commands() {
    log_header "Shell Commands"
    
    local commands=(
        "Change shell to zsh"
        "Create .hushfile"
        "All commands"
        "None (skip shell commands)"
    )
    
    show_menu "Shell Commands:" "${commands[@]}"
    local choice=$(get_choice ${#commands[@]})
    
    case $choice in
        0) # Change shell to zsh
            if [[ $SHELL != "/bin/zsh" ]]; then
                log_info "Changing shell to zsh..."
                sudo chsh -s /bin/zsh $(whoami)
                log_success "Shell changed to zsh"
            else
                log_info "Shell is already zsh"
            fi
            ;;
        1) # Create .hushfile
            log_info "Creating .hushfile..."
            touch ~/.hushfile
            log_success "Created .hushfile"
            ;;
        2) # All commands
            if [[ $SHELL != "/bin/zsh" ]]; then
                log_info "Changing shell to zsh..."
                sudo chsh -s /bin/zsh $(whoami)
                log_success "Shell changed to zsh"
            else
                log_info "Shell is already zsh"
            fi
            log_info "Creating .hushfile..."
            touch ~/.hushfile
            log_success "Created .hushfile"
            ;;
        3) # None
            log_warn "Skipping shell commands"
            ;;
    esac
}

# Main installation menu
main_menu() {
    log_header "Dotfile Installation Menu"
    
    local main_options=(
        "Complete installation (clean + symlinks + shell commands)"
        "Custom installation (choose components)"
        "Exit"
    )
    
    show_menu "Installation Options:" "${main_options[@]}"
    local choice=$(get_choice ${#main_options[@]})
    
    case $choice in
        0) # Complete installation
            clean_home
            create_symlinks
            run_shell_commands
            ;;
        1) # Custom installation
            local custom_options=(
                "Clean home directory"
                "Create symlinks"
                "Run shell commands"
                "Done"
            )
            
            while true; do
                show_menu "Select components to install:" "${custom_options[@]}"
                local custom_choice=$(get_choice ${#custom_options[@]})
                
                case $custom_choice in
                    0) clean_home ;;
                    1) create_symlinks ;;
                    2) run_shell_commands ;;
                    3) break ;;
                esac
            done
            ;;
        2) # Exit
            log_info "Installation cancelled"
            exit 0
            ;;
    esac
}