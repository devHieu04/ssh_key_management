# SSH Key Manager

`ssh_key_manager` is a powerful utility tool designed to simplify the management and usage of SSH keys. With this tool, you can easily manage, create, and switch between SSH keys, ensuring secure and efficient communication with remote services like GitHub, GitLab, and more.

## Installation

### Step 1: Clone the repository

To begin, you need to clone the repository to your local machine. Open the terminal and run the following command:

```bash
curl -O https://raw.githubusercontent.com/devHieu04/ssh_key_management/main/ssh_key_manager.sh
```

### Step 2: Grant execution permission for `ssh_key_manager.sh`

Next, you need to grant execution permissions for the script:

```bash
chmod +x ssh_key_manager.sh
```

### Step 3: Configure `~/.zshrc`

Open the `~/.zshrc` configuration file and add the following line at the end of the file:

#### For macOS:

```bash
nano ~/.zshrc
# Add this line to the end of the file
source ~/.ssh_key_manager.sh
```

#### For Linux (Ubuntu):

```bash
nano ~/.zshrc
# Add this line to the end of the file
source ~/ssh_key_manager.sh
```

### Step 4: Reload Zsh configuration

After updating `~/.zshrc`, you need to reload the Zsh configuration for the changes to take effect:

```bash
source ~/.zshrc
```

### Useful Aliases

Several useful aliases will be created to make it easier for you to use the tool:

```bash
# Display alias help
ssh_help # Show help for aliases

# Run SSH key management script
sshm    # Run the SSH key management script

# Check connection to GitHub
sshp    # Check SSH connection to GitHub

# Create a new SSH key
sshnew  # Create a new SSH key

# Display current SSH information
sshc    # Show current SSH key information
```

## Usage

- **`sshm`**: Run the SSH key management tool.
- **`sshp`**: Check the connection to services like GitHub, GitLab, etc.
- **`sshnew`**: Create a new SSH key and configure it for GitHub/GitLab.
- **`sshc`**: Display the current SSH key information, including keys and configuration details.

## Benefits

- **Easy to use**: Create and manage SSH keys with just a few simple commands.
- **Automation**: Easily create new SSH keys and configure them for services like GitHub and GitLab.
- **Convenience**: Easily switch between SSH keys without needing to remember complex commands.

