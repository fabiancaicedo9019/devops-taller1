#!/bin/bash

echo ""
# Configuración básica de seguridad para Nginx
echo "Configurando medidas de seguridad básicas en Nginx..."
sudo sed -i 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf
sudo systemctl restart nginx
echo "Nginx configurado y reiniciado."
echo ""

# Ruta a la carpeta donde está el script y la subcarpeta 'web-site'
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
WEB_ROOT="$SCRIPT_DIR/web-site"

# Crear archivo de configuración para el sitio
NGINX_SITE_CONF="/etc/nginx/sites-available/web-site"
NGINX_SITE_LINK="/etc/nginx/sites-enabled/web-site"

echo ""
# Crear y escribir la configuración del servidor
echo "Creación de archivo de configuración de sitio web estatico"
echo "server {
    listen 80 default_server;
    server_name _;

    root $WEB_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}" | sudo tee $NGINX_SITE_CONF

# Ajustar permisos y propiedad del directorio web y sus directorios superiores
echo "Ajustando permisos y propiedad del directorio web..."
sudo chown -R "www-data:" "$WEB_ROOT"
# Establecer permisos adecuados para directorios (755) y archivos (644)
find "$WEB_ROOT" -type d -exec sudo chmod 755 {} \;
find "$WEB_ROOT" -type f -exec sudo chmod 644 {} \;

# Asegurando que todos los directorios superiores hasta el raíz tengan permisos adecuados
CURRENT_DIR=$WEB_ROOT
while [ "$CURRENT_DIR" != "/" ]; do
    sudo chmod 755 "$CURRENT_DIR"
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
done

# Eliminar el enlace simbólico de la configuración por defecto de Nginx si existe
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Habilitar el sitio web enlazando el archivo de configuración
if [ -L "$NGINX_SITE_LINK" ]; then
    echo "Ya existe un enlace simbólico para el sitio web, reemplazándolo..."
    sudo rm $NGINX_SITE_LINK
fi
sudo ln -s $NGINX_SITE_CONF $NGINX_SITE_LINK

echo ""
# Imprime el estado actual de UFW
echo "Estado actual de UFW:"
ufw status verbose

# Verifica si UFW (Uncomplicated Firewall) está activo. Si no está activo, lo activa.
ufw_status=$(ufw status | grep -o "inactive")
if [[ "$ufw_status" == "inactive" ]]; then
    echo "UFW está inactivo, activándolo..."
    sudo ufw --force enable
    echo "UFW ha sido activado."
else
    echo "UFW ya está activo."
fi

# Configura UFW para permitir tráfico sólo en el puerto 80 para nginx
echo "Configurando UFW para permitir tráfico en el puerto 80..."
sudo ufw allow 80/tcp comment 'permitir tráfico HTTP para nginx'
sudo ufw allow 443/tcp comment 'permitir tráfico HTTPS para nginx' # Se agrega regla para HTTP y HTTPS
# Configura UFW para permitir tráfico sólo en el puerto 22 para ssh
sudo ufw allow 22/tcp comment 'permitir tráfico para ssh'

# Reinicia UFW para aplicar cambios
echo "Reiniciando UFW para aplicar los cambios..."
sudo ufw reload
echo "Configuración de UFW completada."

# Muestra el estado final para verificar la configuración
ufw status verbose

# Reiniciar Nginx para aplicar cambios
sudo systemctl restart nginx
echo "Nginx ha sido configurado para servir el sitio web desde $WEB_ROOT"