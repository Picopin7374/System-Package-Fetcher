#!/bin/bash

echo -e "This script needs to be run has root, you will be asked for you password in a moment. \n"
sudo -v

# Defines color for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'  # No Color

OUTPUT_TO_FILE=false
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
FILE_NAME="output-$TIMESTAMP.txt"

function fetch_local_packages {
    echo -e "${RED}\nInitiating system packages fetch...\n${NC}"
    if hash pacman 2>/dev/null ; then
        echo -e "${GREEN}pacman found. Fetching pacman packages...\n${NC}"
        PACKAGE_OUTPUT=$(pacman -Qq 2>&1)
    elif hash apt 2>/dev/null ; then
        echo -e "${GREEN}apt found. Fetching apt packages...\n${NC}"
        PACKAGE_OUTPUT=$(dpkg --get-selections | awk '{print $1}' 2>&1)
    elif hash dnf 2>/dev/null ; then
        echo -e "${GREEN}dnf found. Fetching dnf packages...\n${NC}"
        PACKAGE_OUTPUT=$(dnf repoquery --installed --queryformat '%{name}' 2>&1)
    elif hash zypper 2>/dev/null ; then
        echo -e "${GREEN}zypper found. Fetching zypper packages...\n${NC}"
        PACKAGE_OUTPUT=$(zypper se -i 2>&1)
    elif hash yum 2>/dev/null ; then
        echo -e "${GREEN}yum found. Fetching yum packages...\n${NC}"
        PACKAGE_OUTPUT=$(yum list installed 2>&1)
    elif hash brew 2>/dev/null ; then
        echo -e "${GREEN}brew found. Fetching brew packages...\n${NC}"
        PACKAGE_OUTPUT=$(brew list 2>&1)
    elif hash eopkg 2>/dev/null ; then
        echo -e "${GREEN}eopkg found. Fetching eopkg packages...\n${NC}"
        PACKAGE_OUTPUT=$(eopkg list-installed 2>&1)
    elif hash xbps-query 2>/dev/null ; then
        echo -e "${GREEN}xbps-query found. Fetching xbps packages...\n${NC}"
        PACKAGE_OUTPUT=$(xbps-query -l 2>&1)
    else
        echo "${RED}Error: Unsupported or unrecognized package manager.${NC}"
        return
    fi
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of system packages.\n${PACKAGE_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of system packages:\n${NC}$PACKAGE_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$PACKAGE_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of system packages has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_aur_packages {
    echo -e "${RED}\nInitiating AUR packages fetch...\n${NC}"
    if hash yay 2>/dev/null ; then
        echo -e "${GREEN}Using yay to list AUR packages...\n${NC}"
        AUR_OUTPUT=$(yay -Qm 2>&1)
    elif hash paru 2>/dev/null ; then
        echo -e "${GREEN}Using paru to list AUR packages...\n${NC}"
        AUR_OUTPUT=$(paru -Qm 2>&1)
    elif hash pamac 2>/dev/null; then
        echo -e "${GREEN}Using pamac to list AUR packages...\n${NC}"
        AUR_OUTPUT=$(pamac list -i -a --aur 2>&1)
    elif hash pacaur 2>/dev/null ; then
        echo -e "${GREEN}Using pacaur to list AUR packages...\n${NC}"
        AUR_OUTPUT=$(pacaur -Qm 2>&1)
    elif hash trizen 2>/dev/null ; then
        echo -e "${GREEN}Using trizen to list AUR packages...\n${NC}"
        AUR_OUTPUT=$(trizen -Qm 2>&1)
    else
        echo "${RED}No AUR helper (like yay, paru, pamac, pacaur or trizen) found. Skipping AUR packages.${NC}"
        return
    fi
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of AUR packages.\n${AUR_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of AUR packages:\n${NC}$AUR_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$AUR_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of AUR packages has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_pip_packages {
    echo -e "${RED}\nInitiating pip packages fetch...\n${NC}"
    if ! hash pip 2>/dev/null ; then
        echo "${RED}Error: pip is not installed on your system.${NC}"
        return
    fi
    echo -e "${GREEN}pip found, fetching the list of pip packages...\n${NC}"
    PIP_OUTPUT=$(pip freeze 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of pip packages.\n${PIP_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of pip packages:\n${NC}$PIP_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$PIP_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of pip packages has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_npm_packages {
    echo -e "${RED}\nInitiating npm packages fetch...\n${NC}"
    if ! hash npm 2>/dev/null ; then
        echo "${RED}Error: npm is not installed on your system.${NC}"
        return
    fi
    echo -e "${GREEN}npm found, fetching the list of global npm packages...\n${NC}"
    NPM_OUTPUT=$(npm ls -g --depth=0 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of npm packages.\n${NPM_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of global npm packages:\n${NC}$NPM_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$NPM_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of npm packages has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}


function fetch_flatpak_apps {
    echo -e "${RED}\nInitiating Flatpak applications fetch...\n${NC}"
    if ! hash flatpak 2>/dev/null ; then
        echo "${RED}Error: Flatpak is not installed on your system.${NC}"
        return
    fi
    echo -e "${GREEN}Flatpak found, fetching the list of Flatpak applications...\n${NC}"
    FLATPAK_APPS_OUTPUT=$(flatpak list --app 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of Flatpak applications.\n${FLATPAK_APPS_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of Flatpak applications:\n${NC}$FLATPAK_APPS_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$FLATPAK_APPS_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of Flatpak applications has been written to $FILE_NAME\n${NC}"
    fi

    echo -e "\n${GREEN}Fetching the list of Flatpak addons...\n${NC}"
    FLATPAK_ADDONS_OUTPUT=$(flatpak list --runtime 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of Flatpak addons.\n${FLATPAK_ADDONS_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of Flatpak addons:\n${NC}$FLATPAK_ADDONS_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$FLATPAK_ADDONS_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of Flatpak addons has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_snap_apps {
    echo -e "${RED}\nInitiating Snap applications fetch...\n${NC}"
    if ! hash snap 2>/dev/null ; then
        echo "${RED}Error: Snap is not installed on your system.${NC}"
        return
    fi
    echo -e "${GREEN}Snap found, fetching the list of Snap applications...\n${NC}"
    SNAP_OUTPUT=$(snap list 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of Snap applications.\n${SNAP_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of Snap applications:\n${NC}$SNAP_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$SNAP_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of Snap applications has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_portage_packages {
    echo -e "${RED}\nInitiating Portage packages fetch...\n${NC}"
    if ! hash qlop 2>/dev/null ; then
        echo "${RED}Error: qlop (Portage package manager utility) is not installed or not in PATH on your system.${NC}"
        return
    fi
    echo -e "${GREEN}qlop found, fetching the list of Portage packages...\n${NC}"
    PORTAGE_OUTPUT=$(qlop -l 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of Portage packages.\n${PORTAGE_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of Portage packages:\n${NC}$PORTAGE_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$PORTAGE_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of Portage packages has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_nix_packages {
    echo -e "${RED}\nInitiating Nix packages fetch...\n${NC}"
    if ! hash nix-env 2>/dev/null ; then
        echo "${RED}Error: nix-env (Nix package manager utility) is not installed or not in PATH on your system.${NC}"
        return
    fi
    echo -e "${GREEN}nix-env found, fetching the list of Nix packages...\n${NC}"
    NIX_OUTPUT=$(nix-env -q --installed 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of Nix packages.\n${NIX_OUTPUT}\n${NC}"
        return
    fi
    echo -e "${GREEN}List of Nix packages:\n${NC}$NIX_OUTPUT"
    if $OUTPUT_TO_FILE; then
        echo -e "$NIX_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of Nix packages has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_gnome_extensions {
    echo -e "${RED}\nInitiating GNOME extensions fetch...\n${NC}"
    if ! hash gnome-extensions 2>/dev/null ; then
        echo "${RED}Error: gnome-extensions (GNOME Desktop utility) is not installed or not in PATH on your system.${NC}"
        return
    fi

    echo -e "${GREEN}gnome-extensions found, fetching the list of User Extensions...\n${NC}"
    USER_EXT_OUTPUT=$(gnome-extensions list --enabled --user 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of User Extensions.\n${USER_EXT_OUTPUT}\n${NC}"
        return
    fi 
    echo -e "${GREEN}User Extensions:\n${NC}$USER_EXT_OUTPUT"
    
    echo -e "${GREEN}Fetching the list of System Extensions...\n${NC}"
    SYSTEM_EXT_OUTPUT=$(gnome-extensions list --enabled --system 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error while fetching the list of System Extensions.\n${SYSTEM_EXT_OUTPUT}\n${NC}"
        return
    fi 
    echo -e "${GREEN}System Extensions:\n${NC}$SYSTEM_EXT_OUTPUT"

    GNOME_EXTENSIONS_OUTPUT="\nUser Extensions:\n${USER_EXT_OUTPUT}\nSystem Extensions:\n${SYSTEM_EXT_OUTPUT}"
    if $OUTPUT_TO_FILE; then
        echo -e "$GNOME_EXTENSIONS_OUTPUT" >> "$FILE_NAME"
        echo -e "${GREEN}The list of GNOME extensions has been written to $FILE_NAME\n${NC}"
    fi
    echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
}

function fetch_all {
    fetch_local_packages
    fetch_aur_packages
    fetch_pip_packages
    fetch_npm_packages
    fetch_flatpak_apps
    fetch_snap_apps
    fetch_portage_packages
    fetch_nix_packages
    fetch_gnome_extensions
}

function get_user_option {
    while true; do
        echo -e "\nChoose which package info you want:"
        echo "1 - Local installed packages (pacman, apt, dnf, yum, zypper, homebrew)"
        echo "2 - AUR installed packages (yay, paru, pamac)"
        echo "3 - Pip installed packages"
        echo "4 - npm installed packages"
        echo "5 - Flatpak installed applications"
        echo "6 - Snap installed applications"
        echo "7 - Portage installed packages (Gentoo)"
        echo "8 - Nix installed packages (NixOS)"
        echo "9 - GNOME extensions"
        echo "10 - All of the above"
        echo "Press any other key to exit."

        read -r option

        if [[ $option =~ [1-9] || $option == 10 ]]; then
            echo -e "\nWould you like to save the output to a .txt file? (yes/no)"
            read -r save_option

            if [[ $save_option =~ ^[Yy] ]]; then
                OUTPUT_TO_FILE=true
                echo -e "\nOutput will be saved to $FILE_NAME\n"
            else 
                OUTPUT_TO_FILE=false
            fi
        fi

        case $option in
            1) fetch_local_packages ;;
            2) fetch_aur_packages ;;
            3) fetch_pip_packages ;;
            4) fetch_npm_packages ;;
            5) fetch_flatpak_apps ;;
            6) fetch_snap_apps ;;
            7) fetch_portage_packages ;;
            8) fetch_nix_packages ;;
            9) fetch_gnome_extensions ;;
            10) fetch_all ;;
            *) echo "Exiting..." ;
               exit 0
        esac 
        
        echo -e "\n${RED}----------------------------------------------------------------${NC}\n"
    done
}

get_user_option


