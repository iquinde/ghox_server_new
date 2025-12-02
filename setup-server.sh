#!/bin/bash

# Script de configuración inicial para servidor Digital Ocean
# Ejecutar como root en el servidor nuevo

echo "🔧 Configurando servidor Digital Ocean para Ghox Server..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
apt update && apt upgrade -y

# Instalar Node.js 18
echo "🟢 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Instalar PM2 globalmente
echo "⚡ Instalando PM2..."
npm install -g pm2

# Instalar Nginx
echo "🌐 Instalando Nginx..."
apt install -y nginx

# Instalar Git
echo "📋 Instalando Git..."
apt install -y git

# Crear directorio para la aplicación
echo "📁 Creando directorios..."
mkdir -p /opt/ghox_server
mkdir -p /opt/ghox_server/logs

# Crear usuario para la aplicación
echo "👤 Creando usuario para la aplicación..."
useradd -r -s /bin/false ghox
chown -R ghox:ghox /opt/ghox_server

# Configurar firewall
echo "🔥 Configurando firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Habilitar servicios
echo "🚀 Habilitando servicios..."
systemctl enable nginx
systemctl start nginx

# Configurar PM2 para iniciar con el sistema
echo "⚙️ Configurando PM2 startup..."
pm2 startup systemd

echo "✅ Configuración inicial completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Clonar el repositorio en /opt/ghox_server"
echo "2. Configurar las variables de entorno"
echo "3. Configurar Nginx con el dominio"
echo "4. Configurar certificados SSL (Let's Encrypt)"
echo "5. Ejecutar el deploy inicial"