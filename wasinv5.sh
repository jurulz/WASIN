#!/bin/bash

# ASCII Art for WASIN
echo -e "\033[1;33m" # Yellow text color
cat << "EOF"

 █     █░ ▄▄▄        ██████  ██▓ ███▄    █ 
▓█░ █ ░█░▒████▄    ▒██    ▒ ▓██▒ ██ ▀█   █ 
▒█░ █ ░█ ▒██  ▀█▄  ░ ▓██▄   ▒██▒▓██  ▀█ ██▒
░█░ █ ░█ ░██▄▄▄▄██   ▒   ██▒░██░▓██▒  ▐▌██▒
░░██▒██▓  ▓█   ▓██▒▒██████▒▒░██░▒██░   ▓██░
░ ▓░▒ ▒   ▒▒   ▓▒█░▒ ▒▓▒ ▒ ░░▓  ░ ▒░   ▒ ▒ 
  ▒ ░ ░    ▒   ▒▒ ░░ ░▒  ░ ░ ▒ ░░ ░░   ░ ▒░
  ░   ░    ░   ▒   ░  ░  ░   ▒ ░   ░   ░ ░ 
    ░          ░  ░      ░   ░           ░ 
    
****Tenable WAS installer for Nessus****
                                                
EOF
echo -e "\033[0m" # Reset text color

echo "Beginning of the configuration script."

# Function to determine the package manager
determine_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
    elif command -v yum >/dev/null 2>&1; then
        PACKAGE_MANAGER="yum"
    elif command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"
    else
        echo "Unsupported package manager."
        exit 1
    fi
}

# Function to update the system based on package manager
update_system() {
    echo "Updating the system..."
    case $PACKAGE_MANAGER in
        apt)
            sudo apt-get update && sudo apt-get upgrade -y
            ;;
        yum)
            sudo yum update -y
            ;;
        dnf)
            sudo dnf upgrade --refresh -y
            ;;
        *)
            echo "System update not supported for this package manager."
            exit 1
            ;;
    esac
}

# Call the function to determine the package manager
determine_package_manager

# Call the function to update the system
update_system

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    case $PACKAGE_MANAGER in
        apt)
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            sudo apt-get update
            sudo apt-get install -y docker-ce
            ;;
        yum)
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce
            ;;
        dnf)
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo dnf install -y docker-ce --nobest
            ;;
        *)
            echo "Docker installation not supported for this package manager."
            exit 1
            ;;
    esac
}

# Function to start and enable Docker service
start_docker_service() {
    echo "Enabling and starting Docker service..."
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
}

# Function to verify Docker installation
verify_docker_installation() {
    echo "Verifying Docker installation..."
    docker info
    docker version
}

# Call the functions in order
determine_package_manager
install_docker
start_docker_service
verify_docker_installation


# Function to determine the firewall service
determine_firewall_service() {
    if systemctl is-active --quiet firewalld; then
        FIREWALL_SERVICE="firewalld"
    elif command -v ufw >/dev/null 2>&1; then
        FIREWALL_SERVICE="ufw"
    else
        echo "No supported firewall service found."
        exit 1
    fi
}

# Function to configure firewall based on the service
configure_firewall() {
    echo "Configuring the firewall for Docker..."
    case $FIREWALL_SERVICE in
        firewalld)
            echo "Using firewalld for firewall configuration."
            sudo systemctl start firewalld
            ;;
        ufw)
            echo "Using ufw for firewall configuration."
            sudo ufw enable
            ;;
        *)
            echo "Firewall configuration not supported for this service."
            exit 1
            ;;
    esac
}

# Prompt for user decision
echo "Do you want to limit the connection of the scanner to the security center console only? (yes/no)"
read limit_connection

# Call the functions in order
determine_firewall_service
configure_firewall

# Function to apply firewall rules based on user input
apply_firewall_rules() {
    if [ "$limit_connection" = "yes" ]; then
        echo "Please enter the IP address or hostname of the SC console:"
        read sc_console_ip
        echo "Limiting access to $sc_console_ip on port 8834..."
        case $FIREWALL_SERVICE in
            firewalld)
                sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="'$sc_console_ip'" port port=8834 protocol=tcp accept' --permanent
                ;;
            ufw)
                sudo ufw allow from $sc_console_ip to any port 8834 proto tcp
                ;;
        esac
    else
        echo "Opening port 8834/tcp in the firewall for everyone..."
        case $FIREWALL_SERVICE in
            firewalld)
                sudo firewall-cmd --zone=public --add-port=8834/tcp --permanent
                ;;
            ufw)
                sudo ufw allow 8834/tcp
                ;;
        esac
    fi

    # Reload firewall rules
    echo "Reloading firewall rules..."
    case $FIREWALL_SERVICE in
        firewalld)
            sudo firewall-cmd --reload
            ;;
        ufw)
            sudo ufw reload
            ;;
    esac

    # Check open ports in the firewall (for firewalld)
    if [ "$FIREWALL_SERVICE" = "firewalld" ]; then
        echo "Checking open ports in the firewall..."
        sudo firewall-cmd --zone=public --list-ports
    fi
}


echo "End of the configuration script. You can now install Nessus Scanner"

# Checking for Nessus installation packages in /opt
echo "Checking for Nessus installation packages in /opt..."

# Loop over each file that matches the pattern
for file in $(ls /opt | grep Nessus); do
    full_path="/opt/$file"

    # Match RPM packages for CentOS/RHEL
    if [[ $file == *es*.x86_64.rpm ]]; then
        echo "Found CentOS/RHEL compatible Nessus package: $file"
        echo "Installing Nessus..."
        sudo yum install "$full_path"
        echo "Starting Nessus service..."
        sudo /bin/systemctl start nessusd.service
    
    # Match DEB packages for Debian
    elif [[ $file == *debian*.deb ]]; then
        echo "Found Debian compatible Nessus package: $file"
        echo "Installing Nessus..."
        sudo dpkg -i "$full_path"
        echo "Starting Nessus service..."
        sudo /bin/systemctl start nessusd.service
    
    # Match TXZ packages for FreeBSD
    elif [[ $file == *fbsd*.txz ]]; then
        echo "Found FreeBSD compatible Nessus package: $file"
        echo "Installing Nessus..."
        sudo pkg add "$full_path"
        echo "Starting Nessus service..."
        sudo /bin/systemctl start nessusd.service

    # Match any other DNF-based system packages
    elif [[ $file == *debian*.rpm ]]; then
        echo "Found generic DNF-based system Nessus package: $file"
        echo "Installing Nessus..."
        sudo dnf install "$full_path"
        echo "Starting Nessus service..."
        sudo /bin/systemctl start nessusd.service

    else
        echo "Found Nessus package but unsure how to install: $file"
    fi
done

echo "End of the configuration script. Nessus installation process complete."