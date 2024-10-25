#!/bin/zsh

# Function to check GitHub SSH connection
check_github_connection() {
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
        echo "Error: SSH key with this name already exists!"
        return 1
    fi

    echo "Enter your email for this SSH key:"
    read "email?"

    ssh-keygen -t rsa -b 4096 -f "$key_path" -C "$email"
    chmod 600 "$key_path"

    echo "SSH key created: $key_path"
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
    keys=($(find "$SSH_DIR" -type f ! -name "*.pub"))
    
    if [ ${#keys} -eq 0 ]; then
        echo "No SSH keys found in $SSH_DIR"
        return 1
    fi
    
    echo "Available SSH keys:"
    integer i=0
    for key in $keys; do
        key_name=$(basename "$key")
        echo "[$i] $key_name"
        ((i++))
    done
    
    echo ""
    echo "Select key index (0-$((${#keys}-1))):"
    read "selection?"

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#keys}" ]; then
        echo "Invalid selection"
        return 1
    fi
    
    selected_key="${keys[$((selection+1))]}"

    echo ""
    echo "Choose a host for this SSH key:"
    echo "[0] github.com"
    echo "[1] gitlab.kiaisoft.com"
    echo "[2] Enter custom domain"
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
            echo "Invalid selection"
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
    
    echo "Current SSH configuration (Hosts):"
    if [ -f "$CONFIG_FILE" ]; then
        # Use grep to extract only the Host entries
        grep -E '^Host ' "$CONFIG_FILE"
        
        # Extract IdentityFile entries
        echo ""
        echo "Configured IdentityFiles:"
        grep -E '^ *IdentityFile ' "$CONFIG_FILE" | awk '{print $2}' | xargs -n 1 basename
    else
        echo "No SSH config file found."
    fi
}

# Function to list, select, and remove an SSH key and its config
remove_ssh_key() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"
    
    if [ ! -d "$SSH_DIR" ]; then
        echo "No SSH directory found."
        return 1
    fi

    # List available SSH keys (excluding .pub files)
    typeset -a keys
    keys=($(find "$SSH_DIR" -type f ! -name "*.pub"))
    
    if [ ${#keys} -eq 0 ]; then
        echo "No SSH keys found in $SSH_DIR."
        return 1
    fi
    
    echo "Available SSH keys:"
    integer i=0
    for key in $keys; do
        key_name=$(basename "$key")
        echo "[$i] $key_name"
        ((i++))
    done
    
    # Select SSH key to remove
    echo ""
    echo "Select key index to remove (0-$((${#keys}-1))):"
    read "selection?"

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#keys}" ]; then
        echo "Invalid selection."
        return 1
    fi
    
    selected_key="${keys[$((selection+1))]}"
    selected_key_basename=$(basename "$selected_key")

    # Confirm deletion of the key file
    echo "Are you sure you want to delete SSH key $selected_key_basename? (y/n)"
    read "confirm?"
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted deletion."
        return 1
    fi

    # Remove the SSH key file
    rm -f "$selected_key" "$selected_key.pub"
    echo "Removed SSH key: $selected_key_basename"

    # Remove any host configuration in config file using this key
    if [ -f "$CONFIG_FILE" ]; then
        # Backup config file before making changes
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        
        # Remove existing config block for the selected host, if present
        sed -i.bak "/^Host $host$/,/^Host /{//!d; /^Host $host$/d;}" "$CONFIG_FILE"
        
        echo "Removed SSH key configuration for IdentityFile: $selected_key"
    else
        echo "No SSH config file found."
    fi
}

# Aliases for convenience
alias sshm="ssh_key_manager"
alias sshp="check_github_connection"
alias sshnew="create_ssh_key"
alias sshc="show_ssh_info"
alias sshrm="remove_ssh_key"

