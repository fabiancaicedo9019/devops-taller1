#!/bin/bash
# Archivo de hardening adicional para Ubuntu Server
echo ""
echo "Hardening adicional...."

# Configurar el registro (logging) de eventos de seguridad
echo ""
echo "Configurando registro de eventos de seguridad..."

# Establecer el modo de creación de archivos a 0640 para asegurar la privacidad de los logs
sudo sed -i 's/$FileCreateMode .*/$FileCreateMode 0640/' /etc/rsyslog.conf

# Configurar rsyslog para registrar más información de seguridad
echo "auth,authpriv.*                 /var/log/auth.log" | sudo tee -a /etc/rsyslog.conf
echo "kern.*                          /var/log/kern.log" | sudo tee -a /etc/rsyslog.conf
echo "daemon.*                        /var/log/daemon.log" | sudo tee -a /etc/rsyslog.conf
echo "syslog.*                        /var/log/syslog" | sudo tee -a /etc/rsyslog.conf
echo "user.*                          /var/log/user.log" | sudo tee -a /etc/rsyslog.conf

# Reiniciar el servicio para aplicar cambios
sudo systemctl restart rsyslog
echo "Registro de eventos configurado."
echo ""

# Establecer una política de contraseñas seguras
echo ""
echo "Estableciendo política de contraseñas seguras..."
# Configurar políticas de contraseñas en PAM
{
  echo "minlen = 12"
  # echo "dcredit = -1" # Al menos un dígito
  # echo "ucredit = -1" # Al menos una mayúscula
  # echo "lcredit = -1" # Al menos una minúscula
  # echo "ocredit = -1" # Al menos un carácter no alfanumérico
  # echo "difok = 3" # Especifica cuántos caracteres deben ser diferentes de la palabra del diccionario para que la contraseña sea aceptada.
} >> /etc/security/pwquality.conf
echo "Política de contraseñas seguras establecida."
echo ""

# Deshabilitar el inicio de sesión root por SSH
echo ""
echo "Deshabilitando el inicio de sesión root por SSH..."
# Asegurarse de que el archivo de configuración de SSH contiene la directiva PermitRootLogin
if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
fi

# Reiniciar el servicio SSH para aplicar los cambios
sudo systemctl restart sshd
echo "Inicio de sesión root por SSH deshabilitado."
echo ""

# Crear un nuevo usuario con Zsh y Oh-My-Zsh configurados, con permisos de administrador
echo ""
echo "Creando nuevo usuario 'userssh' con permisos de administrador y configuración de Zsh..."
# Crear el usuario
sudo adduser --gecos "" --disabled-password userssh
# Añadir al usuario al grupo sudo
sudo usermod -aG sudo userssh
# Configurar Zsh y Oh-My-Zsh
sudo cp -r /root/.oh-my-zsh /home/userssh/
sudo cp /root/.zshrc /home/userssh/
sudo chown -R userssh:userssh /home/userssh/.oh-my-zsh /home/userssh/.zshrc
# Cambiar la shell predeterminada a Zsh
sudo chsh -s /usr/bin/zsh userssh
echo "Usuario 'userssh' creado y configurado."
# Generar y establecer una contraseña segura automáticamente
password=$(openssl rand -base64 12)
echo "userssh:$password" | sudo chpasswd
echo "userssh:$password"
echo "Usuario 'userssh' creado y configurado con contraseña segura automáticamente."
echo ""

echo "Hardening adicional completado."
