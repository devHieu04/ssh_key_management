# SSH Key Manager

`ssh_key_manager` là một công cụ tiện ích giúp bạn quản lý và sử dụng các khóa SSH dễ dàng hơn.

## Cài đặt

### Bước 1: Clone repository

Trước tiên, bạn cần clone repository về máy của mình. Mở terminal và chạy lệnh sau:

```bash
git clone https://github.com/devHieu04/ssh_key_management.git
cd ssh_key_management
```
### Bước 2: Cấp quyền thực thi cho ssh_key_manager.sh
```bash
chmod +x ssh_key_manager.sh
```

### Bước 3: Setup kiểm tra path lưu trữ file
```bash
pwd #get your zsh alias
cd ~  #checkout home 
nano ~/.zshc #open zshc and start config 
export PATH="$PATH:/path/to/ssh_key_manager" #replace your path ssh_key_manager.sh

```
### Một số alias được tạo

```bash
#some alias 
sshm="ssh_key_manager"        # Call the SSH key management script
sshp="check_github_connection" # Check connection to GitHub
sshnew="create_ssh_key"       # Create a new SSH key
sshc="show_ssh_info"          # Display current SSH information
```
