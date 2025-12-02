#!/bin/bash

# Script de despliegue para Digital Ocean
# Este script se ejecuta en el servidor después de cada push

echo "🚀 Iniciando despliegue..."

# Navegar al directorio de la aplicación
cd /opt/ghox_server

# Detener la aplicación actual si está ejecutándose
echo "⏹️ Deteniendo aplicación actual..."
pm2 stop ghox-server || true

# Hacer pull de los últimos cambios
echo "⬇️ Obteniendo últimos cambios..."
git pull origin main

# Instalar/actualizar dependencias
echo "📦 Instalando dependencias..."
npm ci --only=production

# Reiniciar la aplicación con PM2
echo "🔄 Reiniciando aplicación..."
pm2 restart ghox-server || pm2 start src/index.js --name ghox-server

# Guardar configuración de PM2
pm2 save

echo "✅ Despliegue completado exitosamente!"