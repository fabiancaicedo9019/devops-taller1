#!/bin/bash

echo "Iniciando el proceso de ejecución de scripts..."

# Llamar al script de dependencias
echo ""
echo "Ejecutando el script de dependencias..."
./dependencies.sh
echo ""

# Llamar script de configuración del Nginx y despliegue HTML:
echo ""
echo "Ejecutando el configurando Nginx y despliegue HTML..."
./nginx-config.sh
echo ""

# Llamar script de configuración del HTML
echo ""
echo "Ejecutando el configurando HTML..."
./additional-hardening.sh
echo ""

echo "Todos los scripts se han ejecutado."

# Reinicio del sistema con cuenta regresiva
# echo "El sistema se reiniciará en 5 segundos..."
# for i in {5..1}; do
#     echo "$i..."
#     sleep 1
# done

# echo "Reiniciando ahora."
# sudo reboot