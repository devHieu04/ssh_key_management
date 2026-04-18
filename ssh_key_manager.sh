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


# Function to copy selected SSH public key to clipboard
copy_ssh_key() {
    SSH_DIR="$HOME/.ssh"
    
    # Create SSH directory if it doesn't exist
    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi
    
    # Find public SSH keys
    typeset -a keys
    keys=($(find "$SSH_DIR" -type f -name "*.pub"))
    
    # Check if any public keys exist
    if [ ${#keys} -eq 0 ]; then
        echo -e "${PURPLE}No SSH public keys found in $SSH_DIR${NC}"
        return 1
    fi
    
    # Display available SSH public keys
    echo -e "${CYAN}Available SSH public keys:${NC}"
    integer i=0
    for key in "${keys[@]}"; do
        key_name=$(basename "$key")
        echo -e "${GREEN}[$i] $key_name${NC}"
        ((i++))
    done
    
    # Prompt user to select a key index
    echo ""
    echo "Select key index to copy its public key (0-$((${#keys}-1))):"
    read "selection?"

    # Validate selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#keys}" ]; then
        echo -e "${PURPLE}Invalid selection.${NC}"
        return 1
    fi

    # Get the selected public key
    selected_key="${keys[$selection]}"

    # Attempt to use pbcopy for macOS
    if command -v pbcopy &> /dev/null; then
        pbcopy < "$selected_key"
        echo -e "${GREEN}Copied SSH public key to clipboard: ${selected_key}${NC}"
    # Attempt to use xclip for Linux
    elif command -v xclip &> /dev/null; then
        xclip -sel clip < "$selected_key"
        echo -e "${GREEN}Copied SSH public key to clipboard: ${selected_key}${NC}"
    # Attempt to use xsel for Linux
    elif command -v xsel &> /dev/null; then
        xsel --clipboard < "$selected_key"
        echo -e "${GREEN}Copied SSH public key to clipboard: ${selected_key}${NC}"
    else
        echo -e "${PURPLE}No clipboard command found. Unable to copy to clipboard.${NC}"
        return 1
    fi
}

ssh_key_list() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"

    # Create SSH directory if it doesn't exist
    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi

    # Find private SSH keys in the directory
    typeset -a keys
    keys=($(find "$SSH_DIR" -type f ! -name "*.pub" ! -name "config*" ! -name "known_hosts*" ! -name "authorized_keys"))

    if [ ${#keys[@]} -eq 0 ]; then
        echo -e "${PURPLE}No SSH keys found in $SSH_DIR${NC}"
        return 1
    fi

    # Display available SSH keys
    echo -e "${CYAN}Available SSH keys:${NC}"
    integer i=0
    for key in "${keys[@]}"; do
        key_name=$(basename "$key")
        echo -e "${GREEN}[$i] $key_name${NC}"
        ((i++))
    done

    return 0
}

# Function to list SSH keys and configured hosts together
ssh_list_all() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"

    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi

    typeset -a keys
    keys=($(find "$SSH_DIR" -type f ! -name "*.pub" ! -name "config*" ! -name "known_hosts*" ! -name "authorized_keys"))

    echo -e "${CYAN}Available SSH keys:${NC}"
    if [ ${#keys[@]} -eq 0 ]; then
        echo -e "${PURPLE}  (none found in $SSH_DIR)${NC}"
    else
        integer i=0
        for key in "${keys[@]}"; do
            key_name=$(basename "$key")
            echo -e "${GREEN}[$i] $key_name${NC}"
            ((i++))
        done
    fi

    echo ""
    echo -e "${CYAN}Available hosts:${NC}"
    echo -e "${GREEN}  github${NC}  -> github.com"
    echo -e "${GREEN}  gitlab${NC}  -> gitlab.com"
    echo -e "${GREEN}  <custom>${NC} -> any custom domain (e.g. sshm 0 git.example.com)"

    if [ -f "$CONFIG_FILE" ]; then
        echo ""
        echo -e "${CYAN}Currently configured hosts in $CONFIG_FILE:${NC}"
        grep -E '^Host ' "$CONFIG_FILE" | awk '{print "  " $2}'
    fi

    echo ""
    echo -e "${CYAN}Usage:${NC} sshm <key_index> <host>"
    echo -e "${CYAN}Example:${NC} sshm 0 github   |   sshm 2 gitlab   |   sshm 1 git.example.com"
}

# Resolve a host alias/shortname to a full domain
# github -> github.com, gitlab -> gitlab.com, anything else is used as-is
_resolve_host() {
    case "$1" in
        github|gh)      echo "github.com" ;;
        gitlab|gl)      echo "gitlab.com" ;;
        bitbucket|bb)   echo "bitbucket.org" ;;
        "") echo "" ;;
        *)  echo "$1" ;;
    esac
}

# Parse the authenticated username out of `ssh -T git@<host>` output.
# GitHub:    "Hi <name>! You've successfully authenticated..."
# GitLab:    "Welcome to GitLab, @<name>!"
# Bitbucket: "logged in as <name>."
_extract_git_username() {
    local host="$1" output="$2" name=""
    case "$host" in
        github.com|ssh.github.com|*.github.com)
            name=$(echo "$output" | sed -n 's/.*Hi \([A-Za-z0-9_.\-]*\)!.*/\1/p' | head -n 1)
            ;;
        gitlab.com|*.gitlab.com)
            name=$(echo "$output" | sed -n 's/.*Welcome to GitLab, @\([A-Za-z0-9_.\-]*\)!.*/\1/p' | head -n 1)
            ;;
        bitbucket.org|*.bitbucket.org)
            name=$(echo "$output" | sed -n 's/.*logged in as \([A-Za-z0-9_.\-]*\)\..*/\1/p' | head -n 1)
            ;;
    esac
    echo "$name"
}

