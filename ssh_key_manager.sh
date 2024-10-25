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
    
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    fi
    
    cat > "$CONFIG_FILE" << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile $selected_key
    PreferredAuthentications publickey
    IdentitiesOnly yes

Host *
    IdentityFile $selected_key
    PreferredAuthentications publickey
    IdentitiesOnly yes
EOF
    
    chmod 600 "$CONFIG_FILE"
    
    echo ""
    echo "Test GitHub connection? (y/n)"
    read "check_connection?"
    if [[ "$check_connection" =~ ^[Yy]$ ]]; then
        check_github_connection
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



alias sshm="ssh_key_manager"
alias sshp="check_github_connection"
alias sshnew="create_ssh_key"
alias sshc="show_ssh_info"
