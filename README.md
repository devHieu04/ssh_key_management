# SSH Key Manager

`ssh_key_manager` là một công cụ tiện ích giúp bạn quản lý và sử dụng các khóa SSH dễ dàng hơn.

## Cài đặt

### Bước 1: Clone repository

Trước tiên, bạn cần clone repository về máy của mình. Mở terminal và chạy lệnh sau:

```bash
curl -O https://raw.githubusercontent.com/devHieu04/ssh_key_management/refs/heads/main/ssh_key_manager.sh
```
### Bước 2: Cấp quyền thực thi cho ssh_key_manager.sh
```bash
chmod +x ssh_key_manager.sh
```

### Bước 3: Setup config ~/.zshrc
```bash
nano ~/.zshrc #open zshc and start config 
# Add it in your ~/.zshrc
source ~/.ssh_key_manager.sh # if your OS is macOS
source ~/ssh_key_manager.sh # if your OS is linux ubuntu
```
### Bước 4: Load lại zsh của bạn
```bash
source ~/.ssh_key_manager.sh
source ~/.zshrc
```
### Một số alias được tạo

```bash
#some alias 
ssh_help #show alias helper
sshm    # Call the SSH key management script
sshp # Check connection to GitHub
sshnew # Create a new SSH key
sshc # Display current SSH information
```