# Extract the trailing comment (usually an email) from a .pub key file.
_extract_pubkey_email() {
    local priv_key="$1"
    local pub="${priv_key}.pub"
    [ -f "$pub" ] || return 0
    awk '{print $NF}' "$pub"
}

# Function to manage SSH keys
# Usage:
#   sshm                       -> interactive mode
#   sshm <key_index> <host>    -> direct mode, e.g. sshm 0 github | sshm 2 git.example.com
ssh_key_manager() {
    SSH_DIR="$HOME/.ssh"
    CONFIG_FILE="$SSH_DIR/config"

    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi

    typeset -a keys
    keys=($(find "$SSH_DIR" -type f ! -name "*.pub" ! -name "config*" ! -name "known_hosts*" ! -name "authorized_keys"))

    if [ ${#keys} -eq 0 ]; then
        echo -e "${PURPLE}No SSH keys found in $SSH_DIR${NC}"
        return 1
    fi

    local arg_index="$1"
    local arg_host="$2"
    local selection host selected_key

    if [[ -n "$arg_index" && -n "$arg_host" ]]; then
        # Direct mode: sshm <index> <host>
        if ! [[ "$arg_index" =~ ^[0-9]+$ ]] || [ "$arg_index" -ge "${#keys}" ]; then
            echo -e "${PURPLE}Invalid key index: $arg_index (run 'sshl' to list keys)${NC}"
            return 1
        fi
        selection="$arg_index"
        host="$(_resolve_host "$arg_host")"
    else
        # Interactive mode
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

        echo ""
        echo -e "${CYAN}Choose a host for this SSH key:${NC}"
        echo -e "${GREEN}[0] github.com${NC}"
        echo -e "${GREEN}[1] gitlab.com${NC}"
        echo -e "${GREEN}[2] Enter custom domain${NC}"
        read "host_selection?"

        case "$host_selection" in
            0) host="github.com" ;;
            1) host="gitlab.com" ;;
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
    fi

    if [[ -z "$host" ]]; then
        echo -e "${PURPLE}Host is empty${NC}"
        return 1
    fi

    selected_key="${keys[$((selection+1))]}"

    # Backup current config file
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    fi

    # Remove existing config block for the selected host, if present
    if [ -f "$CONFIG_FILE" ]; then
        sed -i.bak "/^Host $host$/,/^Host /{//!d; /^Host $host$/d;}" "$CONFIG_FILE"
    fi

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

    echo -e "${GREEN}Switched host '${host}' -> $(basename "$selected_key")${NC}"

    # Always ping so we can extract the authenticated username, then apply
    # it (plus the email from the .pub comment) to git config.
    echo ""
    echo -e "${PURPLE}Testing SSH connection to $host...${NC}"
    local ssh_output
    ssh_output=$(ssh -T -o StrictHostKeyChecking=accept-new "git@$host" 2>&1)
    echo "$ssh_output"

    local git_user git_email scope="--local"
    git_user=$(_extract_git_username "$host" "$ssh_output")
    git_email=$(_extract_pubkey_email "$selected_key")

    echo ""
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${PURPLE}Not inside a git repository — skipped updating git config (--local).${NC}"
        [[ -n "$git_user" ]]  && echo -e "${PURPLE}  would have set user.name  = $git_user${NC}"
        [[ -n "$git_email" && "$git_email" == *@* ]] && echo -e "${PURPLE}  would have set user.email = $git_email${NC}"
        return 0
    fi

    if [[ -n "$git_user" ]]; then
        git config $scope user.name "$git_user"
        echo -e "${GREEN}git config $scope user.name  = $git_user${NC}"
    else
        echo -e "${PURPLE}Could not detect username from $host response; skipped user.name${NC}"
    fi

    if [[ -n "$git_email" && "$git_email" == *@* ]]; then
        git config $scope user.email "$git_email"
        echo -e "${GREEN}git config $scope user.email = $git_email${NC}"
    else
        echo -e "${PURPLE}No email-like comment in ${selected_key}.pub; skipped user.email${NC}"
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
    echo -e "${GREEN}sshm${NC} - Manage SSH keys (interactive). Direct mode: ${CYAN}sshm <key_index> <host>${NC} (e.g. sshm 0 github)"
    echo -e "${GREEN}sshl${NC} - List SSH keys and available hosts"
    echo -e "${GREEN}sshp${NC} - Check GitHub SSH connection"
    echo -e "${GREEN}sshnew${NC} - Create a new SSH key"
    echo -e "${GREEN}sshc${NC} - Show current SSH configuration and keys"
    echo -e "${GREEN}sshrm${NC} - Remove an SSH key and its config"
    echo -e "${GREEN}ssh_help${NC} - Show this help information"
    echo -e "${GREEN}ssh_copy${NC} - ssh copy publish key"
    echo -e "${GREEN}list_ssh_keys${NC} - list ssh keys"
}

# Aliases for convenience
alias ssh_help="show_help"
alias list_ssh_keys="ssh_key_list"
alias sshl="ssh_list_all"
alias sshm="ssh_key_manager"
alias sshp="check_github_connection"
alias sshnew="create_ssh_key"
alias sshc="show_ssh_info"
alias sshrm="remove_ssh_key"
alias ssh_copy="copy_ssh_key"
