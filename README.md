
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

**BETA** Tenable WAS Installer for Nessus
This script automates the setup and configuration of a Nessus scanner on Linux systems. it methodically prepares the system for Nessus installation and ensures all necessary components are correctly configured.

Key Features:
1.	System Update: Updates system packages using yum.
2.	Docker Installation: Installs Docker and adds the Docker CE repository.
3.	Docker Service Management: Enables and starts the Docker service.
4.	Docker Verification: Checks Docker installation status and version.
5.	Firewall Configuration: Configures the system firewall, with an option to restrict scanner connectivity to a specific IP or hostname, or to allow open access on port 8834.
6.	Nessus Package Installation: Searches /opt for Nessus installation packages, recognizes various formats (RPM, DEB, TXZ), and installs based on the operating system. It starts the Nessus service post-installation.
7.	Feedback and Transparency: Provides informative feedback throughout the process.

Instructions for Use:
1.	Prepare Your System: Ensure you're using a compatible Linux distribution. This script has been tested on Oracle Linux 9 minimal install.
2.	Add Nessus Package: If you wish to install Nessus, place the appropriate Nessus package in the /opt folder. The script supports various package types and will automatically detect and install it.
3.	Run the Script: Execute the script as a superuser to ensure all operations (such as system updates, package installations, and service management) can be performed without interruption.
4.	Follow Prompts: During execution, the script will prompt you to make choices, such as firewall configuration. Respond as per your requirements.

Testing Note:
This script has been specifically tested on Oracle Linux 9 with a minimal installation setup with the Standard installation of Oracle Linux addon. While it offers broad compatibility with other Linux distributions, optimal performance and behavior are best guaranteed on similar environments.


Conclusion:
This script is designed to streamline the deployment and configuration process of Nessus in a Linux environment, making it an efficient tool for system administrators or security professionals. It reduces manual intervention and ensures a consistent setup across different systems.

