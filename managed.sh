#!/bin/bash
## Extremely Managed Server Script (Supports Ubuntu & CentOS)

# Detect OS ID
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    echo "Unsupported OS: cannot detect /etc/os-release"
    exit 1
fi

# Function to install a package if available (apt or dnf)
install_package_if_available() {
    local pkg=$1
    if [ "$OS_ID" = "ubuntu" ] || [ "$OS_ID" = "debian" ]; then
        package_name=$(apt search "$pkg" 2>/dev/null | grep -o "^$pkg\S*")
        if [[ -n "$package_name" ]]; then
            sudo apt install -y "$package_name"
        else
            echo "Package $pkg not found in the APT repositories."
        fi
    elif [[ "$OS_ID" == "centos" || "$ID_LIKE" == *"rhel"* ]]; then
        if dnf list available "$pkg" >/dev/null 2>&1; then
            sudo dnf install -y "$pkg"
        else
            echo "Package $pkg not found in the DNF repositories."
        fi
    fi
}

echo "Detected OS: $OS_ID"

# Main logic
if [ "$OS_ID" = "ubuntu" ] || [ "$OS_ID" = "debian" ]; then
    sudo apt update
    sudo apt install -y python3 python3-pip curl python3-venv

elif [[ "$OS_ID" == "centos" || "$ID_LIKE" == *"rhel"* ]]; then
    sudo dnf makecache
    sudo dnf install -y python3 python3-pip curl python3-virtualenv
fi

# Install optional system Python packages
install_package_if_available "python3-netifaces"
install_package_if_available "python3-colorama"
install_package_if_available "python3-requests"

# Create and activate a virtual environment
python3 -m venv /tmp/my_env
source /tmp/my_env/bin/activate

pip install --upgrade pip
pip install netifaces colorama requests
pip list

# Run the external script
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Azumi67/Backhaul_script/refs/heads/main/backhaul.sh)"

deactivate
