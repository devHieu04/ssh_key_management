#!/bin/zsh

# Colors
GREEN="\033[0;32m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
NC="\033[0m" # No Color

# Function to check GitHub SSH connection
check_github_connection() {
    echo -e "${PURPLE}Testing GitHub SSH connection...${NC}"
    ssh -T git@github.com
    return $?
}

# Function to create a new SSH key
create_ssh_key() {
    SSH_DIR="$HOME/.ssh"
    
    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi
    
    echo "Enter the name for your new SSH key (without extension):"
    read "key_name?"

    key_path="$SSH_DIR/$key_name"

    if [ -f "$key_path" ]; then
        echo -e "${PURPLE}Error: SSH key with this name already exists!${NC}"
        return 1
    fi

    echo "Enter your email for this SSH key:"
    read "email?"

    ssh-keygen -t rsa -b 4096 -f "$key_path" -C "$email"
    chmod 600 "$key_path"

    echo -e "${PURPLE}SSH key created: $key_path${NC}"
}

# Function to manage SSH keys
ssh_key_manager() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"
    
    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi
    
    typeset -a keys
    keys=($(find "$SSH_DIR" -type f  -name "*.pub"))
    
    if [ ${#keys} -eq 0 ]; then
        echo -e "${PURPLE}No SSH keys found in $SSH_DIR${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Available SSH keys:${NC}"
    integer i=0
    for key in $keys; do
        key_name=$(basename "$key")
        echo -e "${GREEN}[$i] $key_name${NC}"
        ((i++))
    done
    
    echo ""
    echo "Select key index (0-$((${#keys}-1))):"
    read "selection?"

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#keys}" ]; then
        echo -e "${PURPLE}Invalid selection${NC}"
        return 1
    fi
    
    selected_key="${keys[$((selection+1))]}"

    echo ""
    echo -e "${CYAN}Choose a host for this SSH key:${NC}"
    echo -e "${GREEN}[0] github.com${NC}"
    echo -e "${GREEN}[1] gitlab.kiaisoft.com${NC}"
    echo -e "${GREEN}[2] Enter custom domain${NC}"
    read "host_selection?"

    case "$host_selection" in
        0)
            host="github.com"
            ;;
        1)
            host="gitlab.kiaisoft.com"
            ;;
        2)
            echo "Enter the custom domain:"
            read "custom_domain?"
            host="$custom_domain"
            ;;
        *)
            echo -e "${PURPLE}Invalid selection${NC}"
            return 1
            ;;
    esac

    # Backup current config file
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    fi
    
    # Remove existing config block for the selected host, if present
    sed -i.bak "/^Host $host$/,/^Host /{//!d; /^Host $host$/d;}" "$CONFIG_FILE"

    # Append the new configuration for the selected host
    cat >> "$CONFIG_FILE" << EOF
Host $host
    HostName $host
    User git
    IdentityFile $selected_key
    PreferredAuthentications publickey
    IdentitiesOnly yes
EOF
    
    chmod 600 "$CONFIG_FILE"
    
    echo ""
    echo "Test connection to $host? (y/n)"
    read "check_connection?"
    if [[ "$check_connection" =~ ^[Yy]$ ]]; then
        ssh -T "git@$host"
    fi
}

# Function to display current SSH config and keys
show_ssh_info() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"
    
    echo -e "${CYAN}Current SSH configuration (Hosts):${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        grep -E '^Host ' "$CONFIG_FILE"
        echo ""
        echo -e "${CYAN}Configured IdentityFiles:${NC}"
        grep -E '^ *IdentityFile ' "$CONFIG_FILE" | awk '{print $2}' | xargs -n 1 basename
    else
        echo -e "${PURPLE}No SSH config file found.${NC}"
    fi
}

# Function to list, select, and remove an SSH key and its config
remove_ssh_key() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"
    
    if [ ! -d "$SSH_DIR" ]; then
        echo -e "${PURPLE}No SSH directory found.${NC}"
        return 1
    fi

    # List available SSH keys (excluding .pub files)
    typeset -a keys
    keys=($(find "$SSH_DIR" -type f  -name "*.pub"))
    
    if [ ${#keys} -eq 0 ]; then
        echo -e "${PURPLE}No SSH keys found in $SSH_DIR.${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Available SSH keys:${NC}"
    integer i=0
    for key in $keys; do
        key_name=$(basename "$key")
        echo -e "${GREEN}[$i] $key_name${NC}"
        ((i++))
    done
    
    echo ""
    echo "Select key index to remove (0-$((${#keys}-1))):"
    read "selection?"

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#keys}" ]; then
        echo -e "${PURPLE}Invalid selection.${NC}"
        return 1
    fi
    
    selected_key="${keys[$((selection+1))]}"
    selected_key_basename=$(basename "$selected_key")

    echo "Are you sure you want to delete SSH key $selected_key_basename? (y/n)"
    read "confirm?"
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${PURPLE}Aborted deletion.${NC}"
        return 1
    fi

    rm -f "$selected_key" "$selected_key.pub"
    echo -e "${PURPLE}Removed SSH key: $selected_key_basename${NC}"

    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        sed -i.bak "/^Host $host$/,/^Host /{//!d; /^Host $host$/d;}" "$CONFIG_FILE"
        echo -e "${PURPLE}Removed SSH key configuration for IdentityFile: $selected_key${NC}"
    else
        echo -e "${PURPLE}No SSH config file found.${NC}"
    fi
}
# Function to display help information
show_help() {
    echo -e "${PURPLE}Available Commands:${NC}"
    echo -e "${GREEN}sshm${NC} - Manage SSH keys"
    echo -e "${GREEN}sshp${NC} - Check GitHub SSH connection"
    echo -e "${GREEN}sshnew${NC} - Create a new SSH key"
    echo -e "${GREEN}sshc${NC} - Show current SSH configuration and keys"
    echo -e "${GREEN}sshrm${NC} - Remove an SSH key and its config"
    echo -e "${GREEN}help${NC} - Show this help information"
}

# Aliases for convenience
alias ssh_help="show_help"
alias sshm="ssh_key_manager"
alias sshp="check_github_connection"
alias sshnew="create_ssh_key"
alias sshc="show_ssh_info"
alias sshrm="remove_ssh_key"
