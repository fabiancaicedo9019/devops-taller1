#!/bin/bash

# Actualizar e instalar Zsh si no está presente
if ! command -v zsh &> /dev/null; then
    echo "Instalando Zsh..."
    sudo apt update
    sudo apt install -y zsh
fi

# Función para instalar Oh-My-Zsh para un usuario
install_oh_my_zsh_for_user() {
    local user_home=$1
    local user_name
	user_name=$(basename "$user_home")
    if [ ! -d "$user_home/.oh-my-zsh" ]; then
        echo "Instalando Oh-My-Zsh para $user_name..."
        sudo git clone https://github.com/ohmyzsh/ohmyzsh.git "$user_home/.oh-my-zsh"
        sudo cp "$user_home/.oh-my-zsh/templates/zshrc.zsh-template" "$user_home/.zshrc"
        sudo chown -R "$user_name:$user_name" "$user_home/.oh-my-zsh" "$user_home/.zshrc"
        echo "Oh-My-Zsh instalado para $user_name."
    else
        echo "Oh-My-Zsh ya está instalado para $user_name."
    fi
}

echo ""
# Instalar Oh-My-Zsh para root y todos los usuarios de /home
echo "Instalando Oh-My-Zsh para root y todos los usuarios de /home..."
echo ""
install_oh_my_zsh_for_user "/root"
for dir in /home/*; do
    if [ -d "$dir" ]; then
        echo ""
        install_oh_my_zsh_for_user "$dir"
        user_temp=$(basename "$dir")
        chsh -s /usr/bin/zsh "$user_temp"
        echo ""
    fi
done

echo ""
# Establecer Zsh como la shell por defecto para root
echo "Estableciendo Zsh como la shell por defecto para root..."
sudo chsh -s "$(which zsh)" root
echo ""

# Instalar y configurar las dependencias restantes
install_if_not_present() {
    echo ""
    local package=$1
    if ! dpkg -l | grep -qw "$package"; then
        echo "$package no está instalado. Instalando $package..."
        sudo apt update
        sudo apt install -y "$package"
        echo "$package ha sido instalado."
    else
        echo "$package ya está instalado."
    fi
    echo ""
}

install_if_not_present tree
install_if_not_present net-tools
install_if_not_present nginx
install_if_not_present rsyslog
install_if_not_present libpam-pwquality