# Install jcd

## macOS (Homebrew)

### From Official Tap (Recommended)
```sh
brew install jcd
```

### From Custom Tap
If using a custom tap:
```sh
brew tap <username>/<tapname>
brew install jcd
```

### Post-Installation Setup
After installation, add the following to your shell configuration:

For bash (`~/.bashrc`):
```sh
export JCD_BINARY="$(brew --prefix)/bin/jcd"
source $(brew --prefix)/bin/jcd_function.sh
```

For zsh (`~/.zshrc`):
```sh
export JCD_BINARY="$(brew --prefix)/bin/jcd"
source $(brew --prefix)/bin/jcd_function.sh
```

Then reload your shell:
```sh
source ~/.bashrc   # or source ~/.zshrc
```

You can also run `jcd-setup` for setup instructions.

## Azure Linux 3
```sh
sudo dnf install jcd
```
## Ubuntu
#### 1. Register Microsoft key and feed
```sh
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
```

#### 2. Install jcd
```sh
sudo apt-get update
sudo apt-get install jcd
```

## Debian
#### 1. Register Microsoft key and feed
```sh
wget -q https://packages.microsoft.com/config/debian/$(. /etc/os-release && echo ${VERSION_ID%%.*})/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
```

#### 2. Install jcd
```sh
sudo apt-get update
sudo apt-get install jcd
```
## Fedora
#### 1. Register Microsoft key and feed
```sh
sudo rpm -Uvh https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/packages-microsoft-prod.rpm
```

#### 2. Install jcd
```sh
sudo apt-get update
sudo apt-get install jcd
```

## RHEL
#### 1. Register Microsoft key and feed
```sh
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/$(. /etc/os-release && echo ${VERSION_ID%%.*})/packages-microsoft-prod.rpm
```

#### 2. Install jcd
```sh
sudo yum install jcd
```

## openSUSE 15
#### 1. Register Microsoft key and feed
```sh
sudo zypper install libicu
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
wget -q https://packages.microsoft.com/config/opensuse/15/prod.repo
sudo mv prod.repo /etc/zypp/repos.d/microsoft-prod.repo
sudo chown root:root /etc/zypp/repos.d/microsoft-prod.repo
```

#### 2. Install jcd
```sh
sudo zypper install jcd
```

## SLES 12
#### 1. Register Microsoft key and feed
```sh
sudo rpm -Uvh https://packages.microsoft.com/config/sles/12/packages-microsoft-prod.rpm
```

#### 2. Install jcd
```sh
sudo zypper install jcd
```

## SLES 15
#### 1. Register Microsoft key and feed
```sh
sudo rpm -Uvh https://packages.microsoft.com/config/sles/15/packages-microsoft-prod.rpm
```

#### 2. Install jcd
```sh
sudo zypper install jcd
```