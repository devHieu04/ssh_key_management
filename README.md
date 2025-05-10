
# SSH Key Manager

`ssh_key_manager` là một công cụ tiện ích mạnh mẽ giúp bạn quản lý và sử dụng các khóa SSH một cách dễ dàng và thuận tiện hơn. Với công cụ này, bạn có thể dễ dàng quản lý, tạo mới và chuyển đổi giữa các khóa SSH, đảm bảo sự liên lạc an toàn và hiệu quả với các dịch vụ từ xa như GitHub, GitLab và nhiều dịch vụ khác.

## Cài đặt

### Bước 1: Clone repository

Để bắt đầu, bạn cần clone repository về máy của mình. Mở terminal và chạy lệnh sau:

```bash
curl -O https://raw.githubusercontent.com/devHieu04/ssh_key_management/main/ssh_key_manager.sh
```

### Bước 2: Cấp quyền thực thi cho `ssh_key_manager.sh`

Tiếp theo, bạn cần cấp quyền thực thi cho script:

```bash
chmod +x ssh_key_manager.sh
```

### Bước 3: Cấu hình `~/.zshrc`

Mở file cấu hình `~/.zshrc` và thêm dòng lệnh sau vào cuối file:

#### Trên macOS:

```bash
nano ~/.zshrc
# Thêm dòng sau vào cuối file
source ~/.ssh_key_manager.sh
```

#### Trên Linux (Ubuntu):

```bash
nano ~/.zshrc
# Thêm dòng sau vào cuối file
source ~/ssh_key_manager.sh
```

### Bước 4: Tải lại cấu hình Zsh

Sau khi cập nhật `~/.zshrc`, bạn cần tải lại cấu hình Zsh để áp dụng thay đổi:

```bash
source ~/.zshrc
```

### Các alias hữu ích

Một số alias sẽ được tạo ra để giúp bạn sử dụng công cụ dễ dàng hơn:

```bash
# Hiển thị trợ giúp về alias
ssh_help # hiển thị hướng dẫn về các alias

# Gọi script quản lý SSH key
sshm    # chạy script quản lý SSH key

# Kiểm tra kết nối đến GitHub
sshp    # kiểm tra kết nối SSH đến GitHub

# Tạo một SSH key mới
sshnew  # tạo khóa SSH mới

# Hiển thị thông tin SSH hiện tại
sshc    # hiển thị thông tin về khóa SSH hiện tại
```

## Sử dụng

- **`sshm`**: Chạy công cụ quản lý SSH key.
- **`sshp`**: Kiểm tra kết nối đến các dịch vụ GitHub, GitLab, v.v.
- **`sshnew`**: Tạo một SSH key mới và cấu hình cho dịch vụ GitHub/GitLab.
- **`sshc`**: Hiển thị thông tin SSH hiện tại của bạn, bao gồm các keys và các thông tin cấu hình.

## Lợi ích

- **Dễ sử dụng**: Tạo và quản lý các SSH key chỉ với vài lệnh đơn giản.
- **Tự động hóa**: Giúp bạn dễ dàng tạo SSH key mới và cấu hình cho các dịch vụ như GitHub, GitLab.
- **Tiện lợi**: Dễ dàng chuyển đổi giữa các SSH key mà không cần phải nhớ các lệnh phức tạp.

---

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

