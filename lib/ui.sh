#!/usr/bin/env bash

# UI and Menu Functions for dotfiles installer

# Function to display menu and get user selection
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo -e "\n${CYAN}$title${NC}"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[i]}"
    done
    echo
}

# Function to get user choice
get_choice() {
    local max=$1
    local choice
    while true; do
        read -p "Select option (1-$max): " choice
        if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ]; then
            echo $((choice-1))
            return
        else
            log_error "Invalid selection. Please choose 1-$max."
        fi
    done
}

# Function to get yes/no answer
get_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local answer
    
    while true; do
        if [ "$default" = "y" ]; then
            read -p "$prompt (Y/n): " answer
            answer=${answer:-y}
        else
            read -p "$prompt (y/N): " answer
            answer=${answer:-n}
        fi
        
        case $answer in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) log_error "Please answer yes or no." ;;
        esac
    done
}

# Function to show multi-select menu
show_multi_select_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo -e "\n${CYAN}$title${NC}"
    echo "Select items (space-separated numbers, e.g., '1 3 5'):"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[i]}"
    done
    echo "  $((${#options[@]}+1)). All items"
    echo "  $((${#options[@]}+2)). None (skip)"
    echo
}

# Function to get multiple choices
get_multiple_choices() {
    local max=$1
    local choices_input
    local -a selected_indices=()
    
    while true; do
        read -p "Select options (space-separated): " choices_input
        
        if [[ -z "$choices_input" ]]; then
            log_error "Please enter at least one selection."
            continue
        fi
        
        # Handle "All" and "None" special cases
        local all_option=$((max+1))
        local none_option=$((max+2))
        
        if [[ "$choices_input" == "$all_option" ]]; then
            # Return all indices from 0 to max-1
            for ((i=0; i<max; i++)); do
                selected_indices+=($i)
            done
            break
        elif [[ "$choices_input" == "$none_option" ]]; then
            # Return empty array (no selections)
            break
        fi
        
        # Parse space-separated numbers
        local valid=true
        selected_indices=()
        
        for choice in $choices_input; do
            if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ]; then
                selected_indices+=($((choice-1)))
            else
                log_error "Invalid selection: $choice. Please choose 1-$max, $all_option (all), or $none_option (none)."
                valid=false
                break
            fi
        done
        
        if [ "$valid" = true ]; then
            break
        fi
    done
    
    # Return unique sorted indices
    printf '%s\n' "${selected_indices[@]}" | sort -nu
}