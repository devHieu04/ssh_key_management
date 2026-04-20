# SSH Key Manager

`ssh_key_manager` is a utility tool designed to simplify the management and usage of SSH keys. With this tool, you can create, manage, and switch between SSH keys for services like GitHub, GitLab, and other custom Git hosts.

## Installation

### Step 1: Download the script

To get started, download the script to your local machine:

```bash
curl -O https://raw.githubusercontent.com/devHieu04/ssh_key_management/main/ssh_key_manager.sh
```

### Step 2: Grant execution permission for `ssh_key_manager.sh`

Next, grant execution permissions for the script:

```bash
chmod +x ssh_key_manager.sh
```

### Step 3: Configure `~/.zshrc`

Open the `~/.zshrc` configuration file and add the following line at the end of the file:

#### For macOS:

```bash
nano ~/.zshrc
# Add this line to the end of the file
source ~/ssh_key_manager.sh
```

#### For Linux (Ubuntu):

```bash
nano ~/.zshrc
# Add this line to the end of the file
source ~/ssh_key_manager.sh
```

### Step 4: Reload Zsh configuration

After updating `~/.zshrc`, reload the Zsh configuration for the changes to take effect:

```bash
source ~/.zshrc
```

### Useful Aliases

Several useful aliases are created to make the tool easier to use:

```bash
# Display alias help
ssh_help   # Show help for aliases

# Run SSH key management script
sshm       # Run the SSH key management script

# List SSH keys and supported hosts
sshl       # Show keys, hosts, and usage examples

# Check connection to GitHub
sshp       # Check SSH connection to GitHub

# Create a new SSH key
sshnew     # Create a new SSH key

# Display current SSH information
sshc       # Show current SSH key information

# Remove an SSH key pair
sshrm      # Remove an SSH key and related config entries

# Copy a public key
ssh_copy   # Copy an SSH public key to the clipboard
```

## Usage

- **`sshm`**: Run the SSH key management tool in interactive mode.
- **`sshm <key_index> <host>`**: Switch directly to a key/host pair, for example `sshm 0 github`.
- **`sshl`**: List SSH keys and available hosts.
- **`sshp`**: Check the connection to GitHub.
- **`sshnew`**: Create a new SSH key.
- **`sshc`**: Display the current SSH key information, including configured hosts and keys.
- **`sshrm`**: Remove an SSH key pair and matching SSH config entries.
- **`ssh_copy`**: Copy a selected public key to the clipboard.

## Benefits

- **Easy to use**: Create and manage SSH keys with a few simple commands.
- **Automation**: Quickly switch SSH identities for Git hosting services.
- **Convenience**: Use short aliases instead of remembering longer commands.
