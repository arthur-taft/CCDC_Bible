#!/usr/bin/env bash

function get_os_name() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        declare -g OS="$NAME"
    elif type lsb_release > /dev/null 2>&1; then
        # linuxbase.org
        declare -g OS
        OS=$(lsb_release -si)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        declare -g OS="$DISTRIB_ID"
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        declare -g OS=Debian
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        declare -g OS
        declare -g VER
        OS=$(uname -s)
    fi
}

function check_package_manager() {
    if [[ -z "$OS" ]]; then
        echo "Error: No OS name provided to remove_package."
        exit 1
    fi

    case "$OS" in
        ubuntu|debian)
            echo "apt"
            ;;
        centos|rocky|almalinux|fedora)
            echo "yum"
            ;;
        arch)
            echo "pacman"
            ;;
        opensuse*)
            echo "zypper"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

function install_package() {
    local package_manager="$1"
    if [[ -z "$package_manager" ]]; then
        echo "Error: No package manager provided to install package :("
        exit 1
    fi

    local package_name="$2"
    if [[ -z "$package_name" ]]; then
        echo "Error: No package name provided to install package :("
        exit 1
    fi

    if [[ "$package_manager" == "unsupported" ]]; then
        echo "Error: Unsupported operating system :("
        exit 1
    fi

    case "$package_manager" in
        apt)
            echo "Using apt to install $package_name..."
            apt update && apt install -y "$package_name"
            ;;
        dnf)
            echo "Using dnf to install $package_name..."
            dnf install -y "$package_name"
            ;;
        yum)
            echo "Using yum to install $package_name..."
            yum install -y "$package_name"
            ;;
        pacman)
            echo "Using pacman to install $package_name..."
            pacman -Syu --noconfirm "$package_name"
            ;;
        *)
            echo "Unsupported package manager :("
            exit 1
            ;;
    esac
}

echo "OS=$OS VER=$VER" > /dev/null 2>&1 

# Clean things up
OS="${OS,,}"

if [ "$OS" = "ubuntu" ]; then
    # Fix version to work with integer comparison
    VER="${VER::-3}"
elif [[ "$OS" =~ "fedora" ]]; then
    # Shorten Fedora Linux to fedora
    OS="fedora"
fi

package_manager=$(check_package_manager)

install_package "$package_manager" "pandoc"

case "$OS" in
    ubuntu|debian)
        install_package "$package_manager" "texlive-xetex"
        install_package "$package_manager" "fonts-noto"
        ;;
    centos|rocky|almalinux|fedora)
        install_package "$package_manager" "texlive-xetex"
        install_package "$package_manager" "texlive-collection-xetex"
        install_package "$package_manager" "texlive-extsizes"
        install_package "$package_manager" "texlive-unicode-math"
        install_package "$package_manager" "texlive-upquote"
        install_package "$package_manager" "texlive-titlepic"
        install_package "$package_manager" "texlive-tocloft"
        install_package "$package_manager" "texlive-tcolorbox"
        install_package "$package_manager" "texlive-tikzfill"
        install_package "$package_manager" "texlive-pdfcol"
        install_package "$package_manager" "texlive-noto"
        ;;
    arch)
        install_package "$package_manager" "texlive-xetex"
        install_package "$package_manager" "texlive-latexextra"
        install_package "$package_manager" "texlive-fontsrecommended"
        ;;
    opensuse*)
        echo "zypper"
        ;;
    *)
        echo "unsupported"
        ;;
esac
